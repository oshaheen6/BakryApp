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

            // Separate current and stopped medications
            List<QueryDocumentSnapshot> currentMedications = [];
            List<QueryDocumentSnapshot> stoppedMedications = [];
            for (var medDoc in medications) {
              final state = medDoc['state'] ?? 'active';
              if (state == 'stopped') {
                stoppedMedications.add(medDoc);
              } else {
                currentMedications.add(medDoc);
              }
            }

            return ListView(
              children: [
                ...currentMedications
                    .map((medDoc) => _buildMedicationTile(medDoc, false)),
                ...stoppedMedications
                    .map((medDoc) => _buildMedicationTile(medDoc, true)),
              ],
            );
          } else {
            return const Center(child: Text('No medication data available.'));
          }
        },
      ),
    );
  }

  Widget _buildMedicationTile(QueryDocumentSnapshot medDoc, bool isStopped) {
    final drugName = medDoc.id;

    return Card(
      color: isStopped ? Colors.red[50] : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        title: Text(
          drugName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isStopped ? Colors.red : Colors.black,
          ),
        ),
        subtitle: isStopped
            ? FutureBuilder(
                future: _getStartAndEndDates(medDoc),
                builder:
                    (context, AsyncSnapshot<Map<String, String>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading...');
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final dates = snapshot.data!;
                    return Text(
                        'Started: ${dates['startDate']}, Stopped: ${dates['endDate']}');
                  } else {
                    return const Text('No data available');
                  }
                },
              )
            : FutureBuilder(
                future: _getStartAndEndDates(medDoc),
                builder:
                    (context, AsyncSnapshot<Map<String, String>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading...');
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final dates = snapshot.data!;
                    return Text('Started: ${dates['startDate']}');
                  } else {
                    return const Text('No data available');
                  }
                },
              ),
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: medDoc.reference
                .collection('daily_entries')
                .orderBy('date')
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> dailySnapshot) {
              if (dailySnapshot.connectionState == ConnectionState.waiting) {
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
                  children: dailyEntries.map((entry) {
                    final data = entry.data() as Map<String, dynamic>;
                    final dose = data['dose(number)'] ?? 'N/A';
                    final doseU = data['dose(unit)'] ?? 'N/A';
                    final regimen = data['regimen'] ?? 'N/A';
                    final date = data['date'] ?? 'N/A';

                    return ListTile(
                      title: Text('Dose: $dose $doseU, Regimen: $regimen'),
                      subtitle: Text('Date: $date'),
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
  }

  Future<Map<String, String>> _getStartAndEndDates(
      QueryDocumentSnapshot medDoc) async {
    final dailyEntriesSnapshot = await medDoc.reference
        .collection('daily_entries')
        .orderBy('date')
        .get();

    if (dailyEntriesSnapshot.docs.isNotEmpty) {
      final firstEntry = dailyEntriesSnapshot.docs.first;
      final lastEntry = dailyEntriesSnapshot.docs.last;
      final firstDate = (firstEntry.data() as Map<String, dynamic>)['date'];
      final lastDate = (lastEntry.data() as Map<String, dynamic>)['date'];
      final state = medDoc['state'] ?? 'active';

      return {
        'startDate': firstDate ?? 'N/A',
        'endDate': state == 'stopped' ? lastDate ?? 'N/A' : 'Ongoing',
      };
    }

    return {'startDate': 'N/A', 'endDate': 'N/A'};
  }
}
