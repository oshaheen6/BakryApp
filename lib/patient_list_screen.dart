import 'package:bakryapp/patient_info_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bakryapp/all_medication.dart';
import 'package:bakryapp/discharge_patients.dart';
import 'package:bakryapp/labs_screen.dart';
import 'package:bakryapp/notes_todo_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:bakryapp/tpn_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/provider/user_provider.dart';

class PatientListScreen extends StatefulWidget {
  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  String? formattedString;
  @override
  void initState() {
    loadLastFetchedTime();
    updateFetch();
    super.initState();
  }

  Future<void> updateFetch() async {
    try {
      // Simulate fetching data from Firestore
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // No internet connection; do not fetch or update
        print('No internet connection. Using last fetched time.');
        return;
      }
      await FirebaseFirestore.instance.collection('departments').get();

      // Capture the actual fetch time
      DateTime fetchTime = DateTime.now();
      String formattedTime =
          fetchTime.toString().split(' ')[1].substring(0, 5); // HH:mm
      String formattedDate = fetchTime.toString().split(' ')[0]; // YYYY-MM-DD
      formattedString = '$formattedDate $formattedTime';

      // Save the formattedString to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastFetchedTime', formattedString!);

      // Update the UI
      setState(() {});
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> loadLastFetchedTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      formattedString =
          prefs.getString('lastFetchedTime') ?? 'No data fetched yet';
      print(formattedString);
    });
  }

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
                    title: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PatientInfoScreen(
                              patientId: patientId,
                              department: department!,
                            ),
                          ),
                        );
                      },
                      child: AgeAndButtons(
                          patientName: patientName, patient: patient),
                    ),
                    childrenPadding:
                        const EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      OverflowBar(
                        alignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Fetched on: $formattedString',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
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
                                borderRadius: BorderRadius.circular(10),
                              ),
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
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotesTodoScreen(
                                      theDepartment: department!,
                                      patientId: patientId),
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
                            return const CircularProgressIndicator();
                          } else if (medSnapshot.hasData) {
                            List<QueryDocumentSnapshot> medications =
                                medSnapshot.data!.docs;

                            return Column(
                              children: medications.map((medDoc) {
                                return StreamBuilder(
                                  stream: medDoc.reference
                                      .collection('daily_entries')
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot>
                                          dailySnapshot) {
                                    if (dailySnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else if (dailySnapshot.hasData) {
                                      final count =
                                          dailySnapshot.data!.docs.length;

                                      if (count > 0) {
                                        final dailyEntry =
                                            dailySnapshot.data!.docs.first;
                                        final drugName = medDoc.id;
                                        final dose = dailyEntry['dose(number)'];
                                        final doseUnit =
                                            dailyEntry['dose(unit)'];
                                        final regimen = dailyEntry['regimen'];
                                        final amounts = dailyEntry['amounts'];

                                        return ListTile(
                                          title: Text(
                                            drugName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Dose: $dose $doseUnit, ($amounts ml) every: $regimen',
                                              ),
                                            ],
                                          ),
                                          trailing: Text(
                                            'No. of days: $count',
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                        );
                                      } else {
                                        return const Center(
                                          child: Text(
                                              'No daily entries available.'),
                                        );
                                      }
                                    } else {
                                      return const Center(
                                        child: Text(
                                            'Error fetching daily entries.'),
                                      );
                                    }
                                  },
                                );
                              }).toList(),
                            );
                          } else {
                            return const Center(
                              child:
                                  Text('No current medication data available.'),
                            );
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

class AgeAndButtons extends StatelessWidget {
  const AgeAndButtons({
    super.key,
    required this.patientName,
    required this.patient,
  });

  Future<Map<String, dynamic>> calculateAges(
      QueryDocumentSnapshot patient) async {
    try {
      // Cast `data` to a Map
      final Map<String, dynamic> patientData =
          patient.data() as Map<String, dynamic>;

      // Check if `Day of birth` exists
      if (!patientData.containsKey('Day of birth')) {
        return {
          'gestationAge': 'N/A',
          'postnatalAge': 'No birth day available'
        };
      }

      // Retrieve `Day of birth` and `Gestational age`
      final dob = patientData['Day of birth'];
      final gestationWeeksAtBirth = patientData['Gestational age'] ?? 'N/A';

      // Convert to DateTime if necessary
      DateTime birthDate;
      if (dob is Timestamp) {
        birthDate = dob.toDate();
      } else if (dob is String) {
        // Parse the string to DateTime
        birthDate = DateTime.parse(dob);
      } else {
        throw 'Unsupported `Day of birth` format';
      }

      // Calculate ages
      final currentDate = DateTime.now();
      final postnatalAge = currentDate.difference(birthDate).inDays;

      String getPostnatalAge(DateTime birthDate) {
        final totalDays = postnatalAge;
        if (totalDays < 30) {
          return '$totalDays day${totalDays == 1 ? '' : 's'}';
        }

        final months = (totalDays / 30).floor();
        final days = totalDays % 30;

        if (months < 12) {
          return '$months month${months == 1 ? '' : 's'}${days > 0 ? ' and $days day${days == 1 ? '' : 's'}' : ''}';
        }

        final years = (months / 12).floor();
        final remainingMonths = months % 12;

        return '$years year${years == 1 ? '' : 's'}'
            '${remainingMonths > 0 ? ', $remainingMonths month${remainingMonths == 1 ? '' : 's'}' : ''}'
            '${days > 0 ? ' and $days day${days == 1 ? '' : 's'}' : ''}';
      }

      return {
        'gestationAge': gestationWeeksAtBirth,
        'postnatalAge': getPostnatalAge(birthDate),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating ages: $e');
      }
      return {'gestationAge': 'N/A', 'postnatalAge': 'Error calculating age'};
    }
  }
  // The rest of your widget's build method remains the same...

  final dynamic patientName;
  final QueryDocumentSnapshot<Object?> patient;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          patientName,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        FutureBuilder(
          future: calculateAges(patient),
          builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Calculating ages...');
            } else if (snapshot.hasError) {
              return const Text('Error calculating ages.');
            } else if (snapshot.hasData) {
              final ages = snapshot.data!;
              final postnatalAge = ages['postnatalAge'];
              final gestationAge = ages['gestationAge'];

              if (postnatalAge == 'No birth day available') {
                return const Text('No birth day available');
              } else if (postnatalAge == 'Error calculating age') {
                return const Text('Error calculating age');
              } else {
                return Text(
                  'Gestation Age: $gestationAge, Postnatal Age: $postnatalAge',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              }
            } else {
              return const Text('Age data unavailable');
            }
          },
        ),
      ],
    );
  }
}
