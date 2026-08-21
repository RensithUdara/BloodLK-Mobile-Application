import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/donor.dart';
import '../../viewmodels/admin_view_model.dart';
import '../donor/donor_details_view.dart';
import 'admin_page_shell.dart';

class AdminDonorsView extends StatelessWidget {
  const AdminDonorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminPageShell(
      title: 'Donors',
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
              title: 'Unable to load donors',
              message: snapshot.error.toString(),
            );
          }

          final donors = snapshot.data ?? const <Donor>[];
          if (donors.isEmpty) {
            return const AdminEmptyState(
              icon: Icons.groups_rounded,
              title: 'No donors available',
              message: 'Registered donors will appear here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            itemBuilder: (context, index) => _DonorCard(donor: donors[index]),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemCount: donors.length,
          );
        },
      ),
    );
  }
}

class _DonorCard extends StatelessWidget {
  const _DonorCard({required this.donor});

  final Donor donor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DonorDetailsView(donor: donor)),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFE2E2)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFECEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.bloodRed,
                  size: 28,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donor.name.isEmpty ? 'Unnamed donor' : donor.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF2B171A),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.bloodtype_rounded,
                          color: AppColors.bloodRed,
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            '${donor.bloodGroup}  ${donor.city}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF7B6670),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFD9A1A4)),
            ],
          ),
        ),
      ),
    );
  }
}
