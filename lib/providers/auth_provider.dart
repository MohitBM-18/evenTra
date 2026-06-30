import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool get isAdmin => _currentUser?.role != UserRole.studentCoordinator;

  bool get canEditIncharges =>
      _currentUser?.email.toLowerCase() == 'mohitbm28@gmail.com' ||
      _currentUser?.role == UserRole.superAdmin;

  Future<void> _storeUserInFirestore(UserModel user) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .set(user.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error storing user in Firestore: $e');
    }
  }

  Future<UserModel?> _fetchUserFromFirestore(String id) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Error fetching user from Firestore: $e');
    }
    return null;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Basic mock authentication fallback for email/password since Firebase Auth isn't fully wired for it
    if (email.isNotEmpty && password.isNotEmpty) {
      final cleanEmail = email.trim();
      final role = cleanEmail.toLowerCase() == 'mohitbm28@gmail.com'
          ? UserRole.superAdmin
          : UserRole.studentCoordinator;
      final mockId = email.toLowerCase().hashCode.toString();

      var user = await _fetchUserFromFirestore(mockId);
      if (user == null) {
        user = MockData.defaultUser.copyWith(
          id: mockId,
          email: cleanEmail,
          role: role,
        );
        await _storeUserInFirestore(user);
      }

      _currentUser = user;
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
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      await googleSignIn.signOut();
      
      final googleUser = await googleSignIn.signIn();

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

      var user = await _fetchUserFromFirestore(firebaseUser.uid);
      if (user == null) {
        final email = firebaseUser.email ?? googleUser.email;
        final role = email.toLowerCase() == 'mohitbm28@gmail.com'
            ? UserRole.superAdmin
            : UserRole.studentCoordinator;

        user = MockData.defaultUser.copyWith(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? googleUser.displayName ?? MockData.defaultUser.name,
          email: email,
          role: role,
          profileImageUrl: firebaseUser.photoURL ?? googleUser.photoUrl,
        );
        await _storeUserInFirestore(user);
      }

      _currentUser = user;
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

  Future<bool> signInWithMicrosoft() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final provider = OAuthProvider('microsoft.com');
      provider.setCustomParameters({
        'tenant': 'common',
      });

      final userCredential = await FirebaseAuth.instance.signInWithProvider(provider);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        _errorMessage = 'Microsoft sign-in did not return a user.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      var user = await _fetchUserFromFirestore(firebaseUser.uid);
      if (user == null) {
        final email = firebaseUser.email ?? '';
        final role = email.toLowerCase() == 'mohitbm28@gmail.com'
            ? UserRole.superAdmin
            : UserRole.studentCoordinator;

        user = MockData.defaultUser.copyWith(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? MockData.defaultUser.name,
          email: email,
          role: role,
          profileImageUrl: firebaseUser.photoURL,
        );
        await _storeUserInFirestore(user);
      }

      _currentUser = user;
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = 'Microsoft sign-in failed. Check Firebase config.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void selectRole(UserRole role) async {
    if (_currentUser != null) {
      UserRole finalRole = role;
      if (_currentUser!.email.toLowerCase() == 'mohitbm28@gmail.com') {
        finalRole = UserRole.superAdmin;
      } else if (role == UserRole.superAdmin) {
        finalRole = UserRole.studentCoordinator;
      }
      _currentUser = _currentUser!.copyWith(role: finalRole);
      await _storeUserInFirestore(_currentUser!);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().disconnect();
    } catch (_) {
      await GoogleSignIn().signOut();
    }
    _currentUser = null;
    _isLoggedIn = false;
    _errorMessage = null;
    notifyListeners();
  }

  void updateProfile({String? name, String? department, String? phone}) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        department: department ?? _currentUser!.department,
        phone: phone ?? _currentUser!.phone,
      );
      await _storeUserInFirestore(_currentUser!);
      notifyListeners();
    }
  }
}
