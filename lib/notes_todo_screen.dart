import 'package:bakryapp/comment_section.dart';
import 'package:bakryapp/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotesTodoScreen extends StatelessWidget {
  final String theDepartment;
  final String patientId;

  NotesTodoScreen({required this.theDepartment, required this.patientId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final userName = Provider.of<UserProvider>(context).username;
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
                  _buildNotesList(context, userName),
                  const SizedBox(height: 20),
                  _buildSectionTitle(context, 'Todos'),
                  _buildTodosList(context, userName),
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

  Future<int> _getCommentCount(String noteId, String collection) async {
    final commentSnapshot = await _firestore
        .collection('departments')
        .doc(theDepartment)
        .collection('patients')
        .doc(patientId)
        .collection(collection)
        .doc(noteId)
        .collection('comments')
        .get();

    return commentSnapshot.size;
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

  Widget _buildNotesList(BuildContext context, String? userName) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('departments')
          .doc(theDepartment)
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
            return _buildNoteCard(context, note, userName);
          },
        );
      },
    );
  }

  Widget _buildNoteCard(
      BuildContext context, QueryDocumentSnapshot note, String? userName) {
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
              note['noteContent'],
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
                  icon: FutureBuilder<DocumentSnapshot>(
                    future: note.reference.get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Icon(Icons.thumb_up_off_alt);
                      }

                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final List<dynamic> likedBy = data['likedBy'] ?? [];

                      return Icon(
                        likedBy.contains(userName)
                            ? Icons.thumb_up
                            : Icons.thumb_up_off_alt,
                        color: likedBy.contains(userName)
                            ? Colors.blue
                            : Colors.grey,
                      );
                    },
                  ),
                  onPressed: () => _toggleLike(note, 'notes', userName),
                ),
                Text(
                  '${(note.data() as Map<String, dynamic>)['likes'] ?? 0} likes',
                ),
                const Spacer(),
                FutureBuilder<int>(
                  future: _getCommentCount(
                      note.id, "notes"), // Get the number of comments
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasData) {
                      return TextButton(
                        child: Text(
                            "${snapshot.data} Comments"), // Display the comment count
                        onPressed: () =>
                            _showCommentsDialog(note.id, 'notes', context),
                      );
                    }
                    return const SizedBox(); // Handle error or empty state
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodosList(BuildContext context, String? userName) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('departments')
          .doc(theDepartment)
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
            return _buildTodoCard(context, todo, userName!);
          },
        );
      },
    );
  }

  Widget _buildTodoCard(
      BuildContext context, QueryDocumentSnapshot todo, String userName) {
    final Map<String, dynamic>? todoData = todo.data() as Map<String, dynamic>?;

    // Safely retrieve and format the `dateCreated` field
    final String createdOn = todoData?['dateCreated'] is Timestamp
        ? 'Accomplished on: ${formatDate(todoData!['dateCreated'] as Timestamp)} by $userName'
        : '';

    // Safely retrieve and format the `dateAccomplished` field
    final String accomplishedOn = todoData?['dateAccomplished'] is Timestamp
        ? ' ${formatDate(todoData!['dateAccomplished'] as Timestamp)}'
        : 'Accomplished on: Not yet accomplished';

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    todoData?['todoContent'] ?? 'No content',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                Checkbox(
                  value: todoData?['accomplished'] ?? false,
                  onChanged: (value) =>
                      _toggleAccomplished(todo.reference, value),
                ),
              ],
            ),
            Text(
              'Created on: $createdOn\n$accomplishedOn',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: FutureBuilder<DocumentSnapshot>(
                    future: todo.reference.get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Icon(Icons.thumb_up_off_alt);
                      }

                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final List<dynamic> likedBy = data['likedBy'] ?? [];

                      return Icon(
                        likedBy.contains(userName)
                            ? Icons.thumb_up
                            : Icons.thumb_up_off_alt,
                        color: likedBy.contains(userName)
                            ? Colors.blue
                            : Colors.grey,
                      );
                    },
                  ),
                  onPressed: () => _toggleLike(todo, 'todos', userName),
                ),
                Text(
                  '${todo['likes'] ?? 0} likes',
                ),
                const Spacer(),
                FutureBuilder<int>(
                  future: _getCommentCount(todo.id, "todos"),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasData) {
                      return TextButton(
                        child: Text("${snapshot.data} Comments"),
                        onPressed: () =>
                            _showCommentsDialog(todo.id, 'todos', context),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleAccomplished(DocumentReference todoRef, bool? isAccomplished) {
    todoRef.update({
      'accomplished': isAccomplished,
      'dateAccomplished': isAccomplished == true
          ? FieldValue.serverTimestamp()
          : null, // Set to current date or null
    });
  }

  void _toggleLike(QueryDocumentSnapshot doc, String collectionName,
      String? userName) async {
    final docRef = _firestore
        .collection('departments')
        .doc(theDepartment)
        .collection('patients')
        .doc(patientId)
        .collection(collectionName)
        .doc(doc.id);

    await docRef.get().then((docSnapshot) {
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final List<dynamic> likedBy = data['likedBy'] ?? [];

        if (likedBy.contains(userName)) {
          // Unlike: Remove user from likedBy
          likedBy.remove(userName);
        } else {
          // Like: Add user to likedBy
          likedBy.add(userName);
        }

        docRef.update({'likedBy': likedBy, 'likes': likedBy.length});
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

  String formatDate(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  void _showCommentsDialog(
      String docId, String collectionName, BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: CommentsSection(
          department: theDepartment,
          patientId: patientId,
          docId: docId,
          collectionName: collectionName,
        ),
      ),
    );
  }

  void _addNoteToFirestore(String noteContent) {
    DateTime dateTime = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format((dateTime));
    _firestore
        .collection('departments')
        .doc(theDepartment)
        .collection('patients')
        .doc(patientId)
        .collection('notes')
        .add({
      'noteContent': noteContent,
      'dateCreated': formattedDate,
      'likes': 0,
    });
  }

  void _addTodoToFirestore(String todoContent) {
    _firestore
        .collection('departments')
        .doc(theDepartment)
        .collection('patients')
        .doc(patientId)
        .collection('todos')
        .add({
      'todoContent': todoContent,
      'dateCreated': FieldValue.serverTimestamp(),
      'dateAccomplished': null,
      'likes': 0,
    });
  }
}
