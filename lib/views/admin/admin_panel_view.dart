import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/donor.dart';
import '../../viewmodels/admin_view_model.dart';
import '../donor/donor_details_view.dart';

class AdminPanelView extends StatelessWidget {
  const AdminPanelView({super.key});

  Future<void> _sendNotification(
    BuildContext context,
    String bloodType,
  ) async {
    final viewModel = context.read<AdminViewModel>();

    try {
      final count = await viewModel.sendGroupNotification(bloodType);
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.bloodRed,
          content: Text('$bloodType: notification sent to $count donors'),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminViewModel>();

    return Scaffold(
      backgroundColor: AppColors.warmSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bloodRed,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Admin Panel',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Send group notification',
                style: TextStyle(
                  color: AppColors.textBrown,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.bloodGroups.map((type) {
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _sendNotification(context, type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bloodRed,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.bloodRed.withValues(alpha: 0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 18, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Donors',
                style: TextStyle(
                  color: AppColors.textBrown,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Donor>>(
              stream: viewModel.watchDonors(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(
                          color: AppColors.bloodRed,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.bloodRed,
                    ),
                  );
                }

                final donors = snapshot.data!;
                if (donors.isEmpty) {
                  return const Center(
                    child: Text(
                      'No donors found',
                      style: TextStyle(
                        color: AppColors.subTextBrown,
                        fontSize: 15,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  itemCount: donors.length,
                  itemBuilder: (context, index) {
                    final donor = donors[index];
                    return _DonorListTile(donor: donor);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DonorListTile extends StatelessWidget {
  const _DonorListTile({required this.donor});

  final Donor donor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonorDetailsView(donor: donor),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.lightRed,
              child: Icon(Icons.person, color: AppColors.bloodRed),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donor.name.isEmpty ? 'Unnamed donor' : donor.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textBrown,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.bloodtype,
                        size: 15,
                        color: AppColors.bloodRed,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Blood group: ${donor.bloodGroup}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.subTextBrown,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFC99B90)),
          ],
        ),
      ),
    );
  }
}
