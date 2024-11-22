import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientInfoScreen extends StatefulWidget {
  final String patientId;
  final String department;

  PatientInfoScreen({required this.patientId, required this.department});

  @override
  _PatientInfoScreenState createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController hourOfBirthController = TextEditingController();
  TextEditingController gestationalAgeController = TextEditingController();
  TextEditingController dayOfBirthController = TextEditingController();
  TextEditingController admissionDayController = TextEditingController();

  DateTime? selectedDayOfBirth;
  DateTime? selectedAdmissionDate;

  Future<void> fetchPatientData() async {
    final doc = await FirebaseFirestore.instance
        .collection('departments')
        .doc(widget.department)
        .collection('patients')
        .doc(widget.patientId)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;

      hourOfBirthController.text = data['Hour of birth'] ?? '';
      gestationalAgeController.text = data['Gestational age'] ?? '';

      if (data['Day of birth'] != null) {
        selectedDayOfBirth = DateTime.parse(data['Day of birth']);
        dayOfBirthController.text =
            selectedDayOfBirth!.toIso8601String().split('T')[0];
      }

      if (data['Admission day'] != null) {
        selectedAdmissionDate = DateTime.parse(data['Admission day']);
        admissionDayController.text =
            selectedAdmissionDate!.toIso8601String().split('T')[0];
      }
    }
  }

  Future<void> updatePatientData() async {
    final updatedData = {
      'Hour of birth': hourOfBirthController.text,
      'Gestational age': gestationalAgeController.text,
      'Day of birth': selectedDayOfBirth?.toIso8601String(),
      'Admission day': selectedAdmissionDate?.toIso8601String(),
    };

    await FirebaseFirestore.instance
        .collection('departments')
        .doc(widget.department)
        .collection('patients')
        .doc(widget.patientId)
        .update(updatedData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Patient information updated successfully.')),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchPatientData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Day of Birth Field
                      TextFormField(
                        controller: dayOfBirthController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Day of Birth',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDayOfBirth ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );

                          if (selectedDate != null) {
                            setState(() {
                              selectedDayOfBirth = selectedDate;
                              dayOfBirthController.text =
                                  selectedDate.toIso8601String().split('T')[0];
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Hour of Birth Field
                      TextFormField(
                        controller: hourOfBirthController,
                        decoration: InputDecoration(
                          labelText: 'Hour of Birth',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Gestational Age Field
                      TextFormField(
                        controller: gestationalAgeController,
                        decoration: InputDecoration(
                          labelText: 'Gestational Age',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Admission Day Field
                      TextFormField(
                        controller: admissionDayController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Admission Day',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate:
                                selectedAdmissionDate ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );

                          if (selectedDate != null) {
                            setState(() {
                              selectedAdmissionDate = selectedDate;
                              admissionDayController.text =
                                  selectedDate.toIso8601String().split('T')[0];
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Save Button
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            updatePatientData();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
