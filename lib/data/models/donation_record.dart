import 'package:cloud_firestore/cloud_firestore.dart';

class DonationRecord {
  const DonationRecord({
    this.id,
    required this.donationDate,
    required this.patientCount,
    required this.location,
    this.createdAt,
  });

  final String? id;
  final DateTime donationDate;
  final int patientCount;
  final String location;
  final DateTime? createdAt;

  factory DonationRecord.fromMap(String id, Map<String, dynamic> data) {
    return DonationRecord(
      id: id,
      donationDate: _dateFromValue(data['donationDate']) ?? DateTime.now(),
      patientCount: data['patientCount'] is int
          ? data['patientCount'] as int
          : int.tryParse(data['patientCount']?.toString() ?? '') ?? 1,
      location: data['location']?.toString() ?? '',
      createdAt: _dateFromValue(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'donationDate': Timestamp.fromDate(donationDate),
      'patientCount': patientCount,
      'location': location.trim(),
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
