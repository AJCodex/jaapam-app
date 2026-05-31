import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/locale_controller.dart';
import '../../core/format.dart';
import '../../core/jaap/jaap_providers.dart';
import '../../core/jaap/jaap_session.dart';
import '../../l10n/generated/app_localizations.dart';
import '../shared/mantra_label.dart';

class HistoryTab extends ConsumerStatefulWidget {
  const HistoryTab({super.key});
  @override
  ConsumerState<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends ConsumerState<HistoryTab> {
  int _rangeDays = 7;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final localeCode =
        (ref.watch(localeProvider) ?? Localizations.localeOf(context))
            .languageCode;
    final total = ref.watch(rangeCountProvider(_rangeDays));
    final avg = ref.watch(dailyAvgProvider(_rangeDays));
    final streak = ref.watch(currentStreakProvider);
    final sessions = ref.watch(sessionsProvider).valueOrNull ?? const [];

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          sliver: SliverList.list(
            children: [
              Text(l.historyTitle, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(l.historySubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  )),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l.thisWeek),
                    selected: _rangeDays == 7,
                    onSelected: (_) => setState(() => _rangeDays = 7),
                  ),
                  ChoiceChip(
                    label: Text(l.thisMonth),
                    selected: _rangeDays == 30,
                    onSelected: (_) => setState(() => _rangeDays = 30),
                  ),
                  ChoiceChip(
                    label: Text(l.customRange),
                    selected: _rangeDays == 90,
                    onSelected: (_) => setState(() => _rangeDays = 90),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.totalChantCount.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            letterSpacing: 1.2,
                          )),
                      const SizedBox(height: 8),
                      Text(
                        formatNumber(total, localeCode),
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.dailyAvg,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                )),
                            const SizedBox(height: 4),
                            Text(formatNumber(avg, localeCode),
                                style: theme.textTheme.titleLarge),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.currentStreak,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                )),
                            const SizedBox(height: 4),
                            Text('$streak ${l.daysUnit}',
                                style: theme.textTheme.titleLarge),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(l.recentEntries.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                  )),
              const SizedBox(height: 8),
            ],
          ),
        ),
        if (sessions.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            sliver: SliverToBoxAdapter(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(l.noEntries,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList.separated(
              itemCount: sessions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _EntryTile(
                session: sessions[i],
                localeCode: localeCode,
              ),
            ),
          ),
      ],
    );
  }
}

class _EntryTile extends ConsumerWidget {
  const _EntryTile({required this.session, required this.localeCode});
  final JaapSession session;
  final String localeCode;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.deleteEntry),
        content: Text(l.deleteEntryBody(session.count, session.sessionDate)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(jaapServiceProvider).deleteSession(session.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            shortDate(session.createdAt, localeCode)
                .toUpperCase()
                .replaceAll(' ', '\n'),
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ),
        title: Text(
          '${mantraLabel(session.mantra, l)} · ${formatNumber(session.count, localeCode)}',
          style: theme.textTheme.titleMedium,
        ),
        subtitle: session.observation == null
            ? Text(relativeTime(session.createdAt, l),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ))
            : Text(session.observation!,
                maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline,
              color: theme.colorScheme.onSurfaceVariant),
          onPressed: () => _confirmDelete(context, ref),
        ),
      ),
    );
  }
}
