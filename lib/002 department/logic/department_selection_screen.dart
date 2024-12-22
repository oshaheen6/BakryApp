import 'package:bakryapp/002%20department/cubit/department_selection_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bakryapp/admin_screen.dart';
import 'package:bakryapp/drugs_monograph.dart';
import '../../001 signin/logic/login_screen.dart';
import '../../003 patient_list/logic/patient_list.dart';

class DepartmentSelectionScreen extends StatelessWidget {
  const DepartmentSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DepartmentSelectionCubit()..initializeData(),
      child: BlocConsumer<DepartmentSelectionCubit, DepartmentSelectionState>(
        listener: (context, state) {
          if (state is DepartmentSelectionLoggedOut) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          }
        },
        builder: (context, state) {
          if (state is DepartmentSelectionLoading) {
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

          if (state is DepartmentSelectionError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 50),
                    Text(state.message),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<DepartmentSelectionCubit>()
                            .initializeData();
                      },
                      child: const Text('Retry Sync'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is DepartmentSelectionLoaded) {
            return _buildLoadedScreen(context);
          }

          return Container(); // Default empty state
        },
      ),
    );
  }

  Widget _buildLoadedScreen(BuildContext context) {
    // Mock user data for demonstration
    final username = 'User'; // Replace with actual username from the state
    final permission = 'Admin'; // Replace with actual permission from the state
    final units = ['NICU', 'PICU', 'TPN']; // Replace with actual units

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $username'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<DepartmentSelectionCubit>().logout();
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientListScreen(),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 120),
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
