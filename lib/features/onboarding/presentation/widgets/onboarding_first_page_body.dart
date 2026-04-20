import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opennutritracker/features/onboarding/domain/entity/user_gender_selection_entity.dart';
import 'package:opennutritracker/generated/l10n.dart';

class OnboardingFirstPageBody extends StatefulWidget {
  final Function(
          bool active, UserGenderSelectionEntity? gender, DateTime? birthday)
      setPageContent;
  final UserGenderSelectionEntity? initialGender;
  final DateTime? initialBirthday;

  const OnboardingFirstPageBody(
      {super.key,
      required this.setPageContent,
      this.initialGender,
      this.initialBirthday});

  @override
  State<OnboardingFirstPageBody> createState() =>
      _OnboardingFirstPageBodyState();
}

class _OnboardingFirstPageBodyState extends State<OnboardingFirstPageBody> {
  final _dateInput = TextEditingController();
  DateTime? _selectedDate;

  bool _maleSelected = false;
  bool _femaleSelected = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialBirthday;
    if (_selectedDate != null) {
      _dateInput.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    }

    if (widget.initialGender == UserGenderSelectionEntity.genderMale) {
      _maleSelected = true;
      _femaleSelected = false;
    } else if (widget.initialGender == UserGenderSelectionEntity.genderFemale) {
      _maleSelected = false;
      _femaleSelected = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        checkCorrectInput();
      }
    });
  }

  @override
  void dispose() {
    _dateInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context).onboardingStepGenderAge,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          _buildSectionCard(
            context,
            title: S.of(context).genderLabel,
            subtitle: S.of(context).onboardingGenderQuestionSubtitle,
            child: Row(
              children: [
                Expanded(
                  child: _buildGenderOption(
                    context,
                    label: S.of(context).genderMaleLabel,
                    icon: Icons.male_rounded,
                    selected: _maleSelected,
                    onTap: () {
                      setState(() {
                        _maleSelected = true;
                        _femaleSelected = false;
                        checkCorrectInput();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildGenderOption(
                    context,
                    label: S.of(context).genderFemaleLabel,
                    icon: Icons.female_rounded,
                    selected: _femaleSelected,
                    onTap: () {
                      setState(() {
                        _maleSelected = false;
                        _femaleSelected = true;
                        checkCorrectInput();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildSectionCard(
            context,
            title: S.of(context).ageLabel,
            subtitle: S.of(context).onboardingBirthdayQuestionSubtitle,
            child: TextFormField(
              controller: _dateInput,
              readOnly: true,
              decoration: InputDecoration(
                hintText: S.of(context).onboardingEnterBirthdayLabel,
                labelText: S.of(context).onboardingEnterBirthdayLabel,
                prefixIcon: const Icon(Icons.calendar_month_outlined),
                suffixIcon: const Icon(Icons.chevron_right_rounded),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onTap: onDateInputClicked,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context,
      {required String title,
      required String subtitle,
      required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildGenderOption(BuildContext context,
      {required String label,
      required IconData icon,
      required bool selected,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.14)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.25),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void onDateInputClicked() async {
    final pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now());
    if (pickedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        _selectedDate = pickedDate;
        _dateInput.text = formattedDate;
        checkCorrectInput();
      });
    }
  }

  void checkCorrectInput() {
    UserGenderSelectionEntity? selectedGender;
    if (_maleSelected) {
      selectedGender = UserGenderSelectionEntity.genderMale;
    } else if (_femaleSelected) {
      selectedGender = UserGenderSelectionEntity.genderFemale;
    }

    if (selectedGender != null && _selectedDate != null) {
      widget.setPageContent(true, selectedGender, _selectedDate);
    } else {
      widget.setPageContent(false, null, null);
    }
  }
}
