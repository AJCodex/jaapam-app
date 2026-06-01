import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/campaigns/campaign_providers.dart';
import '../../core/jaap/jaap_providers.dart';
import '../../core/jaap/mantras.dart';
import '../../l10n/generated/app_localizations.dart';

/// Shows a confirm dialog before adding [count] jaap. When [contributeToCampaign]
/// is true, the message also mentions the active community campaign.
/// Returns true if the user confirmed AND the write succeeded.
Future<bool> confirmAndAddJaap(
  BuildContext context,
  WidgetRef ref, {
  required int count,
  required bool contributeToCampaign,
}) async {
  final l = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(l.confirmAddTitle),
      content: Text(
        contributeToCampaign
            ? l.confirmAddCampaignBody(count)
            : l.confirmAddBody(count),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l.confirm),
        ),
      ],
    ),
  );
  if (ok != true) return false;
  if (!context.mounted) return false;

  final messenger = ScaffoldMessenger.of(context);
  final jaap = ref.read(jaapServiceProvider);
  await jaap.addSession(
    count: count,
    mantra: Mantra.navkar,
    source: 'quick',
  );

  if (contributeToCampaign) {
    final campaign = ref.read(activeCampaignProvider).valueOrNull;
    if (campaign != null) {
      final snackText = l.contributedToCampaign;
      try {
        await ref.read(campaignServiceProvider).contribute(count: count);
        messenger.showSnackBar(SnackBar(content: Text(snackText)));
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
  return true;
}
