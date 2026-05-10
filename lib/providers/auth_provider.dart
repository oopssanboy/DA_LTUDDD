import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _loading = false;

  User? get user => _user;
  bool get loading => _loading;

  AuthProvider() {
    _authService.userStream.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signUp(String email, String password) async {
    _loading = true;
    notifyListeners();
    User? user = await _authService.signUpWithEmail(email, password);
    _loading = false;
    notifyListeners();
    return user != null;
  }

  Future<bool> signIn(String email, String password) async {
    _loading = true;
    notifyListeners();
    User? user = await _authService.signInWithEmail(email, password);
    _loading = false;
    notifyListeners();
    return user != null;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}