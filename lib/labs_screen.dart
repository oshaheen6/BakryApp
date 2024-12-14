import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '/provider/user_provider.dart';

class LabsScreen extends StatefulWidget {
  final String patientId;
  LabsScreen({required this.patientId});

  @override
  _LabsScreenState createState() => _LabsScreenState();
}

class _LabsScreenState extends State<LabsScreen> {
  CollectionReference? labsRef;

  final Map<String, List<Map<String, dynamic>>> labCategories = {
    'CBC': [
      {
        'name': 'RBC',
        'NICU': [4.1, 5.7], // million/μL
        'PICU': [4.5, 5.9]
      },
      {
        'name': 'Hb',
        'NICU': [14, 20], // g/dL
        'PICU': [11.5, 15.5]
      },
      {
        'name': 'WBC',
        'NICU': [9, 30], // 10^3/μL
        'PICU': [4.5, 11]
      },
      {
        'name': 'Plt',
        'NICU': [150, 450], // 10^3/μL
        'PICU': [150, 400]
      },
      {
        'name': 'Staff',
        'NICU': [0, 5], // %
        'PICU': [0, 5]
      },
      {
        'name': 'Seg',
        'NICU': [40, 70], // %
        'PICU': [40, 70]
      },
      {
        'name': 'Retics',
        'NICU': [3, 7], // %
        'PICU': [0.5, 1.5]
      },
    ],
    'Electrolytes': [
      {
        'name': 'Na',
        'NICU': [135, 145], // mmol/L
        'PICU': [135, 145]
      },
      {
        'name': 'K',
        'NICU': [3.5, 6], // mmol/L
        'PICU': [3.5, 5]
      },
      {
        'name': 'Ca+',
        'NICU': [8.5, 10.5], // mg/dL
        'PICU': [8.5, 10.5]
      },
      {
        'name': 'Ion Ca++',
        'NICU': [1.1, 1.3], // mmol/L
        'PICU': [1.1, 1.3]
      },
      {
        'name': 'Mg',
        'NICU': [1.6, 2.4], // mg/dL
        'PICU': [1.6, 2.4]
      },
      {
        'name': 'Ph',
        'NICU': [4.5, 7.5], // mg/dL
        'PICU': [3, 4.5]
      },
    ],
    'Liver Function': [
      {
        'name': 'ALT',
        'NICU': [5, 25], // U/L
        'PICU': [10, 40]
      },
      {
        'name': 'AST',
        'NICU': [15, 45], // U/L
        'PICU': [10, 40]
      },
      {
        'name': 'Bilirubin',
        'NICU': [0.1, 1], // mg/dL
        'PICU': [0.1, 1.2]
      },
      {
        'name': 'T.Bilirubin',
        'NICU': [0.1, 12], // mg/dL (neonatal range)
        'PICU': [0.1, 1.2]
      },
    ],
    'Kidney Function': [
      {
        'name': 'Creatinine',
        'NICU': [0.2, 0.9], // mg/dL
        'PICU': [0.5, 1.2]
      },
      {
        'name': 'Urea',
        'NICU': [7, 20], // mg/dL
        'PICU': [8, 25]
      },
      {
        'name': 'BUN',
        'NICU': [2.5, 7.1], // mmol/L
        'PICU': [2.5, 6.4]
      },
    ],
    'Clotting': [
      {
        'name': 'PT',
        'NICU': [11, 13.5], // seconds
        'PICU': [11, 13.5]
      },
      {
        'name': 'PTT',
        'NICU': [25, 35], // seconds
        'PICU': [25, 35]
      },
      {
        'name': 'APTT',
        'NICU': [30, 40], // seconds
        'PICU': [30, 40]
      },
      {
        'name': 'Fibrinogen',
        'NICU': [150, 400], // mg/dL
        'PICU': [150, 400]
      },
      {
        'name': 'INR',
        'NICU': [0.8, 1.2], // ratio
        'PICU': [0.8, 1.2]
      },
    ],
  };

  @override
  void initState() {
    super.initState();
  }

