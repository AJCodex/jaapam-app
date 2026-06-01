import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/locale_controller.dart';
import '../../core/auth/auth_providers.dart';
import '../../core/format.dart';
import '../../core/jaap/jaap_providers.dart';
import '../../l10n/generated/app_localizations.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final user = ref.watch(currentUserProvider);
    final localeCode =
        (ref.watch(localeProvider) ?? Localizations.localeOf(context))
            .languageCode;
    final malas = ref.watch(lifetimeMalasProvider);
    final streak = ref.watch(currentStreakProvider);
    final since = profile?.createdAt ?? user?.metadata.creationTime;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: theme.colorScheme.tertiary,
                child: Text(
                  _initials(profile?.displayName ?? user?.email ?? '?'),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                profile?.displayName.isNotEmpty == true
                    ? profile!.displayName
                    : (user?.email ?? ''),
                style: theme.textTheme.headlineSmall,
              ),
              if (since != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l.practitionerSince(monthYear(since.toLocal(), localeCode)),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _StatBox(
                label: l.totalMalas,
                value: formatNumber(malas, localeCode),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatBox(
                label: l.dailyStreak,
                value: '$streak ${l.daysUnit}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(l.preferences.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            )),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text(l.dailyGoalLabel),
                trailing: Text(
                  formatNumber(profile?.dailyGoal ?? 1, localeCode),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => _editDailyGoal(context, ref, profile?.dailyGoal ?? 1000),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.notifications_none),
                title: Text(l.notifications),
                trailing: Text(l.comingSoon,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: Text(l.theme),
                trailing: Text(l.themeSystem,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.translate),
                title: Text(l.appLanguage),
                trailing: DropdownButton<Locale>(
                  value: ref.watch(localeProvider) ??
                      Localizations.localeOf(context),
                  underline: const SizedBox.shrink(),
                  onChanged: (loc) =>
                      ref.read(localeProvider.notifier).state = loc,
                  items: [
                    DropdownMenuItem(
                      value: const Locale('en'),
                      child: Text(l.languageEnglish),
                    ),
                    DropdownMenuItem(
                      value: const Locale('hi'),
                      child: Text(l.languageHindi),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(l.privacySecurity.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            )),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: Text(l.privacyPolicy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => ref.read(authServiceProvider).signOut(),
          icon: const Icon(Icons.logout),
          label: Text(l.signOut),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(color: theme.colorScheme.error),
          ),
        ),
      ],
    );
  }

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Future<void> _editDailyGoal(
      BuildContext context, WidgetRef ref, int current) async {
    final l = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: current.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.editDailyGoal),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l.dailyGoalLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text.trim());
              if (v != null && v > 0) Navigator.pop(context, v);
            },
            child: Text(l.save),
          ),
        ],
      ),
    );
    if (result != null) {
      try {
        await ref.read(jaapServiceProvider).setDailyGoal(result);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                )),
            const SizedBox(height: 6),
            Text(value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ),
    );
  }
}
