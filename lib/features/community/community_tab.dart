import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

class CommunityTab extends StatelessWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.groups_outlined,
                  size: 72, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(l.communityTitle,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(l.communityComingSoon,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(l.communityComingSoonBody,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
