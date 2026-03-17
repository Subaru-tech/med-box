import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<void> signUp(String email, String password, String name) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    if (credential.user != null) {
      final userModel = UserModel(
        uid: credential.user!.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toJson());
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!, uid);
    }
    return null;
  }

  // Remember Me support
  Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', email);
  }

  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('saved_email');
  }

  Future<void> clearSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
  }
}
