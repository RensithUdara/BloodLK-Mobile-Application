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
