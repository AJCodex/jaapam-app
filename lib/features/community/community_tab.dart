import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/locale_controller.dart';
import '../../core/auth/auth_providers.dart';
import '../../core/campaigns/campaign.dart';
import '../../core/campaigns/campaign_providers.dart';
import '../../core/format.dart';
import '../../l10n/generated/app_localizations.dart';
import '../home/widgets/jaap_ring.dart';
import '../shared/confirm_add.dart';

class CommunityTab extends ConsumerWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final campaign = ref.watch(activeCampaignProvider).valueOrNull;
    final isAdmin = ref.watch(isAdminProvider);

    if (campaign == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              if (isAdmin) ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(l.startCampaign),
                  onPressed: () => _showCreateSheet(context, ref),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return _ActiveCampaignView(campaign: campaign);
  }
}

Future<void> _showCreateSheet(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _CreateCampaignSheet(),
  );
}

class _ActiveCampaignView extends ConsumerWidget {
  const _ActiveCampaignView({required this.campaign});
  final Campaign campaign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final localeCode =
        (ref.watch(localeProvider) ?? Localizations.localeOf(context))
            .languageCode;
    final total = ref.watch(campaignTotalProvider);
    final mine = ref.watch(myContributionProvider);
    final participants = ref.watch(campaignParticipantsProvider);
    final contribs = ref.watch(contributionsProvider).valueOrNull ?? const [];
    final activity = ref.watch(campaignActivityProvider).valueOrNull ?? const [];
    final goal = campaign.goal == 0 ? 1 : campaign.goal;
    final progress = (total / goal).clamp(0.0, 1.0).toDouble();
    final user = ref.watch(currentUserProvider);
    final isOwner = user?.uid == campaign.createdBy;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(campaign.title, style: theme.textTheme.headlineSmall),
                  if (campaign.subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(campaign.subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          )),
                    ),
                ],
              ),
            ),
            if (isOwner)
              IconButton(
                tooltip: l.endCampaign,
                icon: const Icon(Icons.stop_circle_outlined),
                onPressed: () => _confirmEnd(context, ref),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: JaapRing(
            progress: progress,
            size: 240,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(formatNumber(total, localeCode),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    )),
                const SizedBox(height: 2),
                Text(l.ofGoalShort(formatNumber(campaign.goal, localeCode)),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
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
                      Text(formatNumber(mine, localeCode),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () => confirmAndAddJaap(
                    context,
                    ref,
                    count: 108,
                    contributeToCampaign: true,
                  ),
                  child: Text(l.contributeNow),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(l.topContributors.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            )),
        const SizedBox(height: 8),
        if (contribs.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(l.noActivityYet,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center),
            ),
          )
        else
          Card(
            child: Column(
              children: [
                for (var i = 0; i < contribs.take(5).length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.tertiary,
                      child: Text('${i + 1}',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                    title: Text(contribs[i].displayName.isEmpty
                        ? 'Anonymous'
                        : contribs[i].displayName),
                    trailing: Text(formatNumber(contribs[i].count, localeCode),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 24),
        Text(l.liveActivity.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            )),
        const SizedBox(height: 8),
        if (activity.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(l.noActivityYet,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center),
            ),
          )
        else
          Card(
            child: Column(
              children: [
                for (var i = 0; i < activity.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.bolt,
                        color: theme.colorScheme.primary, size: 20),
                    title: Text(
                      l.justAddedJaap(
                        activity[i].displayName.isEmpty
                            ? 'Anonymous'
                            : activity[i].displayName,
                        activity[i].count,
                      ),
                      style: theme.textTheme.bodyMedium,
                    ),
                    trailing: Text(
                      relativeTime(activity[i].createdAt, l),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _confirmEnd(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.endCampaign),
        content: Text(l.endCampaignBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.endCampaign),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(campaignServiceProvider).endCampaign();
    }
  }
}

class _CreateCampaignSheet extends ConsumerStatefulWidget {
  const _CreateCampaignSheet();
  @override
  ConsumerState<_CreateCampaignSheet> createState() =>
      _CreateCampaignSheetState();
}

class _CreateCampaignSheetState extends ConsumerState<_CreateCampaignSheet> {
  final _title = TextEditingController();
  final _subtitle = TextEditingController();
  final _goal = TextEditingController(text: '1000000');
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    _goal.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final goal = int.tryParse(_goal.text.trim());
    if (_title.text.trim().isEmpty || goal == null || goal <= 0) {
      setState(() => _error = 'Title and a positive goal are required.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(campaignServiceProvider).createCampaign(
            title: _title.text.trim(),
            subtitle: _subtitle.text.trim(),
            goal: goal,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _busy = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final insets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + insets.bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.createCampaign,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              decoration: InputDecoration(
                labelText: l.campaignTitleLabel,
                hintText: l.campaignTitleHint,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subtitle,
              decoration:
                  InputDecoration(labelText: l.campaignSubtitleLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _goal,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l.campaignGoalLabel),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  )),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: Text(_busy ? l.saving : l.createCampaign),
            ),
          ],
        ),
      ),
    );
  }
}
