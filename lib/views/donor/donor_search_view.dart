import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/donor.dart';
import '../../viewmodels/donor_search_view_model.dart';

class DonorSearchView extends StatelessWidget {
  const DonorSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DonorSearchViewModel>();

    return Scaffold(
      backgroundColor: AppColors.warmSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bloodRed,
        title: const Text(
          'Find Blood Donors',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: viewModel.selectedBloodGroup,
              decoration:
                  _inputDecoration('Select Blood Group', Icons.bloodtype),
              items: AppConstants.bloodGroups
                  .map((group) =>
                      DropdownMenuItem(value: group, child: Text(group)))
                  .toList(),
              onChanged: (value) {
                if (value != null) viewModel.updateBloodGroup(value);
              },
            ),
            const SizedBox(height: 15),
            TextField(
              controller: viewModel.cityController,
              decoration: _inputDecoration('Enter City', Icons.location_on),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: viewModel.search,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bloodRed,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.search, color: Colors.white),
              label: const Text(
                'Search Donors',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: !viewModel.hasSearch
                  ? const _EmptySearchPrompt()
                  : StreamBuilder<List<Donor>>(
                      stream: viewModel.watchDonors(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.bloodRed,
                            ),
                          );
                        }

                        final donors = snapshot.data ?? const <Donor>[];
                        if (donors.isEmpty) {
                          return const Center(
                            child: Text(
                              'No eligible donors found in this city right now.',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: donors.length,
                          itemBuilder: (context, index) {
                            final donor = donors[index];
                            return _DonorCard(
                              donor: donor,
                              onCall: () => viewModel.callDonor(donor.phone),
                              onMessage: () => viewModel.messageDonor(donor),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.bloodRed),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _EmptySearchPrompt extends StatelessWidget {
  const _EmptySearchPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 10),
          const Text(
            'Enter details above to find donors',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _DonorCard extends StatelessWidget {
  const _DonorCard({
    required this.donor,
    required this.onCall,
    required this.onMessage,
  });

  final Donor donor;
  final VoidCallback onCall;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFFFFE8E6),
              child: Text(
                donor.bloodGroup,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepMaroon,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donor.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Age: ${donor.age} | City: ${donor.city.toUpperCase()}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.green, size: 28),
              onPressed: onCall,
            ),
            IconButton(
              icon: const Icon(Icons.message, color: Colors.blue, size: 28),
              onPressed: onMessage,
            ),
          ],
        ),
      ),
    );
  }
}
