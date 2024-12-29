import 'package:bakryapp/admin_screen.dart';
import 'package:bakryapp/bilirubin_screen.dart';
import 'package:bakryapp/calculator_screen.dart';
import 'package:bakryapp/drugs_monograph.dart';
import 'package:bakryapp/login_screen.dart';
import 'package:bakryapp/pediatric_ward_screen.dart';
import 'package:bakryapp/provider/drug_monograph_hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:bakryapp/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:bakryapp/patient_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DepartmentSelectionScreen extends StatefulWidget {
  const DepartmentSelectionScreen({Key? key}) : super(key: key);

  @override
  State<DepartmentSelectionScreen> createState() =>
      _DepartmentSelectionScreenState();
}

class _DepartmentSelectionScreenState extends State<DepartmentSelectionScreen> {
  bool _isSyncing = false;
  String _syncError = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncTimestamp = prefs.getInt('lastSyncTimestamp') ?? 0;

      // Check if the last sync was within the past 2 days (in milliseconds)
      const twoDaysInMillis = 2 * 24 * 60 * 60 * 1000;
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      if (currentTime - lastSyncTimestamp < twoDaysInMillis) {
        // Skip syncing, as it was done recently
        print("Sync skipped; last sync was within 2 days.");
        return;
      }

      setState(() {
        _isSyncing = true;
        _syncError = '';
      });

      // Perform sync
      await _syncWithFirestore();

      // Save the current timestamp as the last sync time
      await prefs.setInt('lastSyncTimestamp', currentTime);
    } catch (e) {
      setState(() {
        _syncError = 'Failed to sync drug monographs: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _syncWithFirestore() async {
    final drugMonographBox =
        Provider.of<Box<DrugMonograph>>(context, listen: false);

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('drug_monographs').get();

      // Clear existing data before sync (optional)
      await drugMonographBox.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final drug = DrugMonograph(
          id: data['id'] ?? 0,
          vialConc: data['vial_conc'] ?? 0,
          finalConc: data['final_conc'] ?? '',
          dilution: data['dilution'] ?? 0,
          genericName: doc.id,
          category: data['category'],
          aware: _parseAwareValue(data['aware']),
          nicuDose: data['NICU_dose'],
          renalAdjustmentNicu: data['renal_adjustment_NICU'],
          picuAdverseEffect: data['PICU_adverse_effect'],
          nicuAdverseEffect: data['NICU_adverse_effect'],
          administration: data['Administration'],
          stability: data['Stability'],
          csf: data['CSF'],
        );
        await drugMonographBox.put(doc.id, drug);
      }
    } catch (e) {
      throw Exception('Firestore sync failed: $e');
    }
  }

  String? _parseAwareValue(dynamic awareValue) {
    return (awareValue is String && awareValue.isNotEmpty) ? awareValue : null;
  }

  Future<void> _logout() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Clear Provider data
    userProvider.clear();

    // Clear cached data
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navigate to login screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final units = userProvider.units ?? [];
    final permission = userProvider.permission ?? '';
    final username = userProvider.username ?? 'User';

    if (_isSyncing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Syncing drug monographs...'),
            ],
          ),
        ),
      );
    }

    if (_syncError.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 50),
              Text(_syncError),
              ElevatedButton(
                onPressed: _initializeData,
                child: const Text('Retry Sync'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $username'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
          if (permission == 'Admin')
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: IconButton(
                icon: const Icon(Icons.admin_panel_settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminPanelScreen(),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (units.contains('NICU') || units.contains('TPN'))
                _buildDepartmentButton(
                  context,
                  title: 'NICU',
                  color: Colors.blueAccent,
                  onPressed: () {
                    Provider.of<UserProvider>(context, listen: false)
                        .setDepartment('NICU');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientListScreen(),
                      ),
                    );
                  },
                ),
              if ((units.contains('NICU') || units.contains('TPN')) &&
                  (units.contains('PICU') || units.contains('TPN')))
                const SizedBox(height: 20),
              if (units.contains('PICU') || units.contains('TPN'))
                _buildDepartmentButton(
                  context,
                  title: 'PICU',
                  color: Colors.teal,
                  onPressed: () {
                    Provider.of<UserProvider>(context, listen: false)
                        .setDepartment('PICU');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientListScreen(),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20),
              _buildDepartmentButton(
                context,
                title: 'Pediatric Ward',
                color: Colors.orange,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PediatricWardScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildDepartmentButton(
                context,
                title: 'Calculators',
                color: const Color.fromARGB(255, 231, 53, 163),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalculatorsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
              _buildDepartmentButton(
                context,
                title: 'Bilirubin',
                color: const Color.fromARGB(255, 15, 161, 76),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ThresholdScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 120),
              // Drug Monographs Button
              _buildDepartmentButton(
                context,
                title: 'Drug Monographs',
                color: const Color.fromARGB(162, 144, 248, 103),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DrugMonographScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentButton(BuildContext context,
      {required String title,
      required Color color,
      required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 36.0),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 6,
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      child: Text(title),
    );
  }
}
