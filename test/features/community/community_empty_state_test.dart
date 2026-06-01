import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaapam/core/auth/auth_providers.dart';
import 'package:jaapam/core/campaigns/campaign.dart';
import 'package:jaapam/core/campaigns/campaign_providers.dart';
import 'package:jaapam/features/community/community_tab.dart';
import 'package:jaapam/l10n/generated/app_localizations.dart';

/// Verifies the admin-gating contract: only admins see "Start campaign".
/// We override `activeCampaignProvider` to return `null` (no active campaign)
/// and toggle `isAdminProvider` between true and false.
void main() {
  Future<void> pump(
    WidgetTester tester, {
    required bool isAdmin,
    Campaign? campaign,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeCampaignProvider.overrideWith((_) => Stream.value(campaign)),
          contributionsProvider.overrideWith((_) => Stream.value(const [])),
          campaignActivityProvider.overrideWith((_) => Stream.value(const [])),
          isAdminProvider.overrideWithValue(isAdmin),
          currentUserProvider.overrideWithValue(null),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(body: CommunityTab()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('admin sees Start campaign button on empty state', (t) async {
    await pump(t, isAdmin: true);
    expect(find.text('Start a campaign'), findsOneWidget);
  });

  testWidgets('non-admin does NOT see Start campaign button', (t) async {
    await pump(t, isAdmin: false);
    expect(find.text('Start a campaign'), findsNothing);
    expect(
      find.textContaining("temple admin hasn't started"),
      findsOneWidget,
    );
  });
}
