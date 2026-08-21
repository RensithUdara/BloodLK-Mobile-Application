import 'package:cloud_firestore/cloud_firestore.dart';

class Donor {
  final String nic;
  final String name;
  final int age;
  final String phone;
  final String bloodGroup;
  final String city;
  final DateTime? lastDonationDate;
  final DateTime? registeredAt;
  final String? fcmToken;

  const Donor({
    required this.nic,
    required this.name,
    required this.age,
    required this.phone,
    required this.bloodGroup,
    required this.city,
    this.lastDonationDate,
    this.registeredAt,
    this.fcmToken,
  });

  factory Donor.fromMap(Map<String, dynamic> data) {
    return Donor(
      nic: data['nic']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      age: data['age'] is int
          ? data['age'] as int
          : int.tryParse(data['age']?.toString() ?? '') ?? 0,
      phone: data['phone']?.toString() ?? '',
      bloodGroup: data['bloodGroup']?.toString() ?? 'N/A',
      city: data['city']?.toString() ?? '',
      lastDonationDate: _dateFromValue(data['lastDonationDate']),
      registeredAt: _dateFromValue(data['registeredAt']),
      fcmToken: data['fcmToken']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nic': nic,
      'name': name,
      'age': age,
      'phone': phone,
      'bloodGroup': bloodGroup,
      'city': city.toLowerCase(),
      'role': 'donor',
      'lastDonationDate': lastDonationDate == null
          ? null
          : Timestamp.fromDate(lastDonationDate!),
      'registeredAt': registeredAt == null
          ? Timestamp.now()
          : Timestamp.fromDate(registeredAt!),
      'fcmToken': fcmToken,
    };
  }

  static DateTime? _dateFromValue(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
