import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/donor.dart';

class DonorRepository {
  DonorRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _donors =>
      _firestore.collection('donors');

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<void> saveDonor(Donor donor) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Please sign in before registering as a donor');
    }

    final email = _auth.currentUser?.email ?? '';
    final batch = _firestore.batch();

    batch.set(_donors.doc(uid), donor.toMap(), SetOptions(merge: true));
    batch.set(
      _users.doc(uid),
      {
        'email': email.trim().toLowerCase(),
        'role': 'donor',
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Stream<Donor?> watchCurrentDonor() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);

    return _donors.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) return null;
      return Donor.fromMap(data);
    });
  }

  Stream<List<Donor>> watchAllDonors() {
    return _donors.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Donor.fromMap(doc.data()))
              .toList(growable: false),
        );
  }

  Stream<List<Donor>> searchEligibleDonors({
    required String bloodGroup,
    required String city,
  }) {
    final fiveMonthsAgo = DateTime.now().subtract(const Duration(days: 150));

    return _donors.where('city', isEqualTo: city.toLowerCase()).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Donor.fromMap(doc.data()))
              .where(
                (donor) =>
                    donor.bloodGroup == bloodGroup &&
                    (donor.lastDonationDate == null ||
                        !donor.lastDonationDate!.isAfter(fiveMonthsAgo)),
              )
              .toList(growable: false),
        );
  }
}
