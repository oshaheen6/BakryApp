import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminPanelScreen extends StatefulWidget {
  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!.docs
              .where((doc) => doc['permission'] != 'Admin')
              .toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user['username'] ?? 'Unknown'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Job Title: ${user['jobTitle'] ?? 'Unknown'}'),
                    Text('Unit: ${user['unit'] ?? 'Unknown'}'),
                    Text('Approved: ${user['isApproved'] ? "Yes" : "No"}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showEditDialog(context, user.id, user);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, String userId, dynamic user) {
    final jobTitle = user['jobTitle'] ?? '';
    List<String> selectedUnits = List<String>.from(user['unit'] ?? []);
    bool isApproved = user['isApproved'] ?? false;

    final jobTitleController = TextEditingController(
      text: jobTitle,
    );

    final List<String> availableUnits = ['PICU', 'NICU', 'TPN'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit User'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: jobTitleController,
                  decoration: const InputDecoration(labelText: 'Job Title'),
                ),
                const SizedBox(height: 10),
                const Text('Select Units:'),
                Wrap(
                  spacing: 10.0,
                  children: availableUnits.map((unit) {
                    final isSelected = selectedUnits.contains(unit);
                    return ChoiceChip(
                      label: Text(unit),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedUnits.add(unit);
                          } else {
                            selectedUnits.remove(unit);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Approved'),
                    Switch(
                      value: isApproved,
                      onChanged: (value) {
                        setState(() {
                          isApproved = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .update({
                    'jobTitle': jobTitleController.text,
                    'unit': selectedUnits,
                    'isApproved': isApproved,
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
