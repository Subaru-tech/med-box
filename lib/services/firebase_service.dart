import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseAuth get auth => FirebaseAuth.instance;

  /// Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Enable Firestore persistence for offline support
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  /// Get a Firestore collection reference
  CollectionReference<Map<String, dynamic>> collection(String name) {
    return firestore.collection(name);
  }

  /// Get the current authenticated user
  User? get currentUser => auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Get the current user's UID
  String? get currentUserId => currentUser?.uid;
}
