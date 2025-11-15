import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  String _role = 'staff';
  bool loading = true;

  AuthProvider() {
    _init();
  }

  User? get user => _user;
  String get role => _role;
  bool get isLoggedIn => _user != null;
  bool get isOwner => _role == 'owner';

  Future<void> _init() async {
    _auth.authStateChanges().listen((firebaseUser) async {
      _user = firebaseUser;
      if (firebaseUser != null) {
        await _loadUserRole(firebaseUser);
      } else {
        _role = 'staff';
        loading = false;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserRole(User firebaseUser) async {
    final doc = await _db.collection('users').doc(firebaseUser.uid).get();

    if (doc.exists) {
      _role = doc.data()?['role'] ?? 'staff';
    } else {
      _role = 'owner'; // user pertama bawaan owner
      await _db.collection('users').doc(firebaseUser.uid).set({
        'name': firebaseUser.displayName ?? '',
        'email': firebaseUser.email ?? '',
        'role': _role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    loading = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    loading = true;
    notifyListeners();

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        loading = false;
        notifyListeners();
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      final firebaseUser = result.user;
      if (firebaseUser != null) {
        await _loadUserRole(firebaseUser);
      }
    } catch (e) {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    _user = null;
    _role = 'staff';
    notifyListeners();
  }
}
