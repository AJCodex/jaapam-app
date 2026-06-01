import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/locale_controller.dart';
import '../../core/auth/auth_providers.dart';
import '../../core/campaigns/campaign_providers.dart';
import '../../core/format.dart';
import '../../core/jaap/jaap_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import '../shared/confirm_add.dart';
import 'widgets/jaap_ring.dart';

/// Home dashboard hosting two counters in tabs: Personal + Community.
/// Quick-add chips contribute to the active tab's context (Personal-only
/// for the personal tab, Personal + Campaign for the community tab).
class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final firstName = (profile?.displayName ?? '').split(' ').first;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  firstName.isEmpty ? l.namaste : '${l.namaste}, $firstName',
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
        ),
        TabBar(
          controller: _tabs,
          labelColor: theme.colorScheme.primary,
          indicatorColor: theme.colorScheme.primary,
          tabs: [
            Tab(text: l.personal),
            Tab(text: l.community),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: const [
              _PersonalCounter(),
              _CommunityCounter(),
            ],
          ),
        ),
      ],
    );
  }
}

class _PersonalCounter extends ConsumerWidget {
  const _PersonalCounter();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final localeCode =
        (ref.watch(localeProvider) ?? Localizations.localeOf(context))
            .languageCode;
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final goal = profile?.dailyGoal ?? 1;
    final today = ref.watch(todayCountProvider);
    final progress = goal == 0 ? 0.0 : today / goal;
    final streak = ref.watch(currentStreakProvider);
    final last = ref.watch(lastSessionProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
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
          children: const [
            _QuickAddChip(amount: 1, contributeToCampaign: false),
            _QuickAddChip(amount: 5, contributeToCampaign: false),
            _QuickAddChip(amount: 11, contributeToCampaign: false),
            _QuickAddChip(amount: 21, contributeToCampaign: false),
            _QuickAddChip(amount: 108, contributeToCampaign: false),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(              child: _StatCard(
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
    );
  }
}

class _CommunityCounter extends ConsumerWidget {
  const _CommunityCounter();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final localeCode =
        (ref.watch(localeProvider) ?? Localizations.localeOf(context))
            .languageCode;
    final campaign = ref.watch(activeCampaignProvider).valueOrNull;
    final total = ref.watch(campaignTotalProvider);
    final mine = ref.watch(myContributionProvider);
    final participants = ref.watch(campaignParticipantsProvider);
    final isAdmin = ref.watch(isAdminProvider);

    if (campaign == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups_outlined,
                size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(l.noActiveCampaign,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              isAdmin ? l.noActiveCampaignBody : l.noActiveCampaignForDevotee,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final goal = campaign.goal == 0 ? 1 : campaign.goal;
    final progress = (total / goal).clamp(0.0, 1.0).toDouble();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Text(campaign.title,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center),
        if (campaign.subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(campaign.subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center),
        ],
        const SizedBox(height: 16),
        Center(
          child: JaapRing(
            progress: progress,
            size: 240,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.community.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 1.4,
                    )),
                const SizedBox(height: 8),
                Text(formatNumber(total, localeCode),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 2),
                Text(
                  l.ofGoalShort(formatNumber(campaign.goal, localeCode)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(l.devoteesParticipating(participants),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            _QuickAddChip(amount: 1, contributeToCampaign: true),
            _QuickAddChip(amount: 5, contributeToCampaign: true),
            _QuickAddChip(amount: 11, contributeToCampaign: true),
            _QuickAddChip(amount: 21, contributeToCampaign: true),
            _QuickAddChip(amount: 108, contributeToCampaign: true),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          color: theme.colorScheme.tertiary,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.favorite, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.myContribution,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          )),
                      const SizedBox(height: 2),
                      Text(formatNumber(mine, localeCode),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickAddChip extends ConsumerWidget {
  const _QuickAddChip({
    required this.amount,
    required this.contributeToCampaign,
  });
  final int amount;
  final bool contributeToCampaign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => confirmAndAddJaap(
        context,
        ref,
        count: amount,
        contributeToCampaign: contributeToCampaign,
      ),
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
