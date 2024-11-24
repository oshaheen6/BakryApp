import 'package:bakryapp/drugs_monograph.dart';
import 'package:bakryapp/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:bakryapp/patient_list_screen.dart';
import 'package:provider/provider.dart';

class DepartmentSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Department'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              const SizedBox(height: 20),
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
