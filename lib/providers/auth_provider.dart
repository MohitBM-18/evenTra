import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/enums.dart';
import '../models/user_model.dart';
import '../data/mock_data.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _currentUser?.role == UserRole.departmentAdmin || _currentUser?.role == UserRole.superAdmin;

  bool get canEditIncharges =>
      _currentUser?.email.toLowerCase() == 'mohitbm28@gmail.com' ||
      _currentUser?.role == UserRole.superAdmin;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Basic mock authentication
    if (email.isNotEmpty && password.isNotEmpty) {
      final cleanEmail = email.trim();
      final role = cleanEmail.toLowerCase() == 'mohitbm28@gmail.com'
          ? UserRole.superAdmin
          : UserRole.studentCoordinator;
      _currentUser = MockData.defaultUser.copyWith(
        email: cleanEmail,
        role: role,
      );
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final googleUser = await GoogleSignIn(
        scopes: ['email', 'profile'],
      ).signIn();

      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        _errorMessage = 'Google sign-in did not return a user.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final email = firebaseUser.email ?? googleUser.email;
      final role = email.toLowerCase() == 'mohitbm28@gmail.com'
          ? UserRole.superAdmin
          : UserRole.studentCoordinator;

      _currentUser = MockData.defaultUser.copyWith(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? googleUser.displayName ?? MockData.defaultUser.name,
        email: email,
        role: role,
        profileImageUrl: firebaseUser.photoURL ?? googleUser.photoUrl,
      );
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = 'Google sign-in needs Firebase setup before it can run.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void selectRole(UserRole role) {
    if (_currentUser != null) {
      UserRole finalRole = role;
      if (_currentUser!.email.toLowerCase() == 'mohitbm28@gmail.com') {
        finalRole = UserRole.superAdmin;
      } else if (role == UserRole.superAdmin) {
        // Normal users cannot choose Administrator (superAdmin)
        finalRole = UserRole.studentCoordinator;
      }
      _currentUser = _currentUser!.copyWith(role: finalRole);
      notifyListeners();
    }
  }

  void logout() {
    FirebaseAuth.instance.signOut();
    GoogleSignIn().signOut();
    _currentUser = null;
    _isLoggedIn = false;
    _errorMessage = null;
    notifyListeners();
  }
}
