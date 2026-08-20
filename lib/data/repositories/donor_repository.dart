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

  Future<void> saveDonor(Donor donor) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Please sign in before registering as a donor');
    }

    return _donors.doc(uid).set(donor.toMap(), SetOptions(merge: true));
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
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));

    return _donors
        .where('bloodGroup', isEqualTo: bloodGroup)
        .where('city', isEqualTo: city.toLowerCase())
        .where(
          'lastDonationDate',
          isLessThanOrEqualTo: Timestamp.fromDate(threeMonthsAgo),
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Donor.fromMap(doc.data()))
              .toList(growable: false),
        );
  }
}
