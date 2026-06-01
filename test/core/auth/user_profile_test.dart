import 'package:flutter_test/flutter_test.dart';
import 'package:jaapam/core/auth/user_profile.dart';

void main() {
  group('UserProfile', () {
    final ts = DateTime.utc(2026, 1, 1, 10);

    test('toMap intentionally omits isAdmin so client cannot self-promote', () {
      final p = UserProfile(
        uid: 'u1',
        displayName: 'Test',
        temple: 'Shri Mandir',
        locale: 'en',
        createdAt: ts,
        isAdmin: true, // even if set in memory…
      );
      final m = p.toMap();
      expect(m.containsKey('isAdmin'), isFalse, reason: 'must never be written');
      expect(m['displayName'], 'Test');
      expect(m['temple'], 'Shri Mandir');
    });

    test('fromMap reads isAdmin and defaults to false when absent', () {
      final pTrue = UserProfile.fromMap('u1', {
        'displayName': 'A',
        'temple': 'X',
        'locale': 'en',
        'createdAt': ts.toIso8601String(),
        'isAdmin': true,
      });
      expect(pTrue.isAdmin, isTrue);

      final pMissing = UserProfile.fromMap('u2', {
        'displayName': 'B',
        'temple': 'X',
        'locale': 'en',
        'createdAt': ts.toIso8601String(),
      });
      expect(pMissing.isAdmin, isFalse);
    });

    test('copyWith preserves isAdmin without exposing it as a parameter', () {
      final p = UserProfile(
        uid: 'u1',
        displayName: 'A',
        temple: 'X',
        locale: 'en',
        createdAt: ts,
        isAdmin: true,
      );
      final copy = p.copyWith(displayName: 'B');
      expect(copy.isAdmin, isTrue);
      expect(copy.displayName, 'B');
    });

    test('isComplete requires displayName + temple', () {
      final p = UserProfile(
        uid: 'u1',
        displayName: '',
        temple: 'X',
        locale: 'en',
        createdAt: ts,
      );
      expect(p.isComplete, isFalse);
      expect(p.copyWith(displayName: 'A').isComplete, isTrue);
    });
  });
}
