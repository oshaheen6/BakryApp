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
      appBar: AppBar(
        title: const Text('TPN Parameters'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('departments')
            .doc(department)
            .collection('patients')
            .doc(patientId)
            .collection('tpnParameters')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No TPN data available.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final tpnDocs = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: tpnDocs.length,
              itemBuilder: (context, index) {
                final dateDoc = tpnDocs[index];
                final date = dateDoc['date'] ??
                    'Unknown'; // Use the document ID as the date

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      'Date: $date',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
