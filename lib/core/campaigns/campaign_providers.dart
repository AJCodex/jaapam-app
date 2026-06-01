import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../observability/analytics.dart';
import 'campaign.dart';

/// Fixed doc id for the single active campaign (v1).
const activeCampaignId = 'current';

/// Streams the active campaign doc (or null if none).
final activeCampaignProvider = StreamProvider<Campaign?>((ref) {
  return ref
      .watch(firestoreProvider)
      .collection('campaigns')
      .doc(activeCampaignId)
      .snapshots()
      .map((s) {
    if (!s.exists) return null;
    final c = Campaign.fromMap(s.id, s.data() ?? const {});
    return c.isActive ? c : null;
  });
});

/// Streams all contributions, sorted by count desc.
final contributionsProvider = StreamProvider<List<Contribution>>((ref) {
  final campaign = ref.watch(activeCampaignProvider).valueOrNull;
  if (campaign == null) return Stream.value(const []);
  return ref
      .watch(firestoreProvider)
      .collection('campaigns')
      .doc(campaign.id)
      .collection('contributions')
      .orderBy('count', descending: true)
      .limit(50)
      .snapshots()
      .map(
        (s) => s.docs
            .map((d) => Contribution.fromMap(d.id, d.data()))
            .toList(growable: false),
      );
});

/// Aggregate campaign count = sum of all contributions.
final campaignTotalProvider = Provider<int>((ref) {
  final list = ref.watch(contributionsProvider).valueOrNull ?? const [];
  return list.fold<int>(0, (a, b) => a + b.count);
});

/// Number of participants who have contributed at least one jaap.
final campaignParticipantsProvider = Provider<int>((ref) {
  final list = ref.watch(contributionsProvider).valueOrNull ?? const [];
  return list.where((c) => c.count > 0).length;
});

/// Current user's contribution (0 if none).
final myContributionProvider = Provider<int>((ref) {
  final user = ref.watch(currentUserProvider);
  final list = ref.watch(contributionsProvider).valueOrNull ?? const [];
  if (user == null) return 0;
  return list
      .firstWhere(
        (c) => c.uid == user.uid,
        orElse: () => Contribution(
          uid: user.uid,
          displayName: '',
          count: 0,
          lastUpdated: DateTime.now(),
        ),
      )
      .count;
});

/// Streams the most recent activity events (last 30).
final campaignActivityProvider = StreamProvider<List<ActivityEvent>>((ref) {
  final campaign = ref.watch(activeCampaignProvider).valueOrNull;
  if (campaign == null) return Stream.value(const []);
  return ref
      .watch(firestoreProvider)
      .collection('campaigns')
      .doc(campaign.id)
      .collection('activity')
      .orderBy('createdAt', descending: true)
      .limit(30)
      .snapshots()
      .map(
        (s) => s.docs
            .map((d) => ActivityEvent.fromMap(d.id, d.data()))
            .toList(growable: false),
      );
});

/// Campaign write service.
final campaignServiceProvider = Provider<CampaignService>(
  (ref) => CampaignService(
    ref.watch(firestoreProvider),
    ref.watch(currentUserProvider),
  ),
);

class CampaignService {
  CampaignService(this._db, this._user);

  final FirebaseFirestore _db;
  final dynamic _user;

  DocumentReference<Map<String, dynamic>> get _campaignRef =>
      _db.collection('campaigns').doc(activeCampaignId);

  Future<void> createCampaign({
    required String title,
    required String subtitle,
    required int goal,
  }) async {
    if (_user == null) throw StateError('Not signed in');
    await _campaignRef.set({
      'title': title,
      'subtitle': subtitle,
      'goal': goal,
      'isActive': true,
      'createdBy': _user.uid as String,
      'createdAt': FieldValue.serverTimestamp(),
    });
    unawaited(analytics.campaignStarted(goal: goal));
  }

  Future<void> endCampaign() async {
    await _campaignRef.set({'isActive': false}, SetOptions(merge: true));
  }

  /// Adds [count] to the current user's contribution and appends an activity
  /// event. Caller should also write a personal session (via JaapService).
  Future<void> contribute({
    required int count,
    required String displayName,
  }) async {
    if (_user == null) throw StateError('Not signed in');
    final uid = _user.uid as String;
    final batch = _db.batch();
    batch.set(
      _campaignRef.collection('contributions').doc(uid),
      {
        'displayName': displayName,
        'count': FieldValue.increment(count),
        'lastUpdated': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    batch.set(
      _campaignRef.collection('activity').doc(),
      {
        'uid': uid,
        'displayName': displayName,
        'count': count,
        'createdAt': FieldValue.serverTimestamp(),
      },
    );
    await batch.commit();
    unawaited(analytics.campaignContributed(count));
  }
}