  void _editLabResult(
      String labName, List<dynamic> results, int resultIndex) async {
    // Get the specific result to edit
    Map<String, dynamic> resultData = results[resultIndex];

    TextEditingController resultController = TextEditingController(
      text: resultData['result'].toString(),
    );
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Lab Result'),
          content: TextField(
            controller: resultController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Result'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedResult = double.tryParse(resultController.text);
                if (updatedResult != null) {
                  // Create a copy of the result data with updated value
                  Map<String, dynamic> updatedResultData = Map.from(resultData);
                  updatedResultData['result'] = updatedResult;

                  // Remove the old result and add the updated result
                  labsRef?.doc(labName).update({
                    'results': FieldValue.arrayRemove([resultData])
                  }).then((_) {
                    labsRef?.doc(labName).update({
                      'results': FieldValue.arrayUnion([updatedResultData])
                    });
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteLabResult(
      String labName, List<dynamic> results, int resultIndex) {
    // Get the specific result to delete
    Map<String, dynamic> resultData = results[resultIndex];

    labsRef?.doc(labName).update({
      'results': FieldValue.arrayRemove([resultData])
    });
  }

  Future<void> _showLabTestSelection(String? department) async {
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
                    _addNewLabTest(department!, lab['name'], lab);
                  },
                );
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _addNewLabTest(String department, String labName,
      Map<String, dynamic> labDetails) async {
    double result = 0;
    bool isCritical = false;
    DateTime selectedDate = DateTime.now(); // Default to today

    // Retrieve the ranges for the selected department (NICU or PICU)
    final lab = labCategories.values
        .expand((category) => category)
        .firstWhere((lab) => lab['name'] == labName);
    final range = lab[department]; // Get the range for the selected department

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Check if the result is within the normal range for the department
            bool isWithinRange = result >= range[0] && result <= range[1];

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
                      setState(() {}); // Update the dialog with the new result
                    },
                  ),
                  const SizedBox(height: 10),
                  if (result > 0) ...[
                    Text(
                      isWithinRange
                          ? 'Result is within normal range for $department.'
                          : 'Result is outside normal range for $department.',
                      style: TextStyle(
                        color: isWithinRange ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Date:'),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate:
                                DateTime(2000), // Earliest selectable date
                            lastDate: DateTime.now(), // Latest selectable date
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate =
                                  pickedDate; // Update the selected date
                            });
                          }
                        },
                        child: Text(
                          "${selectedDate.toLocal()}"
                              .split(' ')[0], // Show the date
                        ),
                      ),
                    ],
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
                    // Add the lab test result to Firestore
                    labsRef?.doc(labName).set({
                      'results': FieldValue.arrayUnion([
                        {
                          'result': result,
                          'date': selectedDate, // Use the selected date
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

  Color _getBackgroundColor(Map<String, dynamic> resultData) {
    if (resultData['isCritical'] == true) {
      return resultData['actionTaken']?.isNotEmpty == true
          ? Colors.orange.shade200
          : Colors.red.shade200;
    }
    return Colors.green.shade200;
  }

  Widget _buildActionTakenWidget(
      Map<String, dynamic> resultData, String labName, int resultIndex) {
    bool hasAction = resultData['actionTaken']?.isNotEmpty == true;

    return hasAction
        ? GestureDetector(
            onTap: () {
              _editActionTaken(resultData, labName, resultIndex);
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
            onChanged: (value) {
              if (value == true) {
                _editActionTaken(resultData, labName, resultIndex);
              }
            },
          );
  }

  Future<void> _editActionTaken(
      Map<String, dynamic> resultData, String labName, int resultIndex) async {
    String actionTaken = resultData['actionTaken'] ?? '';
    TextEditingController actionController = TextEditingController(
      text: actionTaken,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Action Taken for Critical Result'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Action Taken'),
            controller: actionController,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Create a new map with the updated action
                Map<String, dynamic> updatedResultData = Map.from(resultData);
                updatedResultData['actionTaken'] = actionController.text;

                // Update the specific result in the array
                labsRef?.doc(labName).update({
                  'results': FieldValue.arrayRemove([resultData])
                }).then((_) {
                  labsRef?.doc(labName).update({
                    'results': FieldValue.arrayUnion([updatedResultData])
                  });
                });

                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final department = userProvider.department;

    labsRef = FirebaseFirestore.instance
        .collection('departments')
        .doc(department) // Adjust to be dynamic if needed
        .collection('patients')
        .doc(widget.patientId)
        .collection('labs');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Results'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showLabTestSelection(department);
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: labsRef?.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Handle all possible connection states
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Check if data is null or empty
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No lab data available. Press "+" to add.'),
            );
          }

          // Safe access to labs
          final labs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: labs.length,
            itemBuilder: (context, index) {
              final labDoc = labs[index];
              final labName = labDoc.id;
              final results = labDoc['results'] as List<dynamic>;

              return Card(
                color: results.isNotEmpty
                    ? _getBackgroundColor(results.last)
                    : Colors.green.shade200,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    // Row with lab name and popup menu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            labName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.0),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'Delete') {
                              // Delete the entire lab test
                              labsRef?.doc(labName).delete();
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              const PopupMenuItem(
                                value: 'Delete',
                                child: Text('Delete Lab Test'),
                              ),
                            ];
                          },
                        ),
                      ],
                    ),

                    // Existing ExpansionTile and DataTable
                    ExpansionTile(
                      title: const Text(
                        'Results',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        DataTable(
                          columns: const [
                            DataColumn(label: Text('Result')),
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Critical')),
                            DataColumn(label: Text('Action')),
                          ],
                          rows: results.map<DataRow>((resultData) {
                            final result = resultData['result'];
                            final date =
                                (resultData['date'] as Timestamp).toDate();
                            final isCritical =
                                resultData['isCritical'] ?? false;
                            final int resultIndex = results.indexOf(resultData);

                            return DataRow(
                              cells: [
                                DataCell(Text(result.toString())),
                                DataCell(Text(
                                    '${date.day}-${date.month}-${date.year}')),
                                DataCell(Text(isCritical ? 'Yes' : 'No')),
                                DataCell(
                                  Row(
                                    children: [
                                      PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'Edit') {
                                            _editLabResult(
                                                labName, results, resultIndex);
                                          } else if (value == 'Delete') {
                                            _deleteLabResult(
                                                labName, results, resultIndex);
                                          }
                                        },
                                        itemBuilder: (BuildContext context) {
                                          return [
                                            const PopupMenuItem(
                                              value: 'Edit',
                                              child: Text('Edit Result'),
                                            ),
                                            const PopupMenuItem(
                                              value: 'Delete',
                                              child: Text('Delete Result'),
                                            ),
                                          ];
                                        },
                                        child: const Icon(Icons.more_vert),
                                      ),

                                      // Action Taken only for Critical Results
                                      if (isCritical) ...[
                                        const SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () {
                                            _editActionTaken(resultData,
                                                labName, resultIndex);
                                          },
                                          child: Text(
                                            resultData['actionTaken']
                                                        ?.isNotEmpty ==
                                                    true
                                                ? resultData['actionTaken']
                                                : 'Add Action',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
