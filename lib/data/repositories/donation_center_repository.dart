import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/donation_center.dart';

class DonationCenterRepository {
  DonationCenterRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _centers =>
      _firestore.collection('donation_center');

  Stream<List<DonationCenter>> watchCenters() {
    return _centers.snapshots().map((snapshot) {
      final centers = snapshot.docs
          .map((doc) => DonationCenter.fromMap(doc.id, doc.data()))
          .toList();

      centers.sort((a, b) => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ));

      return List<DonationCenter>.unmodifiable(centers);
    });
  }
}
