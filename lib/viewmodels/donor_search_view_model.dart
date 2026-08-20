import 'package:flutter/material.dart';
import '../data/models/donor.dart';
import '../data/repositories/donor_repository.dart';
import '../services/contact_service.dart';

class DonorSearchViewModel extends ChangeNotifier {
  DonorSearchViewModel({
    DonorRepository? donorRepository,
    ContactService? contactService,
  })  : _donorRepository = donorRepository ?? DonorRepository(),
        _contactService = contactService ?? ContactService();

  final DonorRepository _donorRepository;
  final ContactService _contactService;

  final cityController = TextEditingController();
  String selectedBloodGroup = 'A+';
  String searchBlood = '';
  String searchCity = '';

  bool get hasSearch => searchBlood.isNotEmpty;

  void updateBloodGroup(String value) {
    selectedBloodGroup = value;
    notifyListeners();
  }

  void search() {
    searchBlood = selectedBloodGroup;
    searchCity = cityController.text.trim().toLowerCase();
    notifyListeners();
  }

  Stream<List<Donor>> watchDonors() {
    return _donorRepository.searchEligibleDonors(
      bloodGroup: searchBlood,
      city: searchCity,
    );
  }

  Future<void> callDonor(String phoneNumber) {
    return _contactService.makeCall(phoneNumber);
  }

  Future<void> messageDonor(Donor donor) {
    return _contactService.sendSms(
      phoneNumber: donor.phone,
      message:
          'Hello, I am looking for a ${donor.bloodGroup} blood donor urgently in $searchCity. Can you please help us?',
    );
  }

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }
}
