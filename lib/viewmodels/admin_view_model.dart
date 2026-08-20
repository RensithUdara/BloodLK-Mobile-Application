import 'package:flutter/material.dart';
import '../data/models/donor.dart';
import '../data/repositories/donor_repository.dart';
import '../data/repositories/notification_repository.dart';

class AdminViewModel extends ChangeNotifier {
  AdminViewModel({
    DonorRepository? donorRepository,
    NotificationRepository? notificationRepository,
  })  : _donorRepository = donorRepository ?? DonorRepository(),
        _notificationRepository =
            notificationRepository ?? NotificationRepository();

  final DonorRepository _donorRepository;
  final NotificationRepository _notificationRepository;

  Stream<List<Donor>> watchDonors() => _donorRepository.watchAllDonors();

  Future<int> sendGroupNotification(String bloodType) {
    return _notificationRepository.sendGroupNotification(bloodType);
  }
}
