import 'package:cloud_functions/cloud_functions.dart';

class NotificationRepository {
  NotificationRepository({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

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
