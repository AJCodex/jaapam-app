import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/locale_controller.dart';
import '../../l10n/generated/app_localizations.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currentLocale = ref.watch(localeProvider) ??
        Localizations.localeOf(context);

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
                  l.welcome,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
