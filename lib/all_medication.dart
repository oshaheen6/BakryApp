import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllMedicationsScreen extends StatelessWidget {
  final QueryDocumentSnapshot patient;

  AllMedicationsScreen({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Medications')),
      body: StreamBuilder<QuerySnapshot>(
        stream: patient.reference.collection('medication').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> medSnapshot) {
          if (medSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (medSnapshot.hasError) {
            return Center(child: Text('Error: ${medSnapshot.error}'));
          } else if (medSnapshot.hasData && medSnapshot.data!.docs.isNotEmpty) {
            List<QueryDocumentSnapshot> medications = medSnapshot.data!.docs;

            return ListView.builder(
              itemCount: medications.length,
              itemBuilder: (context, index) {
                final medDoc = medications[index];
                final drugName = medDoc.id;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ExpansionTile(
                    title: Text(
                      drugName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: medDoc.reference
                            .collection('daily_entries')
                            .orderBy(
                                'date') // Ensure entries are sorted by date
                            .snapshots(),
                        builder: (context,
                            AsyncSnapshot<QuerySnapshot> dailySnapshot) {
                          if (dailySnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            );
                          } else if (dailySnapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text('Error: ${dailySnapshot.error}'),
                            );
                          } else if (dailySnapshot.hasData &&
                              dailySnapshot.data!.docs.isNotEmpty) {
                            List<QueryDocumentSnapshot> dailyEntries =
                                dailySnapshot.data!.docs;

                            List<Widget> doseHistory = [];
                            for (int i = 0; i < dailyEntries.length; i++) {
                              final currentEntry = dailyEntries[i];
                              final currentData =
                                  currentEntry.data() as Map<String, dynamic>;
                              final dose = currentData['dose'] ?? 'N/A';
                              final regimen = currentData['regimen'] ?? 'N/A';
                              final state = currentData['state'] ?? 'active';
                              final date = currentData['date'] ?? 'N/A';

                              String entryText =
                                  'Dose: $dose, Regimen: $regimen (Started on: $date)';
                              if (state == 'stopped') {
                                entryText += '\nStopped on: $date';
                              } else if (i > 0) {
                                // Compare with the previous entry for dose changes
                                final previousEntry = dailyEntries[i - 1];
                                final previousData = previousEntry.data()
                                    as Map<String, dynamic>;
                                final previousDose =
                                    previousData['dose'] ?? 'N/A';

                                if (previousDose != dose) {
                                  entryText =
                                      'Dose: $dose, Regimen: $regimen (Started on: $date)';
                                }
                              }

                              doseHistory.add(ListTile(
                                title: Text(entryText),
                              ));
                            }

                            return Column(children: doseHistory);
                          } else {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No daily entries available.'),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No medication data available.'));
          }
        },
      ),
    );
  }
}
