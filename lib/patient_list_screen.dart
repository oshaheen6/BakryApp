import 'package:bakryapp/patient_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bakryapp/all_medication.dart';
import 'package:bakryapp/discharge_patients.dart';
import 'package:bakryapp/labs_screen.dart';
import 'package:bakryapp/notes_todo_screen.dart';
import 'package:bakryapp/tpn_screen.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import '/provider/user_provider.dart';

class PatientListScreen extends StatefulWidget {
  @override
  _PatientListScreenState createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  late Box localDatabase;

  @override
  void initState() {
    super.initState();
    _initializeLocalDatabase();
  }

  Future<void> _initializeLocalDatabase() async {
    localDatabase = await Hive.openBox('patient_data');
    await _fetchAndCacheData(); // Fetch data when the app starts
  }

  Future<void> _fetchAndCacheData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final department = userProvider.department;

    final CollectionReference patientsRef = FirebaseFirestore.instance
        .collection('departments')
        .doc(department)
        .collection('patients');

      final snapshot =
          await patientsRef.where('state', isEqualTo: 'current').get();

      final postnatalAge = currentDate.difference(birthDate).inDays;
      final gestationAge = (gestationWeeksAtBirth * 7) + postnatalAge;

      return {
        'gestationAge': gestationAge,
        'postnatalAge': postnatalAge,
      };
    }

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
                    title: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PatientInfoScreen(
                              patientId: patientId,
                            department: Provider.of<UserProvider>(context, listen: false).department!,
                          ),
                                ),
                              );
                            },
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
