import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../observability/analytics.dart';
import 'jaap_session.dart';
import 'mantras.dart';

/// Streams the user's recent sessions (most recent 500, ordered desc).
/// All client-side aggregates (today, week, month, lifetime, streak)
/// derive from this list.
final sessionsProvider = StreamProvider<List<JaapSession>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(const []);
  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .collection('sessions')
      .orderBy('createdAt', descending: true)
      .limit(500)
      .snapshots()
      .map(
        (s) => s.docs
            .map((d) => JaapSession.fromMap(d.id, d.data()))
            .toList(growable: false),
      );
});

/// Sum of today's sessions (local timezone).
final todayCountProvider = Provider<int>((ref) {
  final list = ref.watch(sessionsProvider).valueOrNull ?? const [];
  final today = dateKey(DateTime.now());
  return list
      .where((s) => s.sessionDate == today)
      .fold<int>(0, (a, b) => a + b.count);
});

/// Sum of all sessions in window (last `days` days, inclusive).
final rangeCountProvider =
    Provider.family<int, int>((ref, days) {
  final list = ref.watch(sessionsProvider).valueOrNull ?? const [];
  final cutoff = DateTime.now().subtract(Duration(days: days - 1));
  final cutoffKey = dateKey(cutoff);
  return list
      .where((s) => s.sessionDate.compareTo(cutoffKey) >= 0)
      .fold<int>(0, (a, b) => a + b.count);
});

/// Lifetime total across the loaded window.
final lifetimeCountProvider = Provider<int>((ref) {
  final list = ref.watch(sessionsProvider).valueOrNull ?? const [];
  return list.fold<int>(0, (a, b) => a + b.count);
});

/// Lifetime total in malas (1 mala = 108 jaaps).
final lifetimeMalasProvider = Provider<int>((ref) {
  return ref.watch(lifetimeCountProvider) ~/ 108;
});

/// Most recent session, or null if none.
final lastSessionProvider = Provider<JaapSession?>((ref) {
  final list = ref.watch(sessionsProvider).valueOrNull ?? const [];
  return list.isEmpty ? null : list.first;
});

/// Current consecutive-day streak (counts back from today; today counts if any
/// session today, otherwise from yesterday).
final currentStreakProvider = Provider<int>((ref) {
  final list = ref.watch(sessionsProvider).valueOrNull ?? const [];
  if (list.isEmpty) return 0;
  final days = list.map((s) => s.sessionDate).toSet();
  var streak = 0;
  var cursor = DateTime.now();
  // If no session today, start from yesterday so an active streak is preserved
  // until the day ends.
  if (!days.contains(dateKey(cursor))) {
    cursor = cursor.subtract(const Duration(days: 1));
  }
  while (days.contains(dateKey(cursor))) {
    streak += 1;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
});

/// Last-7-days count per day (oldest first). Used by the weekly devotion grid.
final last7DaysProvider = Provider<List<int>>((ref) {
  final list = ref.watch(sessionsProvider).valueOrNull ?? const [];
  final now = DateTime.now();
  final result = <int>[];
  for (var i = 6; i >= 0; i--) {
    final d = dateKey(now.subtract(Duration(days: i)));
    final sum = list
        .where((s) => s.sessionDate == d)
        .fold<int>(0, (a, b) => a + b.count);
    result.add(sum);
  }
  return result;
});

/// Average daily count over last `days` days (jaap/day).
final dailyAvgProvider = Provider.family<int, int>((ref, days) {
  final total = ref.watch(rangeCountProvider(days));
  return days == 0 ? 0 : (total / days).round();
});

/// Streams the current month's personal goal doc.
final currentMonthGoalProvider = StreamProvider<int>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(0);
  final key = monthKey(DateTime.now());
  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .collection('personal_goals')
      .doc(key)
      .snapshots()
      .map((s) => (s.data()?['target'] as num?)?.toInt() ?? 0);
});

/// Sum of sessions in the current calendar month.
final currentMonthCountProvider = Provider<int>((ref) {
  final list = ref.watch(sessionsProvider).valueOrNull ?? const [];
  final mk = monthKey(DateTime.now());
  return list
      .where((s) => s.sessionDate.startsWith(mk))
      .fold<int>(0, (a, b) => a + b.count);
});

/// Jaap write/delete service.
final jaapServiceProvider = Provider<JaapService>(
  (ref) => JaapService(
    ref.watch(firestoreProvider),
    ref.watch(currentUserProvider),
  ),
);

class JaapService {
  JaapService(this._db, this._user);

  final FirebaseFirestore _db;
  final dynamic _user;

  CollectionReference<Map<String, dynamic>> get _sessions => _db
      .collection('users')
      .doc(_user.uid as String)
      .collection('sessions');

  Future<void> addSession({
    required int count,
    required Mantra mantra,
    String? observation,
    DateTime? date,
    String source = 'manual',
  }) async {
    if (_user == null) throw StateError('Not signed in');
    final d = date ?? DateTime.now();
    final session = JaapSession(
      id: '',
      count: count,
      mantra: mantra,
      sessionDate: dateKey(d),
      createdAt: DateTime.now(),
      source: source,
      observation: observation,
    );
    await _sessions.add(session.toMap());
    unawaited(analytics.jaapAdded(count: count, mantra: mantra.name));
  }

  Future<void> deleteSession(String id) async {
    await _sessions.doc(id).delete();
  }

  Future<void> setDailyGoal(int goal) async {
    await _db
        .collection('users')
        .doc(_user.uid as String)
        .set({'dailyGoal': goal}, SetOptions(merge: true));
  }

  Future<void> setMonthlyTarget(int target, {DateTime? month}) async {
    final key = monthKey(month ?? DateTime.now());
    await _db
        .collection('users')
        .doc(_user.uid as String)
        .collection('personal_goals')
        .doc(key)
        .set({'target': target}, SetOptions(merge: true));
    unawaited(analytics.targetSet(target));
  }
}
