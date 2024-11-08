import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  final CollectionReference patientsRef =
      FirebaseFirestore.instance.collection('patients');
}
