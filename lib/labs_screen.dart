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

  @override
  void initState() {
    super.initState();
    labsRef = FirebaseFirestore.instance
        .collection('departments')
        .doc('NICU') // or PICU based on the department
        .collection('patients')
        .doc(widget.patientId)
        .collection('labs');
  }

  Future<void> _addNewLabTest() async {
    String labName = '';
    double result = 0;
    bool isCritical = false;
    String actionTaken = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Lab Test'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Lab Test Name'),
              onChanged: (value) => labName = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Result'),
              keyboardType: TextInputType.number,
              onChanged: (value) => result = double.parse(value),
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
                decoration: const InputDecoration(labelText: 'Action Taken'),
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
      ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewLabTest, // Button in the upper area
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            _addNewLabTest, // Floating action button for adding lab tests
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
                    title: Text(labName,
                        style: TextStyle(fontWeight: FontWeight.bold)),
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
                          final actionTaken = resultData['actionTaken'];

                          return DataRow(cells: [
                            DataCell(Text(result.toString())),
                            DataCell(
                                Text('${date.day}-${date.month}-${date.year}')),
                            DataCell(Text(isCritical ? 'Yes' : 'No')),
                            DataCell(Text(actionTaken ?? '')),
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
