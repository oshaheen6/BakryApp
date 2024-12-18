import 'package:bakryapp/jobs_icon.dart';
import 'package:bakryapp/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsSection extends StatelessWidget {
  final String department;
  final String patientId;
  final String docId;
  final String collectionName;
  final ScrollController scrollController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _commentController = TextEditingController();

  CommentsSection({
    required this.department,
    required this.patientId,
    required this.docId,
    required this.collectionName,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final userName = Provider.of<UserProvider>(context).username;

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('departments')
                .doc(department)
                .collection('patients')
                .doc(patientId)
                .collection(collectionName)
                .doc(docId)
                .collection('comments')
                .orderBy('dateCreated', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final comments = snapshot.data!.docs;

              return ListView.builder(
                controller: scrollController, // Ensures proper scroll behavior
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  var comment = comments[index];
                  return _buildCommentCard(context, comment, userName);
                },
              );
            },
          ),
        ),
        _buildAddCommentField(context, userName!, docId),
      ],
    );
  }

  Widget _buildCommentCard(
      BuildContext context, QueryDocumentSnapshot comment, String? userName) {
    return ListTile(
      leading: const CircleAvatar(radius: 25, child: JobTitleIcon(size: 45.0)),
      title: Text(comment['username']),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment['commentText']),
          Text(
            _formatTimestamp(comment['dateCreated']),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
      isThreeLine: true,
    );
  }

  Widget _buildAddCommentField(
      BuildContext context, String userName, String doc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: () {
              if (_commentController.text.isNotEmpty) {
                _addCommentToFirestore(
                    _commentController.text, userName, collectionName, doc);
                _commentController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  void _addCommentToFirestore(
      String commentText, String userName, String collectionName, String doc) {
    _firestore
        .collection('departments')
        .doc(department)
        .collection('patients')
        .doc(patientId)
        .collection(collectionName)
        .doc(doc)
        .collection('comments')
        .add({
      'username': userName,
      'commentText': commentText,
      'dateCreated': DateTime.now().toIso8601String(),
    });
  }

  String _formatTimestamp(String date) {
    return date;
  }
}
