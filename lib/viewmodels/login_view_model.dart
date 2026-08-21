import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/repositories/auth_repository.dart';

enum LoginDestination { donorRegistration, donorSearch, adminPanel }

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  final donorEmailController = TextEditingController();
  final donorPasswordController = TextEditingController();
  final donorConfirmPasswordController = TextEditingController();
  final adminEmailController = TextEditingController();
  final adminPasswordController = TextEditingController();

  bool isLoading = false;

  Future<LoginDestination> signInDonor() async {
    _setLoading(true);
    try {
      final credential = await _authRepository.signInDonor(
        email: donorEmailController.text.trim(),
        password: donorPasswordController.text.trim(),
      );

      final uid = credential.user!.uid;
      final hasProfile = await _authRepository.donorProfileExists(uid);
      return hasProfile
          ? LoginDestination.donorSearch
          : LoginDestination.donorRegistration;
    } on FirebaseAuthException catch (error) {
      throw Exception(_donorMessageFor(error));
    } catch (error) {
      throw Exception(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<LoginDestination> createDonorAccount() async {
    final password = donorPasswordController.text.trim();
    final confirmPassword = donorConfirmPasswordController.text.trim();

    if (password != confirmPassword) {
      throw Exception('Passwords do not match');
    }

    _setLoading(true);
    try {
      await _authRepository.createDonorAccount(
        email: donorEmailController.text.trim(),
        password: password,
      );
      return LoginDestination.donorRegistration;
    } on FirebaseAuthException catch (error) {
      throw Exception(_donorMessageFor(error));
    } catch (error) {
      throw Exception(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<LoginDestination> signInAdmin() async {
    _setLoading(true);
    try {
      await _authRepository.signInAdmin(
        email: adminEmailController.text.trim(),
        password: adminPasswordController.text.trim(),
      );
      return LoginDestination.adminPanel;
    } on FirebaseAuthException catch (error) {
      throw Exception(_adminMessageFor(error));
    } catch (error) {
      throw Exception(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  String _adminMessageFor(FirebaseAuthException error) {
    if (error.code == 'user-not-found') return 'No admin account found';
    if (error.code == 'wrong-password') return 'Incorrect password';
    if (error.code == 'invalid-email') return 'Invalid email format';
    return 'Access denied: wrong credentials';
  }

  String _donorMessageFor(FirebaseAuthException error) {
    if (error.code == 'email-already-in-use') {
      return 'This email already has an account';
    }
    if (error.code == 'invalid-email') return 'Invalid email format';
    if (error.code == 'weak-password') {
      return 'Password must be at least 6 characters';
    }
    if (error.code == 'user-not-found') return 'No donor account found';
    if (error.code == 'wrong-password') return 'Incorrect password';
    if (error.code == 'invalid-credential') {
      return 'Wrong email or password';
    }
    return 'Unable to continue. Please check your details';
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    donorEmailController.dispose();
    donorPasswordController.dispose();
    donorConfirmPasswordController.dispose();
    adminEmailController.dispose();
    adminPasswordController.dispose();
    super.dispose();
  }
}
