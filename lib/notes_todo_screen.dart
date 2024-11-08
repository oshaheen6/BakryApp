import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotesTodoScreen extends StatelessWidget {
  final String patientId;

  NotesTodoScreen({required this.patientId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes & Todo'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildSectionTitle(context, 'Notes'),
                  _buildNotesList(),
                  const SizedBox(height: 20),
                  _buildSectionTitle(context, 'Todos'),
                  _buildTodosList(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAddNoteButton(context),
                _buildAddTodoButton(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
      ),
    );
  }

  Widget _buildNotesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('patients')
          .doc(patientId)
          .collection('notes')
          .orderBy('dateCreated', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final notes = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            var note = notes[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                title: Text(
                  note['noteContent'],
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'Created on: ${note['dateCreated']}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTodosList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('patients')
          .doc(patientId)
          .collection('todos')
          .orderBy('dateCreated', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final todos = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: todos.length,
          itemBuilder: (context, index) {
            var todo = todos[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                title: Text(
                  todo['todoContent'],
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'Created on: ${todo['dateCreated']}\n'
                  'Accomplished on: ${todo['dateAccomplished'] ?? 'Not yet accomplished'}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAddNoteButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showAddNoteDialog(context),
      icon: const Icon(Icons.add),
      label: const Text('Add Note'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildAddTodoButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showAddTodoDialog(context),
      icon: const Icon(Icons.add_task),
      label: const Text('Add Todo'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    final TextEditingController _noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Note'),
        content: TextField(
          controller: _noteController,
          decoration: const InputDecoration(hintText: 'Enter note content'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (_noteController.text.isNotEmpty) {
                _addNoteToFirestore(_noteController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    final TextEditingController _todoController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Todo'),
        content: TextField(
          controller: _todoController,
          decoration: const InputDecoration(hintText: 'Enter todo description'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (_todoController.text.isNotEmpty) {
                _addTodoToFirestore(_todoController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addNoteToFirestore(String noteContent) {
    _firestore.collection('patients').doc(patientId).collection('notes').add({
      'noteContent': noteContent,
      'dateCreated': DateTime.now().toString(),
    });
  }

  void _addTodoToFirestore(String todoContent) {
    _firestore.collection('patients').doc(patientId).collection('todos').add({
      'todoContent': todoContent,
      'dateCreated': DateTime.now().toString(),
      'dateAccomplished': null,
    });
  }
}
