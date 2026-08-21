import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _donors =>
      _firestore.collection('donors');

  Future<UserCredential> signInDonor({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user?.uid;
    if (uid == null) return credential;

    final role = await userRole(uid);
    if (role == 'admin') {
      await _auth.signOut();
      throw Exception('Admin accounts cannot sign in as donors');
    }

    if (role.isEmpty && await donorProfileExists(uid)) {
      await saveUserRole(uid: uid, email: email, role: 'donor');
    }

    return credential;
  }

  Future<UserCredential> createDonorAccount({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user?.uid;
    if (uid != null) {
      await saveUserRole(uid: uid, email: email, role: 'donor');
    }
    return credential;
  }

  Future<void> signInAdmin({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user?.uid;
    if (uid == null) {
      await _auth.signOut();
      throw Exception('Unable to verify admin account');
    }

    final role = await userRole(uid);
    if (role != 'admin') {
      await _auth.signOut();
      throw Exception('Access denied: admin role required');
    }
  }

  Future<bool> donorProfileExists(String uid) async {
    final doc = await _donors.doc(uid).get();
    return doc.exists;
  }

  Future<String> userRole(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.data()?['role']?.toString().trim().toLowerCase() ?? '';
  }

  Future<void> saveUserRole({
    required String uid,
    required String email,
    required String role,
  }) {
    return _users.doc(uid).set(
      {
        'email': email.trim().toLowerCase(),
        'role': role.trim().toLowerCase(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
