import 'package:bakryapp/admin_screen.dart';
import 'package:bakryapp/drugs_monograph.dart';
import 'package:bakryapp/login_screen.dart';
import 'package:bakryapp/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:bakryapp/patient_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DepartmentSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final units = userProvider.units ?? [];
    final permission = userProvider.permission ?? '';
    final username = userProvider.username ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Clear Provider data
              userProvider.clear();

              // Clear cached data
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              // Navigate to login screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            },
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
                      builder: (context) => DrugMonographScreen(),
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
