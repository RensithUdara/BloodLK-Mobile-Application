import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/donation_center.dart';
import '../../viewmodels/admin_view_model.dart';
import '../../widgets/custom_app_dialog.dart';
import 'admin_page_shell.dart';

class AdminDonationCentersView extends StatefulWidget {
  const AdminDonationCentersView({super.key});

  @override
  State<AdminDonationCentersView> createState() =>
      _AdminDonationCentersViewState();
}

class _AdminDonationCentersViewState extends State<AdminDonationCentersView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _district = 'Badulla';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveCenter() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      await context.read<AdminViewModel>().saveDonationCenter(
            DonationCenter(
              id: '',
              name: _nameController.text,
              contactNumber: _phoneController.text,
              address: _addressController.text,
              district: _district,
            ),
          );

      if (!mounted) return;
      _nameController.clear();
      _phoneController.clear();
      _addressController.clear();

      await showDialog<void>(
        context: context,
        builder: (context) => CustomAppDialog(
          icon: Icons.local_hospital_rounded,
          title: 'Center saved',
          message: 'Donation center details were saved successfully.',
          primaryText: 'OK',
          onPrimary: () => Navigator.pop(context),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => CustomAppDialog(
          icon: Icons.error_outline_rounded,
          title: 'Unable to save',
          message: error.toString(),
          primaryText: 'OK',
          destructive: true,
          onPrimary: () => Navigator.pop(context),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageShell(
      title: 'Donation Centers',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          AdminSectionCard(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add donation center',
                    style: TextStyle(
                      color: Color(0xFF2B171A),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Center name'),
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration('Contact number'),
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _addressController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: _inputDecoration('Center address'),
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _district,
                    isExpanded: true,
                    itemHeight: 48,
                    menuMaxHeight: 240,
                    decoration: _inputDecoration('District'),
                    borderRadius: BorderRadius.circular(14),
                    items: DonationDistricts.values
                        .where((district) => district != DonationDistricts.all)
                        .map(
                          (district) => DropdownMenuItem(
                            value: district,
                            child: Text(
                              district,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _district = value);
                    },
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _saveCenter,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.bloodRed,
                      disabledBackgroundColor: const Color(0xFFFFC9CE),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(
                      _isSaving ? 'Saving...' : 'Save Center',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Saved centers',
            style: TextStyle(
              color: Color(0xFF2B171A),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<DonationCenter>>(
            stream: context.watch<AdminViewModel>().watchDonationCenters(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 34),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.bloodRed),
                  ),
                );
              }

              if (snapshot.hasError) {
                return AdminSectionCard(
                  child: Text(
                    'Unable to load centers: ${snapshot.error}',
                    style: const TextStyle(
                      color: AppColors.bloodRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }

              final centers = snapshot.data ?? const <DonationCenter>[];
              if (centers.isEmpty) {
                return const AdminSectionCard(
                  child: Text(
                    'No donation centers available.',
                    style: TextStyle(
                      color: Color(0xFF6A7380),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }

              return Column(
                children: centers
                    .map(
                      (center) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _CenterListTile(center: center),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }
}

class _CenterListTile extends StatelessWidget {
  const _CenterListTile({required this.center});

  final DonationCenter center;

  @override
  Widget build(BuildContext context) {
    return AdminSectionCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFFFFECEE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: AppColors.bloodRed,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  center.name.isEmpty ? 'Unnamed center' : center.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF171D24),
                    fontSize: 14,
                    height: 1.14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                _CenterLine(
                  icon: Icons.call_rounded,
                  text: center.contactNumber.isEmpty
                      ? 'No contact number'
                      : center.contactNumber,
                ),
                const SizedBox(height: 5),
                _CenterLine(
                  icon: Icons.location_on_rounded,
                  text: center.address.isEmpty ? 'No address' : center.address,
                ),
                const SizedBox(height: 5),
                _CenterLine(
                  icon: Icons.map_rounded,
                  text:
                      center.district.isEmpty ? 'No district' : center.district,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterLine extends StatelessWidget {
  const _CenterLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.bloodRed, size: 15),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6A7380),
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    filled: true,
    fillColor: const Color(0xFFFFFAFA),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    border: _fieldBorder(),
    enabledBorder: _fieldBorder(),
    focusedBorder: _fieldBorder(color: AppColors.bloodRed),
    errorBorder: _fieldBorder(color: AppColors.bloodRed),
    focusedErrorBorder: _fieldBorder(color: AppColors.bloodRed),
  );
}

OutlineInputBorder _fieldBorder({Color color = const Color(0xFFFFD9D9)}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: color),
  );
}
