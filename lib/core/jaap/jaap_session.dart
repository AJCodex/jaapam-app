import 'mantras.dart';

/// A single jaap session entry written to `users/{uid}/sessions/{id}`.
class JaapSession {
  const JaapSession({
    required this.id,
    required this.count,
    required this.mantra,
    required this.sessionDate, // local YYYY-MM-DD
    required this.createdAt,
    required this.source,
    this.observation,
  });

  final String id;
  final int count;
  final Mantra mantra;
  final String sessionDate;
  final DateTime createdAt;
  final String source; // 'quick' | 'manual'
  final String? observation;

  factory JaapSession.fromMap(String id, Map<String, dynamic> data) {
    return JaapSession(
      id: id,
      count: (data['count'] as num?)?.toInt() ?? 0,
      mantra: MantraX.fromKey(data['mantra'] as String?),
      sessionDate: (data['sessionDate'] as String?) ?? '',
      createdAt: _parseDate(data['createdAt']),
      source: (data['source'] as String?) ?? 'manual',
      observation: data['observation'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'count': count,
        'mantra': mantra.key,
        'sessionDate': sessionDate,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'source': source,
        if (observation != null && observation!.isNotEmpty)
          'observation': observation,
      };

  static DateTime _parseDate(dynamic v) {
    if (v is String) {
      return DateTime.tryParse(v)?.toLocal() ?? DateTime.now();
    }
    try {
      // ignore: avoid_dynamic_calls
      return (v.toDate() as DateTime).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }
}

/// Helper: local YYYY-MM-DD for the given date.
String dateKey(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

/// Helper: local YYYY-MM for monthly target docs.
String monthKey(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  return '$y-$m';
}
