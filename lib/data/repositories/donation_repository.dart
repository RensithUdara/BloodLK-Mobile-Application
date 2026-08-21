import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/donation_record.dart';
import '../models/donor.dart';

class DonationRepository {
  DonationRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>> _donorDoc(String uid) {
    return _firestore.collection('donors').doc(uid);
  }

  CollectionReference<Map<String, dynamic>> _donations(String uid) {
    return _donorDoc(uid).collection('donations');
  }

  Stream<int> watchTotalDonationUnits() {
    return _firestore.collectionGroup('donations').snapshots().map((snapshot) {
      return snapshot.docs.fold<int>(0, (total, doc) {
        final record = DonationRecord.fromMap(doc.id, doc.data());
        return total + record.patientCount;
      });
    });
  }

  Future<void> saveDonation(DonationRecord donation) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Please sign in before saving a donation');
    }

    final donorRef = _donorDoc(uid);
    final donationRef = _donations(uid).doc();

    await _firestore.runTransaction((transaction) async {
      final donorSnapshot = await transaction.get(donorRef);
      final donorData = donorSnapshot.data();
      final currentLastDonation =
          donorData == null ? null : Donor.fromMap(donorData).lastDonationDate;

      transaction.set(donationRef, donation.toMap());

      if (currentLastDonation == null ||
          donation.donationDate.isAfter(currentLastDonation)) {
        transaction.set(
          donorRef,
          {'lastDonationDate': Timestamp.fromDate(donation.donationDate)},
          SetOptions(merge: true),
        );
      }
    });
  }

  Stream<List<DonationRecord>> watchCurrentDonations() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(const []);

    return _donations(uid)
        .orderBy('donationDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DonationRecord.fromMap(doc.id, doc.data()))
              .toList(growable: false),
        );
  }
}
