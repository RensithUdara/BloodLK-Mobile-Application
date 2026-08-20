import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/donor.dart';
import '../../services/contact_service.dart';

class DonorDetailsView extends StatelessWidget {
  DonorDetailsView({
    super.key,
    required this.donor,
    ContactService? contactService,
  }) : _contactService = contactService ?? ContactService();

  final Donor donor;
  final ContactService _contactService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bloodRed,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Donor Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.lightRed,
                child: Icon(Icons.person, color: AppColors.bloodRed, size: 40),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                donor.name.isEmpty ? 'Unnamed donor' : donor.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBrown,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.bloodRed.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.bloodtype,
                    label: 'Blood Group',
                    value: donor.bloodGroup,
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    icon: Icons.cake,
                    label: 'Age',
                    value: donor.age.toString(),
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    icon: Icons.phone,
                    label: 'Phone',
                    value: donor.phone.isEmpty ? 'N/A' : donor.phone,
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    icon: Icons.badge,
                    label: 'NIC',
                    value: donor.nic.isEmpty ? 'N/A' : donor.nic,
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    icon: Icons.location_on,
                    label: 'City',
                    value: donor.city.isEmpty ? 'N/A' : donor.city,
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: 'Last Donation Date',
                    value: _formatDate(donor.lastDonationDate),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: donor.phone.isEmpty
                        ? null
                        : () => _contactService.makeCall(donor.phone),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.call, color: Colors.white),
                    label: const Text(
                      'Call',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: donor.phone.isEmpty
                        ? null
                        : () => _contactService.sendSms(
                              phoneNumber: donor.phone,
                              message:
                                  'Hello, regarding blood donation (${donor.bloodGroup})...',
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bloodRed,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.message, color: Colors.white),
                    label: const Text(
                      'Message',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.bloodRed, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.subTextBrown,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBrown,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
