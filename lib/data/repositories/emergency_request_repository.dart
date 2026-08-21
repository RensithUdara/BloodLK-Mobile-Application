import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emergency_request.dart';

class EmergencyRequestRepository {
  EmergencyRequestRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection('emergency_request');

  Future<void> saveRequest(EmergencyRequest request) {
    return _requests.add(request.toMap());
  }

  Stream<List<EmergencyRequest>> watchOpenRequests() {
    return _requests
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EmergencyRequest.fromMap(doc.id, doc.data()))
              .toList(growable: false),
        );
  }
}
