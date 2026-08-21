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
    return _requests.where('status', isEqualTo: 'open').snapshots().map(
      (snapshot) {
        final requests = snapshot.docs
            .map((doc) => EmergencyRequest.fromMap(doc.id, doc.data()))
            .toList();

        requests.sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });

        return List<EmergencyRequest>.unmodifiable(requests);
      },
    );
  }
}
