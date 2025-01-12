import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../provider/drug_monograph_hive.dart';

class PediatricWardScreen extends StatefulWidget {
  const PediatricWardScreen({Key? key}) : super(key: key);

  @override
  State<PediatricWardScreen> createState() => _PediatricWardScreenState();
}

class _PediatricWardScreenState extends State<PediatricWardScreen> {
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _patientWeightController =
      TextEditingController();
  final TextEditingController _patientGAController =
      TextEditingController(); // Gestational Age
  final TextEditingController _patientPNAController =
      TextEditingController(); // Postnatal Age

  final Map<String, String> _calculatedDoses = {};
  Map<String, String?> selectedDoses = {};

  List<Map<String, dynamic>> selectedMedications = [];

  @override
  Widget build(BuildContext context) {
    final drugBox = Provider.of<Box<DrugMonograph>>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pediatric Ward'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPatientInfoInput(),
            const SizedBox(height: 20),
            Expanded(
              child: _buildMedicationList(drugBox),
            ),
            ElevatedButton(
              onPressed: _saveAndUploadData,
              child: const Text('Save and Upload'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoInput() {
    return Column(
      children: [
        TextField(
          controller: _patientNameController,
          decoration: const InputDecoration(
            labelText: 'Patient Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _patientWeightController,
          decoration: const InputDecoration(
            labelText: 'Patient Weight (kg)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _patientGAController,
          decoration: const InputDecoration(
            labelText: 'Gestational Age (weeks)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _patientPNAController,
          decoration: const InputDecoration(
            labelText: 'Postnatal Age (days)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildMedicationList(Box<DrugMonograph> drugBox) {
    final drugs = drugBox.values.toList();

    return ListView.builder(
      itemCount: drugs.length,
      itemBuilder: (context, index) {
        final sortedDrugs = drugs..sort((a, b) => a.id.compareTo(b.id));
        final drug = sortedDrugs[index];
        final doseOptions = _getDoseOptions(drug);

        // Initialize selectedDose
        String? selectedDose = selectedDoses[drug.genericName] ??
            (doseOptions.isNotEmpty ? doseOptions.first['doseString'] : null);

        // Compute calculatedDose without modifying the state
        String calculatedDose = _calculatedDoses[drug.genericName] ??
            (selectedDose != null
                ? _calculateDose(drug, selectedDose).toString()
                : '0.0');

        // Find the note for the selected dose
        String note = '';
        if (selectedDose != null) {
          final selectedOption = doseOptions.firstWhere(
            (option) => option['doseString'] == selectedDose,
            orElse: () => {'note': ''},
          );
          note = selectedOption['note'] ?? '';
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 4,
          child: CheckboxListTile(
            title: Text(drug.genericName),
            subtitle: selectedMedications
                    .any((med) => med['genericName'] == drug.genericName)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$selectedDose $calculatedDose ml'),
                      if (note.isNotEmpty) Text('Note: $note'),
                      if (doseOptions.isNotEmpty)
                        DropdownButton<String>(
                          value: selectedDose,
                          items: doseOptions
                              .map((option) => DropdownMenuItem(
                                    value: option['doseString'],
                                    child: Text(option['doseString']!),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedDoses[drug.genericName] = value;
                              _updateCalculatedDose(drug, value!);
                            });
                          },
                        ),
                    ],
                  )
                : null,
            value: selectedMedications
                .any((med) => med['genericName'] == drug.genericName),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedMedications.add({
                    'genericName': drug.genericName,
                    'dose': selectedDose,
                  });
                } else {
                  selectedMedications.removeWhere(
                      (med) => med['genericName'] == drug.genericName);
                }
              });
            },
          ),
        );
      },
    );
  }

  List<Map<String, String>> _getDoseOptions(DrugMonograph drug) {
    final ga = int.tryParse(_patientGAController.text) ?? 0;
    final pna = int.tryParse(_patientPNAController.text) ?? 0;
    final weight = double.tryParse(_patientWeightController.text) ?? 0.0;

    // Filter conditions matching GA, PNA, and weight
    final conditions = drug.nicuConditions?.where((cond) {
      final gaMatch = (cond.minGA == null || ga >= cond.minGA!) &&
          (cond.maxGA == null || ga <= cond.maxGA!);
      final pnaMatch = (cond.minPNA == null || pna >= cond.minPNA!) &&
          (cond.maxPNA == null || pna <= cond.maxPNA!);
      final weightMatch =
          (cond.minWeight == null || weight >= cond.minWeight!) &&
              (cond.maxWeight == null || weight <= cond.maxWeight!);
      return gaMatch && pnaMatch && weightMatch;
    }).toList();

    if (conditions != null && conditions.isNotEmpty) {
      // Map all matching conditions to structured data
      return conditions.map((cond) {
        final dose = cond.dose ?? 0.0;
        final regimen = cond.regimen ?? '';
        final unit = drug.unit ?? '';
        final note = cond.note ?? '';
        final disease = cond.disease ?? '';

        // Construct the dose string for the dropdown
        String doseString = '$dose $unit every $regimen hours';
        if (disease.isNotEmpty) {
          doseString += ' for $disease';
        }

        return {
          'doseString': doseString, // For dropdown
          'note': note, // For subtitle
        };
      }).toList();
    }
    return [
      {
        'doseString': 'No suitable dose found',
        'note': '',
      }
    ];
  }

  void _updateSelectedMedication(DrugMonograph drug, String selectedDose) {
    // Update the selected medication's dose in the list
    setState(() {
      final medicationIndex = selectedMedications
          .indexWhere((med) => med['genericName'] == drug.genericName);
      if (medicationIndex != -1) {
        selectedMedications[medicationIndex]['dose'] = selectedDose;
      }
    });
  }

  void _updateCalculatedDose(DrugMonograph drug, String selectedDose) {
    // Parse the selected dose
    final doseParts = selectedDose.split(' ');
    final dose = double.tryParse(doseParts[0]) ?? 0.0;
    final weight = double.tryParse(_patientWeightController.text) ?? 0.0;
    final finalDilution = (drug.dilution).toDouble();
    final vialConcentration = (drug.vialConc).toDouble();

    double calculatedDose = dose * weight * (finalDilution / vialConcentration);

    // Round the result to 2 decimal places
    calculatedDose = double.parse(calculatedDose.toStringAsFixed(2));
    String theDose = calculatedDose.toString();
    // Update state
    setState(() {
      _calculatedDoses[drug.genericName] = theDose;
    });
  }

  double _calculateDose(DrugMonograph drug, String selectedDose) {
    // Parse the selected dose
    final doseParts = selectedDose.split(' ');
    final dose = double.tryParse(doseParts[0]) ?? 0.0;
    final weight = double.tryParse(_patientWeightController.text) ?? 0.0;

    // Ensure drug dilution and vial concentration are properly handled
    final finalDilution = (drug.dilution).toDouble();
    final vialConcentration = (drug.vialConc).toDouble();

    // Calculate the dose
    double calculatedDose = dose * weight * (finalDilution / vialConcentration);

    // Round the result to 2 decimal places
    return double.parse(calculatedDose.toStringAsFixed(2));
  }

  String _getSelectedDose(DrugMonograph drug) {
    final ga = int.tryParse(_patientGAController.text) ?? 0;
    final pna = int.tryParse(_patientPNAController.text) ?? 0;
    final weight = double.tryParse(_patientWeightController.text) ?? 0.0;

    // Find the most specific matching condition
    final condition = drug.nicuConditions?.firstWhere(
      (cond) {
        final gaMatch = (cond.minGA == null || ga >= cond.minGA!) &&
            (cond.maxGA == null || ga <= cond.maxGA!);
        final pnaMatch = (cond.minPNA == null || pna >= cond.minPNA!) &&
            (cond.maxPNA == null || pna <= cond.maxPNA!);
        final weightMatch =
            (cond.minWeight == null || weight >= cond.minWeight!) &&
                (cond.maxWeight == null || weight <= cond.maxWeight!);
        return gaMatch && pnaMatch && weightMatch;
      },
      //orElse: () => null,
    );

    if (condition != null) {
      final dose = condition.dose ?? 0.0;
      String checkRegimen = '';
      final regimen = condition.regimen ?? '';
      if (regimen != '') {
        checkRegimen = 'every $regimen hours';
      }

      final unit = drug.unit;
      return '$dose $unit $checkRegimen';
    }
    return 'No suitable dose found';
  }

  Future<void> _saveAndUploadData() async {
    if (_patientNameController.text.isEmpty ||
        _patientWeightController.text.isEmpty ||
        _patientGAController.text.isEmpty ||
        _patientPNAController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all patient details'),
      ));
      return;
    }

    final patientData = {
      'name': _patientNameController.text,
      'weight': _patientWeightController.text,
      'gestationalAge': _patientGAController.text,
      'postnatalAge': _patientPNAController.text,
      'medications': selectedMedications,
    };

    try {
      await FirebaseFirestore.instance
          .collection('departments')
          .doc('PediatricWard')
          .collection('patients')
          .add(patientData);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Patient data saved and uploaded successfully!'),
      ));
      setState(() {
        _patientNameController.clear();
        _patientWeightController.clear();
        _patientGAController.clear();
        _patientPNAController.clear();
        selectedMedications.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save data: $e'),
      ));
    }
  }
}
