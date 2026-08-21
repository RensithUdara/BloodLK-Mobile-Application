import 'package:flutter/material.dart';
import '../data/models/emergency_request.dart';
import '../data/models/donation_center.dart';
import '../data/models/donor.dart';
import '../data/repositories/donation_center_repository.dart';
import '../data/repositories/donor_repository.dart';
import '../data/repositories/emergency_request_repository.dart';
import '../data/repositories/notification_repository.dart';

class AdminViewModel extends ChangeNotifier {
  AdminViewModel({
    DonorRepository? donorRepository,
    EmergencyRequestRepository? emergencyRequestRepository,
    NotificationRepository? notificationRepository,
    DonationCenterRepository? donationCenterRepository,
  })  : _donorRepository = donorRepository ?? DonorRepository(),
        _emergencyRequestRepository =
            emergencyRequestRepository ?? EmergencyRequestRepository(),
        _notificationRepository =
            notificationRepository ?? NotificationRepository(),
        _donationCenterRepository =
            donationCenterRepository ?? DonationCenterRepository();

  final DonorRepository _donorRepository;
  final EmergencyRequestRepository _emergencyRequestRepository;
  final NotificationRepository _notificationRepository;
  final DonationCenterRepository? _donationCenterRepository;

  Stream<List<Donor>> watchDonors() => _donorRepository.watchAllDonors();

  Stream<List<DonationCenter>> watchDonationCenters() {
    return (_donationCenterRepository ?? DonationCenterRepository())
        .watchCenters();
  }

  Stream<List<EmergencyRequest>> watchEmergencyRequests() {
    return _emergencyRequestRepository.watchOpenRequests();
  }

  Future<int> sendGroupNotification(String bloodType) {
    return _notificationRepository.sendGroupNotification(bloodType);
  }

  Future<void> postEmergencyRequest(EmergencyRequest request) {
    return _emergencyRequestRepository.saveRequest(request);
  }

  Future<void> saveDonationCenter(DonationCenter center) {
    return (_donationCenterRepository ?? DonationCenterRepository())
        .saveCenter(center);
  }
}
