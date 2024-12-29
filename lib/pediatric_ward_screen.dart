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
      ],
    );
  }

  Widget _buildMedicationList(Box<DrugMonograph> drugBox) {
    final drugs = drugBox.values.toList();

    return ListView.builder(
      itemCount: drugs.length,
      itemBuilder: (context, index) {
        final drug = drugs[index];
        bool isSelected = selectedMedications
            .any((med) => med['genericName'] == drug.genericName);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 4,
          child: CheckboxListTile(
            title: Text(drug.genericName),
            subtitle: const Text('test'),
            // 'Dose: ${drug.nicuDose} ${drug.nicuConditions} \nRegimen: ${drug.regimen}'),
            value: isSelected,
            onChanged: (bool? value) {
              if (value == true) {
                // Add to selected medications
                // final calculatedDose = _calculateDose(
                //     drug.dose, drug.doseUnit, drug.dilution, drug.vialConc);
                // setState(() {
                //   selectedMedications.add({
                //     'genericName': drug.genericName,
                //     'dose': drug.dose,
                //     'doseUnit': drug.doseUnit,
                //     'calculatedDose': calculatedDose,
                //     'regimen': drug.regimen,
                //   });
                // });
              } else {
                // Remove from selected medications
                setState(() {
                  selectedMedications.removeWhere(
                      (med) => med['genericName'] == drug.genericName);
                });
              }
            },
          ),
        );
      },
    );
  }

  double _calculateDose(
      double dose, String doseUnit, double dilution, double vialConc) {
    final weight = double.tryParse(_patientWeightController.text) ?? 0.0;
    return (dose * weight * dilution) / vialConc;
  }

  Future<void> _saveAndUploadData() async {
    if (_patientNameController.text.isEmpty ||
        _patientWeightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter patient name and weight'),
      ));
      return;
    }

    final patientData = {
      'name': _patientNameController.text,
      'weight': _patientWeightController.text,
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
        selectedMedications.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save data: $e'),
      ));
    }
  }
}
