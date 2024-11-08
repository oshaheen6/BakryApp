import 'package:bakryapp/tpn_detailed.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TpnScreen extends StatelessWidget {
  final String patientId;
  TpnScreen({required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TPN Parameters')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('patients')
            .doc(patientId)
            .collection('tpnParameters')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          final dates = snapshot.data!.docs;
          return ListView.builder(
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final dateDoc = dates[index];
              final date = dateDoc.id; // Document ID as date
              return ListTile(
                title: Text('Date: $date'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TpnDetailScreen(
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
