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
                  _buildNotesList(context),
                  const SizedBox(height: 20),
                  _buildSectionTitle(context, 'Todos'),
                  _buildTodosList(context),
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

  Widget _buildNotesList(BuildContext context) {
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
            return _buildNoteCard(context, note);
          },
        );
      },
    );
  }

  Widget _buildNoteCard(BuildContext context, QueryDocumentSnapshot note) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note['noteContent'], // Access the 'noteContent' field directly
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              'Created on: ${note['dateCreated']}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up),
                  color: Colors.blue,
                  onPressed: () => _toggleLike(note),
                ),
                // Updated likes display to handle absence of 'likes' field
                Text(
                  '${(note.data() as Map<String, dynamic>)['likes'] ?? 0} likes',
                ),
                const Spacer(),
                TextButton(
                  child: const Text("Comments"),
                  onPressed: () =>
                      _showCommentsDialog(note.id, 'notes', context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodosList(BuildContext context) {
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
            return _buildTodoCard(context, todo);
          },
        );
      },
    );
  }

  Widget _buildTodoCard(BuildContext context, QueryDocumentSnapshot todo) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              todo['todoContent'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              'Created on: ${todo['dateCreated']}\n'
              'Accomplished on: ${todo['dateAccomplished'] ?? 'Not yet accomplished'}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up),
                  color: Colors.blue,
                  onPressed: () => _toggleLike(todo),
                ),
                // Using the null-aware operator to avoid 'containsKey'
                Text(
                  '${todo['likes'] ?? 0} likes',
                ),
                const Spacer(),
                TextButton(
                  child: const Text("Comments"),
                  onPressed: () =>
                      _showCommentsDialog(todo.id, 'todos', context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleLike(QueryDocumentSnapshot doc) async {
    final docRef = _firestore
        .collection('patients')
        .doc(patientId)
        .collection(doc.reference.parent.id)
        .doc(doc.id);

    await docRef.get().then((docSnapshot) {
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final likes = data['likes'] ?? 0; // Default to 0 if 'likes' is missing
        docRef.update({'likes': likes + 1});
      }
    });
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

  void _showCommentsDialog(
      String docId, String collectionName, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comments'),
        content: CommentsSection(
            patientId: patientId, docId: docId, collectionName: collectionName),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _addNoteToFirestore(String noteContent) {
    _firestore.collection('patients').doc(patientId).collection('notes').add({
      'noteContent': noteContent,
      'dateCreated': DateTime.now().toIso8601String(),
      'likes': 0, // Ensure 'likes' field is always set
    });
  }

  void _addTodoToFirestore(String todoContent) {
    _firestore.collection('patients').doc(patientId).collection('todos').add({
      'todoContent': todoContent,
      'dateCreated': DateTime.now().toIso8601String(),
      'likes': 0, // Ensure 'likes' field is always set
    });
  }
}

class CommentsSection extends StatelessWidget {
  final String patientId;
  final String docId;
  final String collectionName;

  CommentsSection(
      {required this.patientId,
      required this.docId,
      required this.collectionName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: Column(
        children: [
          // Placeholder for comments list and input field
        ],
      ),
    );
  }
}
