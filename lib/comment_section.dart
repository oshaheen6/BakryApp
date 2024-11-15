import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsSection extends StatelessWidget {
  final String department;
  final String patientId;
  final String docId;
  final String collectionName;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _commentController = TextEditingController();

  CommentsSection({
    required this.department,
    required this.patientId,
    required this.docId,
    required this.collectionName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
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
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  var comment = comments[index];
                  return _buildCommentCard(context, comment);
                },
              );
            },
          ),
        ),
        _buildAddCommentField(context),
      ],
    );
  }

  Widget _buildCommentCard(
      BuildContext context, QueryDocumentSnapshot comment) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: comment['profilePictureUrl'] != null
            ? NetworkImage(comment['profilePictureUrl'])
            : null,
        child: comment['profilePictureUrl'] == null ? Icon(Icons.person) : null,
      ),
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

  Widget _buildAddCommentField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
            icon: Icon(Icons.send, color: Colors.blueAccent),
            onPressed: () {
              if (_commentController.text.isNotEmpty) {
                _addCommentToFirestore(_commentController.text);
                _commentController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  void _addCommentToFirestore(String commentText) {
    _firestore
        .collection('patients')
        .doc(patientId)
        .collection(collectionName)
        .doc(docId)
        .collection('comments')
        .add({
      'username': 'User Name', // Replace with actual user name
      'commentText': commentText,
      'dateCreated': DateTime.now().toIso8601String(),
      'profilePictureUrl':
          'https://example.com/user_profile.jpg', // Replace with user's profile URL if available
    });
  }

  String _formatTimestamp(String date) {
    return date; // Implement formatting if needed
  }
}
