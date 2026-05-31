import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/locale_controller.dart';
import '../../core/auth/auth_providers.dart';
import '../../core/format.dart';
import '../../core/jaap/jaap_providers.dart';
import '../../core/jaap/mantras.dart';
import '../../l10n/generated/app_localizations.dart';
import '../add/add_entry_sheet.dart';
import 'widgets/jaap_ring.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final localeCode =
        (ref.watch(localeProvider) ?? Localizations.localeOf(context))
            .languageCode;
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final firstName = (profile?.displayName ?? '').split(' ').first;
    final goal = profile?.dailyGoal ?? 1000;
    final today = ref.watch(todayCountProvider);
    final progress = goal == 0 ? 0.0 : today / goal;
    final streak = ref.watch(currentStreakProvider);
    final last = ref.watch(lastSessionProvider);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      firstName.isEmpty
                          ? l.namaste
                          : '${l.namaste}, $firstName',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: l.viewTarget,
                    onPressed: () => context.push('/target'),
                    icon: const Icon(Icons.flag_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: JaapRing(
                  progress: progress.clamp(0.0, 1.0).toDouble(),
                  size: 260,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l.today.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            letterSpacing: 1.4,
                          )),
                      const SizedBox(height: 8),
                      Text(
                        formatNumber(today, localeCode),
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '/ ${formatNumber(goal, localeCode)} ${l.goal.toLowerCase()}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickAddChip(amount: 1),
                  _QuickAddChip(amount: 11),
                  _QuickAddChip(amount: 27),
                  _QuickAddChip(amount: 108),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => showAddEntrySheet(context),
                icon: const Icon(Icons.add_circle_outline),
                label: Text(l.addCustomCount),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.access_time,
                      label: l.lastSession,
                      value: last == null
                          ? l.noSessionsYet
                          : relativeTime(last.createdAt, l),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.calendar_month_outlined,
                      label: l.streak,
                      value: '$streak ${l.daysUnit}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAddChip extends ConsumerWidget {
  const _QuickAddChip({required this.amount});
  final int amount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () async {
        final svc = ref.read(jaapServiceProvider);
        await svc.addSession(
          count: amount,
          mantra: Mantra.navkar,
          source: 'quick',
        );
      },
      child: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.primary,
          shape: BoxShape.circle,
        ),
        child: Text(
          '+$amount',
          style: TextStyle(
            color: scheme.onPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
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
            Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
            const SizedBox(height: 4),
            Text(value,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
