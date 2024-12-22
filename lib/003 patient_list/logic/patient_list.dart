import 'package:bakryapp/discharge_patients.dart';
import 'package:bakryapp/patient_info_screen.dart';
import 'package:bakryapp/tpn_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../cubit/patient_list_state.dart';
import '../cubit/patient_list_cubit.dart';

class PatientListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace with the appropriate provider or state management call
    final department = "NICU"; // Example, replace with actual department logic

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
      body: BlocProvider(
        create: (_) => PatientCubit(firestore: FirebaseFirestore.instance)
          ..fetchPatients(department),
        child: BlocBuilder<PatientCubit, PatientState>(
          builder: (context, state) {
            if (state is PatientLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PatientError) {
              return Center(child: Text('Error: ${state.errorMessage}'));
            } else if (state is PatientLoaded) {
              final patients = state.patients;

              if (patients.isEmpty) {
                return const Center(child: Text('No patient data available.'));
              }

              return ListView.builder(
                itemCount: patients.length,
                padding: const EdgeInsets.all(12.0),
                itemBuilder: (context, index) {
                  final patient = patients[index];
                  final patientName = patient['patientName'];
                  final patientId = patient.id;

                  return PatientCard(
                    patient: patient,
                    department: department,
                    patientName: patientName,
                    patientId: patientId,
                  );
                },
              );
            }

            return const Center(child: Text('No patient data available.'));
          },
        ),
      ),
    );
  }
}

class PatientCard extends StatelessWidget {
  final QueryDocumentSnapshot patient;
  final String department;
  final String patientName;
  final String patientId;

  const PatientCard({
    super.key,
    required this.patient,
    required this.department,
    required this.patientName,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    final patientCubit = context.read<PatientCubit>();

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
                  department: department,
                ),
              ),
            );
          },
          child: Text(patientName),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              final hasTpn = await patientCubit.checkForTpnParameters(
                department,
                patientId,
              );
              if (hasTpn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TpnScreen(patientId: patientId),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No TPN data available for this patient.'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.medical_services_outlined),
            label: const Text('TPN'),
          ),
          MedicationList(patient: patient),
        ],
      ),
    );
  }
}

class MedicationList extends StatelessWidget {
  final QueryDocumentSnapshot patient;

  const MedicationList({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: patient.reference
          .collection('medication')
          .where('state', isEqualTo: 'still on')
          .snapshots(),
      builder: (context, medSnapshot) {
        if (medSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (medSnapshot.hasError) {
          return const Center(child: Text('Error fetching medications.'));
        } else if (medSnapshot.hasData) {
          final medications = medSnapshot.data!.docs;

          if (medications.isEmpty) {
            return const Text('No current medication data available.');
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final medDoc = medications[index];
              final drugName = medDoc.id;

              return MedicationDetails(medication: medDoc, drugName: drugName);
            },
          );
        } else {
          return const Text('No current medication data available.');
        }
      },
    );
  }
}

class MedicationDetails extends StatelessWidget {
  final QueryDocumentSnapshot medication;
  final String drugName;

  const MedicationDetails({
    super.key,
    required this.medication,
    required this.drugName,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: medication.reference.collection('daily_entries').snapshots(),
      builder: (context, dailySnapshot) {
        if (dailySnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (dailySnapshot.hasError) {
          return const Center(child: Text('Error fetching daily entries.'));
        } else if (dailySnapshot.hasData) {
          final dailyEntries = dailySnapshot.data!.docs;

          if (dailyEntries.isEmpty) {
            return const Text('No daily entries available.');
          }

          final dailyEntry = dailyEntries.first;
          final dose = dailyEntry['dose(number)'];
          final doseUnit = dailyEntry['dose(unit)'];
          final regimen = dailyEntry['regimen'];
          final amounts = dailyEntry['amounts'];

          return ListTile(
            title: Text(
              drugName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Dose: $dose $doseUnit, ($amounts ml) every: $regimen',
            ),
          );
        } else {
          return const Text('No daily entries available.');
        }
      },
    );
  }
}
