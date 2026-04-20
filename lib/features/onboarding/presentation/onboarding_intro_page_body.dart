import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:opennutritracker/core/presentation/widgets/app_banner_version.dart';
import 'package:opennutritracker/core/utils/app_const.dart';
import 'package:opennutritracker/core/utils/url_const.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardingIntroPageBody extends StatefulWidget {
  final Function(bool active, bool acceptedDataCollection) setPageContent;
  final bool initialAcceptedPolicy;
  final bool initialAcceptedDataCollection;

  const OnboardingIntroPageBody({
    super.key,
    required this.setPageContent,
    this.initialAcceptedPolicy = false,
    this.initialAcceptedDataCollection = false,
  });

  @override
  State<OnboardingIntroPageBody> createState() =>
      _OnboardingIntroPageBodyState();
}

class _OnboardingIntroPageBodyState extends State<OnboardingIntroPageBody> {
  bool _acceptedPolicy = false;
  bool _acceptedDataCollection = false;

  @override
  void initState() {
    super.initState();
    _acceptedPolicy = widget.initialAcceptedPolicy;
    _acceptedDataCollection = widget.initialAcceptedDataCollection;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AppConst.getVersionNumber(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        return SingleChildScrollView(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: Column(
              key: const ValueKey('onboarding-intro-loaded'),
              children: [
                AppBannerVersion(versionNumber: snapshot.requireData),
                const SizedBox(height: 20),
                _buildInfoCard(context),
                const SizedBox(height: 16),
                _buildConsentCard(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.favorite_rounded,
              color: Theme.of(context).colorScheme.primary, size: 36),
          const SizedBox(height: 12),
          /*Text(
            S.of(context).appDescription,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),*/
          Text(
            S.of(context).onboardingIntroDescription,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConsentCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          _buildCheckboxRow(
            context,
            title: Text.rich(
              TextSpan(
                text: S.of(context).readLabel,
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: ' ${S.of(context).privacyPolicyLabel}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                    recognizer: TapGestureRecognizer()..onTap = _launchUrl,
                  ),
                ],
              ),
              textAlign: TextAlign.left,
            ),
            value: _acceptedPolicy,
            onToggle: _togglePolicy,
          ),
          const Divider(height: 1),
          _buildCheckboxRow(
            context,
            title: Text(
              S.of(context).dataCollectionLabel,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            value: _acceptedDataCollection,
            onToggle: _toggleDataCollection,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow(
    BuildContext context, {
    required Widget title,
    required bool value,
    required VoidCallback onToggle,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Checkbox(value: value, onChanged: (_) => onToggle()),
            const SizedBox(width: 8),
            Expanded(child: title),
          ],
        ),
      ),
    );
  }

  void _togglePolicy() {
    setState(() {
      _acceptedPolicy = !_acceptedPolicy;
      widget.setPageContent(_acceptedPolicy, _acceptedDataCollection);
    });
  }

  void _toggleDataCollection() {
    setState(() {
      _acceptedDataCollection = !_acceptedDataCollection;
      widget.setPageContent(_acceptedPolicy, _acceptedDataCollection);
    });
  }

  Future<void> _launchUrl() async {
    await launchUrl(Uri.parse(URLConst.privacyPolicyURLEn),
        mode: LaunchMode.externalApplication);
  }
}
