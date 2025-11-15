import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppUserModel {
  final String id;
  final String name;
  final String email;
  final String role;

  AppUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}

class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<AppUserModel> _users = [];
  List<AppUserModel> get users => _users;

  UserProvider() {
    _listenUsers();
  }

  void _listenUsers() {
    _db.collection('users').snapshots().listen((snapshot) {
      _users = snapshot.docs.map((doc) {
        return AppUserModel(
          id: doc.id,
          name: doc['name'] ?? 'No Name',
          email: doc['email'] ?? '-',
          role: doc['role'] ?? 'staff',
        );
      }).toList();
      notifyListeners();
    });
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    await _db.collection('users').doc(uid).update({'role': newRole});
  }

  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }
}
