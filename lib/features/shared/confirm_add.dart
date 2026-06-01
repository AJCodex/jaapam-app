import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
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
      final profile = ref.read(userProfileProvider).valueOrNull;
      final user = ref.read(currentUserProvider);
      final name = profile?.displayName.isNotEmpty == true
          ? profile!.displayName
          : (user?.email ?? 'Anonymous');
      final snackText = l.contributedToCampaign;
      await ref
          .read(campaignServiceProvider)
          .contribute(count: count, displayName: name);
      messenger.showSnackBar(SnackBar(content: Text(snackText)));
    }
  }
  return true;
}
