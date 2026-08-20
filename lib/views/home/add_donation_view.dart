import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/donation_record.dart';
import '../../data/repositories/donation_repository.dart';

class AddDonationView extends StatefulWidget {
  const AddDonationView({super.key});

  @override
  State<AddDonationView> createState() => _AddDonationViewState();
}

class _AddDonationViewState extends State<AddDonationView> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _repository = DonationRepository();
  final _dateFormat = DateFormat('dd MMM yyyy');

  DateTime? _donationDate;
  int _patientCount = 1;
  bool _isSaving = false;

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _donationDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
      helpText: 'Select donation date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.bloodRed,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;
    setState(() => _donationDate = picked);
  }

  Future<void> _saveDonation() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _donationDate == null) {
      if (_donationDate == null) {
        _showSnackBar('Please select donation date');
      }
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _repository.saveDonation(
        DonationRecord(
          donationDate: _donationDate!,
          patientCount: _patientCount,
          location: _locationController.text,
        ),
      );

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => _DonationSavedDialog(
          dateText: _dateFormat.format(_donationDate!),
          patientCount: _patientCount,
        ),
      );

      if (!mounted) return;
      setState(() {
        _donationDate = null;
        _patientCount = 1;
      });
      _locationController.clear();
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(error.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.bloodRed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _DonationBackdrop())),
          SafeArea(
            child: Column(
              children: [
                const _DonationAppBar(title: 'Add Donations'),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      children: [
                        _SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _Label('Donation Date'),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: _pickDate,
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 15,
                                  ),
                                  decoration: _fieldDecoration(),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_month_rounded,
                                        color: AppColors.bloodRed,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _donationDate == null
                                              ? 'Select donation date'
                                              : _dateFormat
                                                  .format(_donationDate!),
                                          style: TextStyle(
                                            color: _donationDate == null
                                                ? const Color(0xFF8A9099)
                                                : const Color(0xFF171D24),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              const _Label('Patients Helped'),
                              const SizedBox(height: 8),
                              Row(
                                children: [1, 2, 3]
                                    .map(
                                      (count) => Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            right: count == 3 ? 0 : 8,
                                          ),
                                          child: _PatientChoice(
                                            count: count,
                                            selected: _patientCount == count,
                                            onTap: () => setState(
                                              () => _patientCount = count,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 18),
                              const _Label('Location'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _locationController,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  hintText:
                                      'Hospital, blood bank, or camp name',
                                  prefixIcon: const Icon(
                                    Icons.location_on_rounded,
                                    color: AppColors.bloodRed,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFFFFBFB),
                                  border: _inputBorder(),
                                  enabledBorder: _inputBorder(),
                                  focusedBorder: _inputBorder(
                                    color: AppColors.bloodRed,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter donation location';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: _isSaving ? null : _saveDonation,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_rounded),
                          label:
                              Text(_isSaving ? 'Saving...' : 'Save Donation'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.bloodRed,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _fieldDecoration() {
    return BoxDecoration(
      color: const Color(0xFFFFFBFB),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFFFE6E8)),
    );
  }

  OutlineInputBorder _inputBorder({Color color = const Color(0xFFFFE6E8)}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );
  }
}

class _DonationAppBar extends StatelessWidget {
  const _DonationAppBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 18, 8),
      child: Row(
        children: [
          IconButton.filled(
            tooltip: 'Back',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.bloodRed,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightRed.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF171D24),
        fontSize: 13,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _PatientChoice extends StatelessWidget {
  const _PatientChoice({
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.bloodRed : const Color(0xFFFFFBFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.bloodRed : const Color(0xFFFFE6E8),
          ),
        ),
        child: Text(
          '$count',
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF303942),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _DonationSavedDialog extends StatelessWidget {
  const _DonationSavedDialog({
    required this.dateText,
    required this.patientCount,
  });

  final String dateText;
  final int patientCount;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEE),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.lightRed.withValues(alpha: 0.9),
                ),
              ),
              child: const Icon(
                Icons.volunteer_activism_rounded,
                color: AppColors.bloodRed,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Thank you, life saver!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF171D24),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your donation has been saved successfully. Your kindness can help $patientCount patient${patientCount == 1 ? '' : 's'}.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF5D6673),
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFE6E8)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.bloodRed,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      dateText,
                      style: const TextStyle(
                        color: Color(0xFF171D24),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.bloodRed,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonationBackdrop extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    final rect = Rect.fromLTWH(0, 0, size.width, 170);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE71920), Color(0xFFC9000B)],
        ).createShader(rect),
    );

    final wave = Path()
      ..moveTo(0, 128)
      ..cubicTo(size.width * 0.18, 100, size.width * 0.42, 150, size.width, 116)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(wave, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
