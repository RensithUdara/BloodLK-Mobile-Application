import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationRepository {
  NotificationRepository({
    FirebaseFunctions? functions,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseMessaging? messaging,
  })  : _functions = functions ?? FirebaseFunctions.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseMessaging _messaging;

  DocumentReference<Map<String, dynamic>>? get _currentDonorDoc {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('donors').doc(uid);
  }

  DocumentReference<Map<String, dynamic>>? get _currentSettingsDoc {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('donorSettings').doc(uid);
  }

  CollectionReference<Map<String, dynamic>>? get _currentNotifications {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('donors').doc(uid).collection('notifications');
  }

  Future<String?> syncCurrentToken() async {
    final donorDoc = _currentDonorDoc;
    if (donorDoc == null) return null;

    final token = await _messaging.getToken();
    if (token == null || token.trim().isEmpty) return null;

    await donorDoc.set(
      {
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    return token;
  }

  Future<void> saveSettings({
    required bool urgentAlerts,
    required bool eligibilityReminders,
    required bool cityAlerts,
  }) async {
    final settingsDoc = _currentSettingsDoc;
    if (settingsDoc == null) return;

    await settingsDoc.set(
      {
        'urgentAlerts': urgentAlerts,
        'eligibilityReminders': eligibilityReminders,
        'cityAlerts': cityAlerts,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Stream<Map<String, dynamic>> watchCurrentSettings() {
    final settingsDoc = _currentSettingsDoc;
    if (settingsDoc == null) return Stream.value(const {});

    return settingsDoc.snapshots().map(
          (snapshot) => snapshot.data() ?? const <String, dynamic>{},
        );
  }

  Stream<List<DonorNotification>> watchCurrentNotifications() {
    final notifications = _currentNotifications;
    if (notifications == null) return Stream.value(const []);

    return notifications.snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => DonorNotification.fromMap(doc.id, doc.data()))
          .toList();

      items.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      return List<DonorNotification>.unmodifiable(items);
    });
  }

  Future<int> sendGroupNotification(String bloodType) async {
    final result =
        await _functions.httpsCallable('sendGroupNotification').call({
      'bloodType': bloodType,
      'messageContent':
          'Urgent blood request for $bloodType donors. Please contact the hospital if you can help.',
    });

    final data = Map<String, dynamic>.from(result.data as Map);
    if (data['success'] == true) {
      return data['count'] as int? ?? 0;
    }

    throw Exception(data['message']?.toString() ?? 'Notification failed');
  }
}

class DonorNotification {
  const DonorNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.bloodGroup,
    this.requestId,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final String? bloodGroup;
  final String? requestId;
  final DateTime? createdAt;

  factory DonorNotification.fromMap(String id, Map<String, dynamic> data) {
    return DonorNotification(
      id: id,
      title: data['title']?.toString() ?? 'Notification',
      body: data['body']?.toString() ?? '',
      type: data['type']?.toString() ?? 'general',
      bloodGroup: data['bloodGroup']?.toString(),
      requestId: data['requestId']?.toString(),
      createdAt: _dateFromValue(data['createdAt']),
    );
  }

  static DateTime? _dateFromValue(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
