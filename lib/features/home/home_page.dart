import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/locale_controller.dart';
import '../../core/auth/auth_providers.dart';
import '../../l10n/generated/app_localizations.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final currentLocale = ref.watch(localeProvider) ??
        Localizations.localeOf(context);
    final greetingName = profile?.displayName.isNotEmpty == true
        ? profile!.displayName
        : (user?.displayName ?? user?.email ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        actions: [
          PopupMenuButton<Locale>(
            tooltip: l.switchLanguage,
            icon: const Icon(Icons.language_outlined),
            initialValue: currentLocale,
            onSelected: (loc) =>
                ref.read(localeProvider.notifier).state = loc,
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: const Locale('en'),
                child: Text(l.languageEnglish),
              ),
              PopupMenuItem(
                value: const Locale('hi'),
                child: Text(l.languageHindi),
              ),
            ],
          ),
          IconButton(
            tooltip: l.signOut,
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  greetingName.isEmpty
                      ? l.welcome
                      : '${l.welcome}, $greetingName',
                  style: theme.textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l.tagline,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (profile != null) ...[
                  const SizedBox(height: 32),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ProfileRow(label: l.fullName, value: profile.displayName),
                          _ProfileRow(label: l.gotra, value: profile.gotra),
                          _ProfileRow(
                            label: l.temple,
                            value: profile.temple == 'gyanodaya'
                                ? l.templeGyanodaya
                                : profile.temple,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: t.labelMedium),
          ),
          Expanded(child: Text(value, style: t.bodyMedium)),
        ],
      ),
    );
  }
}
