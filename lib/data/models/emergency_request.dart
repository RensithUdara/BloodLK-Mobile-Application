import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyRequest {
  const EmergencyRequest({
    this.id,
    required this.bloodGroup,
    required this.patientName,
    required this.location,
    required this.contactNumber,
    required this.note,
    required this.createdAt,
    this.status = 'open',
  });

  final String? id;
  final String bloodGroup;
  final String patientName;
  final String location;
  final String contactNumber;
  final String note;
  final DateTime? createdAt;
  final String status;

  factory EmergencyRequest.fromMap(String id, Map<String, dynamic> data) {
    return EmergencyRequest(
      id: id,
      bloodGroup: data['bloodGroup']?.toString() ?? '',
      patientName: data['patientName']?.toString() ?? '',
      location: data['location']?.toString() ?? '',
      contactNumber: data['contactNumber']?.toString() ?? '',
      note: data['note']?.toString() ?? '',
      createdAt: _dateFromValue(data['createdAt']),
      status: data['status']?.toString() ?? 'open',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bloodGroup': bloodGroup,
      'patientName': patientName.trim(),
      'location': location.trim(),
      'contactNumber': contactNumber.trim(),
      'note': note.trim(),
      'status': status,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }

  static DateTime? _dateFromValue(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
