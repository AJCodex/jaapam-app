import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// Static Privacy Policy page. Plain text — no third-party telemetry beyond
/// Firebase Analytics, no payment data, no location.
///
/// The temple admin / maintainer should review and adjust this copy before
/// rolling out to a new temple instance.
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _LegalScaffold(
      title: l.privacyPolicy,
      sections: [
        _Section(intro: l.privacyIntro),
        _Section(heading: l.privacyDataCollected, body: l.privacyDataCollectedBody),
        _Section(heading: l.privacyDataNotCollected, body: l.privacyDataNotCollectedBody),
        _Section(heading: l.privacyAccess, body: l.privacyAccessBody),
      ],
    );
  }
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _LegalScaffold(
      title: l.termsOfService,
      sections: [
        _Section(intro: l.termsIntro),
        _Section(heading: l.termsAcceptableUse, body: l.termsAcceptableUseBody),
        _Section(heading: l.termsAvailability, body: l.termsAvailabilityBody),
        _Section(heading: l.termsLiability, body: l.termsLiabilityBody),
      ],
    );
  }
}

class _LegalScaffold extends StatelessWidget {
  const _LegalScaffold({required this.title, required this.sections});
  final String title;
  final List<_Section> sections;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              Text('${l.legalUpdated}: 2026-06-01',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  )),
              const SizedBox(height: 16),
              for (final s in sections) ...[
                if (s.heading != null) ...[
                  Text(s.heading!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 8),
                ],
                Text(s.intro ?? s.body!,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Section {
  const _Section({this.intro, this.heading, this.body})
      : assert(intro != null || body != null);
  final String? intro;
  final String? heading;
  final String? body;
}
