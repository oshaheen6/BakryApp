import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LabsScreen extends StatefulWidget {
  final String patientId;
  LabsScreen({required this.patientId});

  @override
  _LabsScreenState createState() => _LabsScreenState();
}

class _LabsScreenState extends State<LabsScreen> {
  CollectionReference? labsRef;

  final Map<String, List<Map<String, dynamic>>> labCategories = {
    'Electrolytes': [
      {
        'name': 'Na',
        'NICU': [135, 145],
        'PICU': [135, 145]
      },
      {
        'name': 'K',
        'NICU': [3.5, 6],
        'PICU': [3.5, 6]
      },
    ],
    'Liver Function': [
      {
        'name': 'ALT',
        'NICU': [10, 40],
        'PICU': [10, 40]
      },
    ],
    'Kidney Function': [
      {
        'name': 'Creatinine',
        'NICU': [0.2, 0.9],
        'PICU': [0.2, 0.9]
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    labsRef = FirebaseFirestore.instance
        .collection('departments')
        .doc('NICU') // Adjust dynamically if needed
        .collection('patients')
        .doc(widget.patientId)
        .collection('labs');
  }

  Future<void> _showLabTestSelection() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: labCategories.entries.map((category) {
            return ExpansionTile(
              title: Text(category.key),
              children: category.value.map((lab) {
                return ListTile(
                  title: Text(lab['name']),
                  onTap: () {
                    Navigator.pop(context);
                    _addNewLabTest(lab['name'], lab);
                  },
                );
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _addNewLabTest(
      String labName, Map<String, dynamic> labDetails) async {
    double result = 0;
    bool isCritical = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add $labName Test'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Result'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      result = double.tryParse(value) ?? 0;
                      setState(() {});
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Mark as Critical'),
                    value: isCritical,
                    onChanged: (value) {
                      setState(() {
                        isCritical = value ?? false;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    labsRef?.doc(labName).set({
                      'results': FieldValue.arrayUnion([
                        {
                          'result': result,
                          'date': DateTime.now(),
                          'isCritical': isCritical,
                          'actionTaken': '',
                        }
                      ])
                    }, SetOptions(merge: true));
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String?> _editActionTakenDialog(String initialText) async {
    final controller = TextEditingController(text: initialText);

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Action Taken'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Action Taken'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Color _getBackgroundColor(Map<String, dynamic> resultData) {
    if (resultData['isCritical'] == true) {
      return resultData['actionTaken']?.isNotEmpty == true
          ? Colors.orange.shade200
          : Colors.red.shade200;
    }
    return Colors.green.shade200;
  }

  Widget _buildActionTakenWidget(
      Map<String, dynamic> resultData, String labName) {
    bool hasAction = resultData['actionTaken']?.isNotEmpty == true;

    return hasAction
        ? GestureDetector(
            onTap: () async {
              final updatedAction =
                  await _editActionTakenDialog(resultData['actionTaken']);
              if (updatedAction != null) {
                resultData['actionTaken'] = updatedAction;
                labsRef?.doc(labName).update({
                  'results': FieldValue.arrayUnion([resultData])
                });
              }
            },
            child: Text(
              resultData['actionTaken'],
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          )
        : CheckboxListTile(
            title: const Text('Add Action Taken'),
            value: false,
            onChanged: (value) async {
              if (value == true) {
                final newAction = await _editActionTakenDialog('');
                if (newAction != null && newAction.isNotEmpty) {
                  resultData['actionTaken'] = newAction;
                  labsRef?.doc(labName).update({
                    'results': FieldValue.arrayUnion([resultData])
                  });
                }
              }
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Results'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showLabTestSelection,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: labsRef?.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final labs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: labs.length,
              itemBuilder: (context, index) {
                final labDoc = labs[index];
                final labName = labDoc.id;
                final results = labDoc['results'] as List<dynamic>;

                return Card(
                  color: _getBackgroundColor(results.last),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ExpansionTile(
                    title: Text(
                      labName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      DataTable(
                        columns: const [
                          DataColumn(label: Text('Result')),
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Critical')),
                          DataColumn(label: Text('Action Taken')),
                        ],
                        rows: results.map<DataRow>((resultData) {
                          final result = resultData['result'];
                          final date =
                              (resultData['date'] as Timestamp).toDate();
                          final isCritical = resultData['isCritical'];

                          return DataRow(cells: [
                            DataCell(Text(result.toString())),
                            DataCell(
                                Text('${date.day}-${date.month}-${date.year}')),
                            DataCell(Text(isCritical ? 'Yes' : 'No')),
                            DataCell(
                                _buildActionTakenWidget(resultData, labName)),
                          ]);
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(
                child: Text('No lab data available. Press "+" to add.'));
          }
        },
      ),
    );
  }
}
