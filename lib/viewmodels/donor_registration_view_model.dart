import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../data/models/donor.dart';
import '../data/repositories/donor_repository.dart';

class DonorRegistrationViewModel extends ChangeNotifier {
  DonorRegistrationViewModel({DonorRepository? donorRepository})
      : _donorRepository = donorRepository ?? DonorRepository();

  final DonorRepository _donorRepository;

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final nicController = TextEditingController();
  final otpController = TextEditingController();

  String selectedBloodGroup = 'A+';
  DateTime? lastDonationDate;
  bool neverDonated = true;
  String generatedOtp = '';

  int? daysUntilEligible() {
    if (neverDonated || lastDonationDate == null) return null;

    final eligibleDate = lastDonationDate!.add(const Duration(days: 150));
    if (DateTime.now().isBefore(eligibleDate)) {
      return eligibleDate.difference(DateTime.now()).inDays;
    }

    return null;
  }

  void updateBloodGroup(String value) {
    selectedBloodGroup = value;
    notifyListeners();
  }

  void updateNeverDonated(bool value) {
    neverDonated = value;
    notifyListeners();
  }

  void updateLastDonationDate(DateTime value) {
    lastDonationDate = value;
    notifyListeners();
  }

  String generateOtp() {
    generatedOtp = (1000 + Random().nextInt(9000)).toString();
    notifyListeners();
    return generatedOtp;
  }

  bool isOtpValid() => otpController.text.trim() == generatedOtp;

  Future<void> registerDonor() async {
    final token = await FirebaseMessaging.instance.getToken();
    final donationDate = neverDonated || lastDonationDate == null
        ? DateTime.now().subtract(const Duration(days: 3650))
        : lastDonationDate!;

    final donor = Donor(
      nic: nicController.text.trim().toUpperCase(),
      name: nameController.text.trim(),
      age: int.parse(ageController.text.trim()),
      phone: phoneController.text.trim(),
      bloodGroup: selectedBloodGroup,
      city: cityController.text.trim().toLowerCase(),
      lastDonationDate: donationDate,
      registeredAt: DateTime.now(),
      fcmToken: token,
    );

    await _donorRepository.saveDonor(donor);
    resetForm();
  }

  void resetForm() {
    nameController.clear();
    ageController.clear();
    phoneController.clear();
    cityController.clear();
    nicController.clear();
    otpController.clear();
    lastDonationDate = null;
    neverDonated = true;
    generatedOtp = '';
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    cityController.dispose();
    nicController.dispose();
    otpController.dispose();
    super.dispose();
  }
}
