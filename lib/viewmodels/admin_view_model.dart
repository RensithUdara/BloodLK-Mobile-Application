import 'package:flutter/material.dart';
import '../data/models/emergency_request.dart';
import '../data/models/donor.dart';
import '../data/repositories/donor_repository.dart';
import '../data/repositories/emergency_request_repository.dart';
import '../data/repositories/notification_repository.dart';

class AdminViewModel extends ChangeNotifier {
  AdminViewModel({
    DonorRepository? donorRepository,
    EmergencyRequestRepository? emergencyRequestRepository,
    NotificationRepository? notificationRepository,
  })  : _donorRepository = donorRepository ?? DonorRepository(),
        _emergencyRequestRepository =
            emergencyRequestRepository ?? EmergencyRequestRepository(),
        _notificationRepository =
            notificationRepository ?? NotificationRepository();

  final DonorRepository _donorRepository;
  final EmergencyRequestRepository _emergencyRequestRepository;
  final NotificationRepository _notificationRepository;

  Stream<List<Donor>> watchDonors() => _donorRepository.watchAllDonors();

  Future<int> sendGroupNotification(String bloodType) {
    return _notificationRepository.sendGroupNotification(bloodType);
  }

  Future<void> postEmergencyRequest(EmergencyRequest request) {
    return _emergencyRequestRepository.saveRequest(request);
  }
}
