import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TpnDetailScreen extends StatelessWidget {
  final String patientId;
  final String theDepartment;
  final String date;

  TpnDetailScreen(
      {required this.patientId,
      required this.date,
      required this.theDepartment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TPN Parameters on $date')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('departments')
            .doc(theDepartment)
            .collection('patients')
            .doc(patientId)
            .collection('tpnParameters')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          final parameters = snapshot.data!.docs;
          return ListView(
            children: parameters.map((param) {
              return ListTile(
                title: Text(param.id),
                subtitle: Text(param.data().toString()),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
