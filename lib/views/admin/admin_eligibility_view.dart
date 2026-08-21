import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/donor.dart';
import '../../viewmodels/admin_view_model.dart';
import 'admin_page_shell.dart';

class AdminEligibilityView extends StatelessWidget {
  const AdminEligibilityView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminPageShell(
      title: 'Eligibility',
      child: StreamBuilder<List<Donor>>(
        stream: context.watch<AdminViewModel>().watchDonors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.bloodRed),
            );
          }

          if (snapshot.hasError) {
            return AdminEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Unable to load eligibility',
              message: snapshot.error.toString(),
            );
          }

          final donors = snapshot.data ?? const <Donor>[];
          if (donors.isEmpty) {
            return const AdminEmptyState(
              icon: Icons.event_available_rounded,
              title: 'No donors available',
              message: 'Registered donors will appear here.',
            );
          }

          final now = DateTime.now();
          final eligible = donors.where((donor) {
            final lastDate = donor.lastDonationDate;
            if (lastDate == null) return true;
            return !lastDate.add(const Duration(days: 150)).isAfter(now);
          }).toList(growable: false);

          final waiting = donors.length - eligible.length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _CountCard(
                      title: 'Eligible',
                      count: eligible.length,
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _CountCard(
                      title: 'Waiting',
                      count: waiting,
                      icon: Icons.hourglass_bottom_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Eligible donors',
                style: TextStyle(
                  color: Color(0xFF2B171A),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              if (eligible.isEmpty)
                const AdminSectionCard(
                  child: Text(
                    'No donors are eligible right now.',
                    style: TextStyle(
                      color: Color(0xFF6A7380),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                ...eligible.map(
                  (donor) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _EligibleDonorTile(donor: donor),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.title,
    required this.count,
    required this.icon,
  });

  final String title;
  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AdminSectionCard(
      child: Row(
        children: [
          Icon(icon, color: AppColors.bloodRed, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Color(0xFF171D24),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF6A7380),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

class _EligibleDonorTile extends StatelessWidget {
  const _EligibleDonorTile({required this.donor});

  final Donor donor;

  @override
  Widget build(BuildContext context) {
    return AdminSectionCard(
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFFFECEE),
            child: Icon(Icons.person_rounded, color: AppColors.bloodRed),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donor.name.isEmpty ? 'Unnamed donor' : donor.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF171D24),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${donor.bloodGroup}  ${donor.city}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6A7380),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
