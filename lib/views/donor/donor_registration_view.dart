import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../viewmodels/donor_registration_view_model.dart';

class DonorRegistrationView extends StatelessWidget {
  const DonorRegistrationView({super.key});

  Future<void> _startRegistration(BuildContext context) async {
    final viewModel = context.read<DonorRegistrationViewModel>();
    final daysLeft = viewModel.daysUntilEligible();

    if (daysLeft != null) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Not eligible yet'),
          content: Text(
            'Five months have not passed since your last donation.\n\nYou can register in $daysLeft days.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    viewModel.generateOtp();
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('OTP Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'OTP: ${viewModel.generatedOtp}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            TextField(
              controller: viewModel.otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Enter 4-digit code'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _verifyOtpAndRegister(context),
            child: const Text('Verify & Register'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyOtpAndRegister(BuildContext context) async {
    final viewModel = context.read<DonorRegistrationViewModel>();

    if (!viewModel.isOtpValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context);

    try {
      await viewModel.registerDonor();
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registered successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final viewModel = context.read<DonorRegistrationViewModel>();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      viewModel.updateLastDonationDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DonorRegistrationViewModel>();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Become a Donor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.deepMaroon,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: AppColors.warmSurface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.bloodRed.withValues(alpha: 0.14),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(AppConstants.logoAsset, fit: BoxFit.cover),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: viewModel.nameController,
                decoration: _fieldDecoration('Full Name', Icons.person),
                validator: _required('Name is required'),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: viewModel.ageController,
                keyboardType: TextInputType.number,
                decoration: _fieldDecoration('Age', Icons.cake),
                validator: _required('Age is required'),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: viewModel.phoneController,
                keyboardType: TextInputType.phone,
                decoration: _fieldDecoration('Phone Number', Icons.phone),
                validator: _required('Phone number is required'),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: viewModel.nicController,
                decoration: _fieldDecoration('NIC Number', Icons.badge),
                validator: _required('NIC number is required'),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: viewModel.cityController,
                decoration: _fieldDecoration('Your City', Icons.location_on),
                validator: _required('City is required'),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: viewModel.selectedBloodGroup,
                decoration: _fieldDecoration('Blood Group', Icons.bloodtype),
                items: AppConstants.bloodGroups
                    .map(
                      (group) => DropdownMenuItem(
                        value: group,
                        child: Text(
                          group,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) viewModel.updateBloodGroup(value);
                },
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CheckboxListTile(
                  title: const Text('First time donor'),
                  value: viewModel.neverDonated,
                  activeColor: Colors.red,
                  onChanged: (value) =>
                      viewModel.updateNeverDonated(value ?? true),
                ),
              ),
              if (!viewModel.neverDonated)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.calendar_month,
                      color: Colors.red,
                    ),
                    title: Text(
                      viewModel.lastDonationDate == null
                          ? 'Select Date'
                          : DateFormat('yyyy-MM-dd')
                              .format(viewModel.lastDonationDate!),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bloodRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      _startRegistration(context);
                    }
                  },
                  child: const Text(
                    'Register as a Donor',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.red),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  FormFieldValidator<String> _required(String message) {
    return (value) => value == null || value.trim().isEmpty ? message : null;
  }
}
