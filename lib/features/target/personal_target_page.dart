import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/locale_controller.dart';
import '../../core/format.dart';
import '../../core/jaap/jaap_providers.dart';
import '../../l10n/generated/app_localizations.dart';

class PersonalTargetPage extends ConsumerWidget {
  const PersonalTargetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final localeCode =
        (ref.watch(localeProvider) ?? Localizations.localeOf(context))
            .languageCode;
    final target = ref.watch(currentMonthGoalProvider).valueOrNull ?? 0;
    final current = ref.watch(currentMonthCountProvider);
    final week = ref.watch(last7DaysProvider);
    final lifetime = ref.watch(lifetimeCountProvider);
    final streak = ref.watch(currentStreakProvider);
    final pct = target == 0 ? 0 : ((current / target) * 100).clamp(0, 999).round();

    return Scaffold(
      appBar: AppBar(title: Text(l.personalTarget)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // Monthly target card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(l.monthlyTarget,
                            style: theme.textTheme.titleLarge),
                      ),
                      FilledButton.tonal(
                        onPressed: () => _editTarget(context, ref, target),
                        child: Text(l.editTarget),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (target == 0)
                    Text(l.noTargetSet,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ))
                  else ...[
                    Text(
                      '${formatNumber(current, localeCode)} / ${formatNumber(target, localeCode)}',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (current / target).clamp(0.0, 1.0).toDouble(),
                        minHeight: 10,
                        backgroundColor: theme.colorScheme.tertiary,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(l.percentComplete(pct),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Weekly devotion grid
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.weeklyDevotion, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final count = week[i];
                      final intensity = _intensity(count);
                      return _DayBox(
                        label: _dayLabel(i),
                        count: count,
                        intensity: intensity,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Milestones
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.completedMilestones,
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _MilestoneRow(
                    label: l.milestoneFirstMala,
                    unlocked: lifetime >= 108,
                  ),
                  _MilestoneRow(
                    label: l.milestoneFirst1000,
                    unlocked: lifetime >= 1000,
                  ),
                  _MilestoneRow(
                    label: l.milestone7DayStreak,
                    unlocked: streak >= 7,
                  ),
                  _MilestoneRow(
                    label: l.milestone10000,
                    unlocked: lifetime >= 10000,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Expand practice promo
          Card(
            color: theme.colorScheme.tertiary,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.spa_outlined,
                      color: theme.colorScheme.primary, size: 28),
                  const SizedBox(height: 12),
                  Text(l.expandPractice,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 4),
                  Text(l.expandPracticeBody,
                      style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _dayLabel(int i) => const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i];

  double _intensity(int count) {
    if (count == 0) return 0;
    if (count < 108) return 0.3;
    if (count < 500) return 0.55;
    if (count < 1000) return 0.75;
    return 1.0;
  }

  Future<void> _editTarget(
      BuildContext context, WidgetRef ref, int current) async {
    final l = AppLocalizations.of(context);
    final ctrl = TextEditingController(
        text: current == 0 ? '' : current.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.setMonthlyTarget),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l.monthlyTarget),
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
      await ref.read(jaapServiceProvider).setMonthlyTarget(result);
    }
  }
}

class _DayBox extends StatelessWidget {
  const _DayBox({
    required this.label,
    required this.count,
    required this.intensity,
  });
  final String label;
  final int count;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = intensity == 0
        ? scheme.tertiary
        : Color.lerp(scheme.tertiary, scheme.primary, intensity)!;
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                )),
      ],
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({required this.label, required this.unlocked});
  final String label;
  final bool unlocked;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            unlocked
                ? Icons.emoji_events
                : Icons.emoji_events_outlined,
            color: unlocked
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: unlocked
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: unlocked ? FontWeight.w600 : FontWeight.w400,
                )),
          ),
          if (unlocked)
            Icon(Icons.check_circle,
                color: theme.colorScheme.primary, size: 20),
        ],
      ),
    );
  }
}
