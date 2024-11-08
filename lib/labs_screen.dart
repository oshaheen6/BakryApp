import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LabsScreen extends StatefulWidget {
  final String patientId;

  LabsScreen({required this.patientId});

  @override
  _LabsScreenState createState() => _LabsScreenState();
}

class _LabsScreenState extends State<LabsScreen> {
  final List<Map<String, dynamic>> labTests = [
    {
      'name': 'RBS',
      'range': [50, 150]
    },
    {
      'name': 'Na',
      'range': [135, 145]
    },
    {
      'name': 'K',
      'range': [3.5, 6]
    },
    {
      'name': 'Creatinine',
      'range': [0.6, 0.9]
    },
  ];

  String? selectedTest;
  double? result;
  bool isCritical = false;
  String? comment;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Color getCardColor() {
    if (isCritical) {
      return comment != null && comment!.isNotEmpty
          ? Colors.orange
          : Colors.red;
    } else if (isInNormalRange()) {
      return Colors.green;
    }
    return Colors.grey.shade200;
  }

  bool isInNormalRange() {
    if (selectedTest == null || result == null) return false;
    final range =
        labTests.firstWhere((test) => test['name'] == selectedTest)['range'];
    return result! >= range[0] && result! <= range[1];
  }

  // Method to save the lab result to Firestore
  void _saveLabResult() {
    if (selectedTest != null && result != null) {
      _firestore
          .collection('patients')
          .doc(widget.patientId)
          .collection('labs')
          .add({
        'testName': selectedTest,
        'result': result,
        'isCritical': isCritical,
        'comment': comment ?? '',
        'dateCreated': DateTime.now().toString(),
      });
      // Optionally, reset fields after saving
      setState(() {
        selectedTest = null;
        result = null;
        isCritical = false;
        comment = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Labs')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: const Text("Select Lab Test"),
              value: selectedTest,
              onChanged: (String? value) {
                setState(() {
                  selectedTest = value;
                  result = null;
                  isCritical = false;
                  comment = null;
                });
              },
              items: labTests.map<DropdownMenuItem<String>>((test) {
                return DropdownMenuItem<String>(
                  value: test['name'],
                  child: Text(test['name']),
                );
              }).toList(),
            ),
            if (selectedTest != null) ...[
              TextField(
                decoration: const InputDecoration(labelText: "Enter Result"),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    result = double.tryParse(value);
                  });
                },
              ),
              Row(
                children: [
                  Checkbox(
                    value: isCritical,
                    onChanged: (value) {
                      setState(() {
                        isCritical = value ?? false;
                        if (!isCritical) comment = null;
                      });
                    },
                  ),
                  const Text("Mark as Critical"),
                ],
              ),
              if (isCritical)
                TextField(
                  decoration:
                      const InputDecoration(labelText: "Action/Comment"),
                  onChanged: (value) {
                    setState(() {
                      comment = value;
                    });
                  },
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveLabResult,
                child: const Text('Save Result'),
              ),
              const SizedBox(height: 20),
              Card(
                color: getCardColor(),
                child: ListTile(
                  title: Text("Lab Test: $selectedTest"),
                  subtitle: Text("Result: ${result ?? ''}"),
                  trailing: isCritical
                      ? Icon(Icons.warning, color: Colors.red)
                      : Icon(Icons.check, color: Colors.green),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
