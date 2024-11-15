import 'package:bakryapp/provider/user_provider.dart';
import 'package:bakryapp/tpn_detailed.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class TpnScreen extends StatelessWidget {
  final String patientId;
  TpnScreen({required this.patientId});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final department = userProvider.department;

    return Scaffold(
      appBar: AppBar(title: const Text('TPN Parameters')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('departments')
            .doc(department)
            .collection('patients')
            .doc(patientId)
            .collection('tpnParameters')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final tpnDocs = snapshot.data!.docs;
          if (tpnDocs.isEmpty) {
            return const Center(child: Text('No TPN data available.'));
          }

          return ListView.builder(
            itemCount: tpnDocs.length,
            itemBuilder: (context, index) {
              final dateDoc = tpnDocs[index];
              final date = dateDoc.id; // Document ID as the date

              return ListTile(
                title: Text('Date: $date'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TpnDetailScreen(
                      theDepartment: department!,
                      patientId: patientId,
                      date: date,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
