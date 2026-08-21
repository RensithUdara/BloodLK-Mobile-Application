import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/emergency_request.dart';
import '../../viewmodels/admin_view_model.dart';
import 'admin_page_shell.dart';

class AdminEmergencyRequestsView extends StatelessWidget {
  const AdminEmergencyRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminPageShell(
      title: 'Emergency Requests',
      child: StreamBuilder<List<EmergencyRequest>>(
        stream: context.watch<AdminViewModel>().watchEmergencyRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.bloodRed),
            );
          }

          if (snapshot.hasError) {
            return AdminEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Unable to load requests',
              message: snapshot.error.toString(),
            );
          }

          final requests = snapshot.data ?? const <EmergencyRequest>[];
          if (requests.isEmpty) {
            return const AdminEmptyState(
              icon: Icons.emergency_share_rounded,
              title: 'No emergency requests',
              message: 'Open requests posted by admins will appear here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            itemBuilder: (context, index) {
              return _EmergencyRequestCard(request: requests[index]);
            },
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemCount: requests.length,
          );
        },
      ),
    );
  }
}

class _EmergencyRequestCard extends StatelessWidget {
  const _EmergencyRequestCard({required this.request});

  final EmergencyRequest request;

  @override
  Widget build(BuildContext context) {
    return AdminSectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFFFECEE),
              shape: BoxShape.circle,
            ),
            child: Text(
              request.bloodGroup,
              style: const TextStyle(
                color: AppColors.bloodRed,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.patientName.isEmpty
                      ? 'Emergency request'
                      : request.patientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF171D24),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                _RequestLine(
                  icon: Icons.location_on_rounded,
                  text: request.location.isEmpty
                      ? 'No location'
                      : request.location,
                ),
                const SizedBox(height: 4),
                _RequestLine(
                  icon: Icons.call_rounded,
                  text: request.contactNumber.isEmpty
                      ? 'No contact number'
                      : request.contactNumber,
                ),
                if (request.note.trim().isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    request.note,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6A7380),
                      fontSize: 12,
                      height: 1.28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestLine extends StatelessWidget {
  const _RequestLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.bloodRed, size: 15),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6A7380),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
