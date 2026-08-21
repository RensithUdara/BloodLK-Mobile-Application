import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/donation_center.dart';
import '../../data/models/donor.dart';
import '../../viewmodels/admin_view_model.dart';
import '../donor/donor_details_view.dart';
import 'admin_page_shell.dart';

class AdminDonorsView extends StatefulWidget {
  const AdminDonorsView({super.key});

  @override
  State<AdminDonorsView> createState() => _AdminDonorsViewState();
}

class _AdminDonorsViewState extends State<AdminDonorsView> {
  final _searchController = TextEditingController();
  String _selectedDistrict = DonationDistricts.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageShell(
      title: 'Donors',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search donors',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.bloodRed,
                    ),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    border: _inputBorder(),
                    enabledBorder: _inputBorder(),
                    focusedBorder: _inputBorder(color: AppColors.bloodRed),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _selectedDistrict,
                  isExpanded: true,
                  itemHeight: 48,
                  menuMaxHeight: 240,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.map_rounded,
                      color: AppColors.bloodRed,
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                    filled: true,
                    fillColor: Colors.white,
                    border: _inputBorder(),
                    enabledBorder: _inputBorder(),
                    focusedBorder: _inputBorder(color: AppColors.bloodRed),
                  ),
                  borderRadius: BorderRadius.circular(14),
                  items: DonationDistricts.values
                      .map(
                        (district) => DropdownMenuItem(
                          value: district,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              district,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedDistrict = value);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Donor>>(
              stream: context.watch<AdminViewModel>().watchDonors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.bloodRed,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return AdminEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Unable to load donors',
                    message: snapshot.error.toString(),
                  );
                }

                final allDonors = snapshot.data ?? const <Donor>[];
                if (allDonors.isEmpty) {
                  return const AdminEmptyState(
                    icon: Icons.groups_rounded,
                    title: 'No donors available',
                    message: 'Registered donors will appear here.',
                  );
                }

                final donors = allDonors
                    .where(
                      (donor) =>
                          _matchesSearch(donor, _searchController.text) &&
                          _matchesDistrict(donor, _selectedDistrict),
                    )
                    .toList(growable: false);

                if (donors.isEmpty) {
                  return const AdminEmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No matching donors',
                    message: 'Try a different search or district.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  itemBuilder: (context, index) {
                    return _DonorCard(donor: donors[index]);
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemCount: donors.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _matchesSearch(Donor donor, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    return donor.name.toLowerCase().contains(normalizedQuery) ||
        donor.phone.toLowerCase().contains(normalizedQuery) ||
        donor.nic.toLowerCase().contains(normalizedQuery) ||
        donor.bloodGroup.toLowerCase().contains(normalizedQuery) ||
        donor.city.toLowerCase().contains(normalizedQuery);
  }

  bool _matchesDistrict(Donor donor, String district) {
    if (district == DonationDistricts.all) return true;
    return donor.city.trim().toLowerCase() == district.toLowerCase();
  }

  OutlineInputBorder _inputBorder({Color color = const Color(0xFFFFE6E8)}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
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
