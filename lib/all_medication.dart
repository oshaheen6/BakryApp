import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllMedicationsScreen extends StatelessWidget {
  final QueryDocumentSnapshot patient;

  AllMedicationsScreen({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Medications')),
      body: StreamBuilder(
        stream: patient.reference.collection('medication').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> medSnapshot) {
          if (medSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (medSnapshot.hasError) {
            return Center(child: Text('Error: ${medSnapshot.error}'));
          } else if (medSnapshot.hasData && medSnapshot.data!.docs.isNotEmpty) {
            List<QueryDocumentSnapshot> medications = medSnapshot.data!.docs;

            return ListView(
              children: medications.map((medDoc) {
                final date = medDoc.id;
                final drugName = medDoc['drugName'];
                final dose = medDoc['dose(number)'];
                final doseUnit = medDoc['dose(unit)'];
                final regimen = medDoc['regimen'];
                final amounts = medDoc['amounts'];
                final state = medDoc['state'];

                return ListTile(
                  title: Text(drugName),
                  subtitle: Text(
                      'Dose: $dose $doseUnit, ($amounts ml) every: $regimen'),
                  trailing: Text('Date: $date - State: $state'),
                );
              }).toList(),
            );
          } else {
            return const Center(child: Text('No medication data available.'));
          }
        },
      ),
    );
  }
}
