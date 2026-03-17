import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { authenticated, unauthenticated, loading }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  AuthStatus _status = AuthStatus.loading;
  String? _error;
  bool _rememberMe = true;

  AuthProvider() {
    _init();
  }

  UserModel? get user => _user;
  AuthStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == AuthStatus.loading;
  bool get rememberMe => _rememberMe;

  void _init() {
    _authService.authStateChanges.listen((user) async {
      if (user == null) {
        _user = null;
        _status = AuthStatus.unauthenticated;
      } else {
        _user = await _authService.getUserProfile(user.uid);
        _status = AuthStatus.authenticated;
      }
      notifyListeners();
    });
  }

  void toggleRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        if (_rememberMe) {
          await _authService.saveUserEmail(email);
        } else {
          await _authService.clearSavedEmail();
        }
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _error = 'Invalid credentials';
    } catch (e) {
      _error = e.toString().contains('user-not-found') 
          ? 'No user found with this email'
          : 'Failed to sign in. Please try again.';
    }

    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      await _authService.signUp(email, password, name);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create account. Email might already be in use.';
    }

    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<String?> getSavedEmail() async {
    return await _authService.getSavedEmail();
  }
}
