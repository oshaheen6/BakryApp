import 'package:bakryapp/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class LabsScreen extends StatefulWidget {
  final String patientId;
  LabsScreen({required this.patientId});

  @override
  _LabsScreenState createState() => _LabsScreenState();
}

class _LabsScreenState extends State<LabsScreen> {
  CollectionReference? labsRef;
  final List<String> labTestNames = [
    'Na',
    'K',
    'Mg',
    'Ph',
    'Ca',
    'albumin',
    'CRP',
    'Hemoglobin',
    'WBC',
    'RBS',
    'Direct bilirubin',
    'Total bilirubin',
    'ALT',
    'AST',
    'Urea',
    'T.protein'
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _showLabTestSelection() async {
    // Show modal bottom sheet with grid of buttons
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Adjust for layout
            childAspectRatio: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: labTestNames.length,
          itemBuilder: (context, index) {
            final labName = labTestNames[index];
            return ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the modal
                _addNewLabTest(labName);
              },
              child: Text(labName),
            );
          },
        );
      },
    );
  }

  Future<void> _addNewLabTest(String labName) async {
    double result = 0;
    bool isCritical = false;
    String actionTaken = '';

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
                    onChanged: (value) => result = double.tryParse(value) ?? 0,
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
                  if (isCritical)
                    TextField(
                      decoration:
                          const InputDecoration(labelText: 'Action Taken'),
                      onChanged: (value) => actionTaken = value,
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
                          'actionTaken': actionTaken,
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
                          final actionTaken = resultData['actionTaken'] ?? '';

                          return DataRow(cells: [
                            DataCell(Text(result.toString())),
                            DataCell(
                                Text('${date.day}-${date.month}-${date.year}')),
                            DataCell(Text(isCritical ? 'Yes' : 'No')),
                            DataCell(Text(actionTaken)),
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
