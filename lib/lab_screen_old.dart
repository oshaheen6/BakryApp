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

  @override
  void initState() {
    super.initState();
  }

  void _editLabResult(String labName, Map<String, dynamic> resultData) async {
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
                  resultData['result'] = updatedResult;
                  labsRef?.doc(labName).update({
                    'results': FieldValue.arrayRemove([resultData])
                  }).then((_) {
                    labsRef?.doc(labName).update({
                      'results': FieldValue.arrayUnion([resultData])
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

  void _deleteLabResult(String labName, Map<String, dynamic> resultData) {
    labsRef?.doc(labName).update({
      'results': FieldValue.arrayRemove([resultData])
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final department = userProvider.department;
    labsRef = FirebaseFirestore.instance
        .collection('departments')
        .doc(department)
        .collection('patients')
        .doc(widget.patientId)
        .collection('labs');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Results'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // Your method for adding a new lab test
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
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      labName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: results.map<Widget>((resultData) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Result: ${resultData['result']}"),
                            Text("Date: ${resultData['date'].toDate()}"),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'Edit') {
                                  _editLabResult(labName, resultData);
                                } else if (value == 'Delete') {
                                  _deleteLabResult(labName, resultData);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'Edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'Delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No lab results available.'));
          }
        },
      ),
    );
  }
}
