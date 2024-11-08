import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DischargedPatientsScreen extends StatelessWidget {
  final CollectionReference patientsRef =
      FirebaseFirestore.instance.collection('patients');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discharged Patients')),
      body: StreamBuilder(
        stream: patientsRef.where('state', isEqualTo: 'discharged').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            List<QueryDocumentSnapshot> patients = snapshot.data!.docs;

            return ListView.builder(
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];
                final patientName = patient['patientName'];

                return ListTile(
                  title: Text(patientName),
                  subtitle: const Text('Discharged'),
                );
              },
            );
          } else {
            return const Center(
                child: Text('No discharged patient data available.'));
          }
        },
      ),
    );
  }
}
