import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaapam/core/campaigns/campaign.dart';
import 'package:jaapam/core/campaigns/campaign_providers.dart';

void main() {
  final now = DateTime.utc(2026, 6, 1);

  Contribution c(String uid, int n) =>
      Contribution(uid: uid, displayName: uid, count: n, lastUpdated: now);

  group('Campaign.fromMap', () {
    test('defaults when keys are absent', () {
      final c = Campaign.fromMap('current', const {});
      expect(c.id, 'current');
      expect(c.title, '');
      expect(c.goal, 0);
      expect(c.isActive, isFalse);
      expect(c.createdBy, '');
    });

    test('reads populated payload', () {
      final c = Campaign.fromMap('current', {
        'title': 'Paryushan Maha Jaap',
        'subtitle': 'Together for 8 days',
        'goal': 1000000,
        'isActive': true,
        'createdBy': 'admin-uid',
      });
      expect(c.title, 'Paryushan Maha Jaap');
      expect(c.goal, 1000000);
      expect(c.isActive, isTrue);
      expect(c.createdBy, 'admin-uid');
    });
  });

  group('aggregate providers', () {
    test('campaignTotalProvider sums all contributions', () async {
      final container = ProviderContainer(overrides: [
        contributionsProvider.overrideWith(
          (ref) => Stream.value([c('a', 108), c('b', 540), c('c', 0)]),
        ),
      ]);
      addTearDown(container.dispose);
      await container.read(contributionsProvider.future);
      expect(container.read(campaignTotalProvider), 648);
    });

    test('campaignParticipantsProvider counts only contributors with count>0',
        () async {
      final container = ProviderContainer(overrides: [
        contributionsProvider.overrideWith(
          (ref) => Stream.value([c('a', 108), c('b', 0), c('c', 540)]),
        ),
      ]);
      addTearDown(container.dispose);
      await container.read(contributionsProvider.future);
      expect(container.read(campaignParticipantsProvider), 2);
    });

    test('empty stream yields zero total + zero participants', () async {
      final container = ProviderContainer(overrides: [
        contributionsProvider.overrideWith(
          (ref) => Stream.value(const <Contribution>[]),
        ),
      ]);
      addTearDown(container.dispose);
      await container.read(contributionsProvider.future);
      expect(container.read(campaignTotalProvider), 0);
      expect(container.read(campaignParticipantsProvider), 0);
    });
  });
}
