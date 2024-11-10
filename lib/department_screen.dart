import 'package:flutter/material.dart';
import 'package:bakryapp/patient_list_screen.dart';

class DepartmentSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Department'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientListScreen(department: 'NICU'),
                  ),
                );
              },
              child: const Text('NICU'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientListScreen(department: 'PICU'),
                  ),
                );
              },
              child: const Text('PICU'),
            ),
          ],
        ),
      ),
    );
  }
}
