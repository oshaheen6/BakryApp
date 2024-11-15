import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bakryapp/all_medication.dart';
import 'package:bakryapp/discharge_patients.dart';
import 'package:bakryapp/labs_screen.dart';
import 'package:bakryapp/notes_todo_screen.dart';
import 'package:bakryapp/tpn_screen.dart';
import 'package:provider/provider.dart';
import '/provider/user_provider.dart';

class PatientListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final department = userProvider.department;

    final CollectionReference patientsRef = FirebaseFirestore.instance
        .collection('departments')
        .doc(department)
        .collection('patients');

    Future<bool> checkForTpnParameters(String patientId) async {
      final tpnRef = FirebaseFirestore.instance
          .collection('departments')
          .doc(department)
          .collection('patients')
          .doc(patientId)
          .collection('tpnParameters');
      final tpnSnapshot = await tpnRef.get();
      return tpnSnapshot.docs.isNotEmpty;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Current Patients in $department'),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DischargedPatientsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: patientsRef.where('state', isEqualTo: 'current').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            List<QueryDocumentSnapshot> patients = snapshot.data!.docs;

            return ListView.builder(
              itemCount: patients.length,
              padding: const EdgeInsets.all(12.0),
              itemBuilder: (context, index) {
                final patient = patients[index];
                final patientName = patient['patientName'];
                final patientId = patient.id;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 4,
                  child: ExpansionTile(
                    title: Text(
                      patientName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    childrenPadding:
                        const EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      OverflowBar(
                        alignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AllMedicationsScreen(patient: patient),
                                ),
                              );
                            },
                            icon: const Icon(Icons.medical_services_outlined),
                            label: const Text('All Medication'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      LabsScreen(patientId: patientId),
                                ),
                              );
                            },
                            icon: const Icon(Icons.science_outlined),
                            label: const Text('Labs'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NotesTodoScreen(patientId: patientId),
                                ),
                              );
                            },
                            icon: const Icon(Icons.notes_outlined),
                            label: const Text('Notes & Todo'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              bool hasTpn =
                                  await checkForTpnParameters(patientId);
                              if (hasTpn) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TpnScreen(patientId: patientId),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'No TPN data available for this patient.')),
                                );
                              }
                            },
                            icon: const Icon(Icons.medical_services_outlined),
                            label: const Text('TPN'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                      StreamBuilder(
                        stream: patient.reference
                            .collection('medication')
                            .where('state', isEqualTo: 'still on')
                            .snapshots(),
                        builder: (context,
                            AsyncSnapshot<QuerySnapshot> medSnapshot) {
                          if (medSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (medSnapshot.hasError) {
                            return Center(
                                child: Text('Error: ${medSnapshot.error}'));
                          } else if (medSnapshot.hasData &&
                              medSnapshot.data!.docs.isNotEmpty) {
                            List<QueryDocumentSnapshot> medications =
                                medSnapshot.data!.docs;

                            return Column(
                              children: medications.map((medDoc) {
                                return StreamBuilder(
                                  stream: medDoc.reference
                                      .collection('daily_entries')
                                      .orderBy('date', descending: true)
                                      .limit(1)
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot>
                                          dailySnapshot) {
                                    if (dailySnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else if (dailySnapshot.hasData &&
                                        dailySnapshot.data!.docs.isNotEmpty) {
                                      final dailyEntry =
                                          dailySnapshot.data!.docs.first;
                                      final drugName = medDoc.id;
                                      final dose = dailyEntry['dose(number)'];
                                      final doseUnit = dailyEntry['dose(unit)'];
                                      final regimen = dailyEntry['regimen'];
                                      final amounts = dailyEntry['amounts'];

                                      return ListTile(
                                        title: Text(
                                          drugName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                            'Dose: $dose $doseUnit, ($amounts ml) every: $regimen'),
                                        trailing: Text(
                                          'no. of days: $count',
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                      );
                                    } else {
                                      return const Center(
                                          child: Text(
                                              'No current medication data available.'));
                                    }
                                  },
                                );
                              }).toList(), // Convert the mapped iterable to a list
                            );
                          } else {
                            return const Center(
                                child: Text(
                                    'No current medication data available.'));
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No patient data available.'));
          }
        },
      ),
    );
  }
}
