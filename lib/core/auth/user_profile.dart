/// User profile stored in Firestore at `users/{uid}`.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.gotra,
    required this.temple,
    required this.locale,
    required this.createdAt,
  });

  final String uid;
  final String displayName;
  final String gotra;
  final String temple;
  final String locale;
  final DateTime createdAt;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      displayName: (data['displayName'] as String?) ?? '',
      gotra: (data['gotra'] as String?) ?? '',
      temple: (data['temple'] as String?) ?? '',
      locale: (data['locale'] as String?) ?? 'en',
      createdAt: _parseDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'gotra': gotra,
        'temple': temple,
        'locale': locale,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  bool get isComplete =>
      displayName.trim().isNotEmpty &&
      gotra.trim().isNotEmpty &&
      temple.trim().isNotEmpty;

  static DateTime _parseDate(dynamic v) {
    if (v is String) {
      return DateTime.tryParse(v)?.toUtc() ?? DateTime.now().toUtc();
    }
    // Firestore Timestamp has a toDate() method; avoid hard dep here.
    try {
      // ignore: avoid_dynamic_calls
      return (v.toDate() as DateTime).toUtc();
    } catch (_) {
      return DateTime.now().toUtc();
    }
  }
}
