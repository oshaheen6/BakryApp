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
                final drugName =
                    medDoc.id; // Medication name is the document ID

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

                            return Column(
                              children: dailyEntries.map((dailyDoc) {
                                final date =
                                    dailyDoc.id; // Document ID as the date
                                final data =
                                    dailyDoc.data() as Map<String, dynamic>;
                                final dose = data['dose'] ?? 'N/A';
                                final doseUnit = data['unit'] ?? 'N/A';
                                final regimen = data['regimen'] ?? 'N/A';
                                final amounts = data['amounts'] ?? 'N/A';
                                final state = data['state'] ?? 'N/A';

                                return ListTile(
                                  title: Text('Date: $date'),
                                  subtitle: Text(
                                      'Dose: $dose $doseUnit, ($amounts ml) every $regimen'),
                                  trailing: Text('State: $state'),
                                );
                              }).toList(),
                            );
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
