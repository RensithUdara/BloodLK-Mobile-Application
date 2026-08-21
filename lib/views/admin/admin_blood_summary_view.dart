import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/donor.dart';
import '../../viewmodels/admin_view_model.dart';
import 'admin_page_shell.dart';

class AdminBloodSummaryView extends StatelessWidget {
  const AdminBloodSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminPageShell(
      title: 'Blood Summary',
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
              title: 'Unable to load summary',
              message: snapshot.error.toString(),
            );
          }

          final donors = snapshot.data ?? const <Donor>[];
          final counts = {
            for (final group in AppConstants.bloodGroups) group: 0,
          };

          for (final donor in donors) {
            if (counts.containsKey(donor.bloodGroup)) {
              counts[donor.bloodGroup] = counts[donor.bloodGroup]! + 1;
            }
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.55,
            ),
            itemCount: AppConstants.bloodGroups.length,
            itemBuilder: (context, index) {
              final group = AppConstants.bloodGroups[index];
              return AdminSectionCard(
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
                        Icons.bloodtype_rounded,
                        color: AppColors.bloodRed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group,
                            style: const TextStyle(
                              color: Color(0xFF171D24),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${counts[group]} donors',
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
            },
          );
        },
      ),
    );
  }
}
