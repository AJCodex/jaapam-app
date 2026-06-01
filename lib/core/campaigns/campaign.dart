import 'package:cloud_firestore/cloud_firestore.dart';

/// A community campaign drives a temple-wide jaap goal.
/// For v1 we keep at most one active campaign at a fixed doc id `current`,
/// so all readers don't need a query. Future phases can support history.
class Campaign {
  const Campaign({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.goal,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String subtitle;
  final int goal;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;

  factory Campaign.fromMap(String id, Map<String, dynamic> data) {
    return Campaign(
      id: id,
      title: (data['title'] as String?) ?? '',
      subtitle: (data['subtitle'] as String?) ?? '',
      goal: (data['goal'] as num?)?.toInt() ?? 0,
      isActive: (data['isActive'] as bool?) ?? false,
      createdBy: (data['createdBy'] as String?) ?? '',
      createdAt: _ts(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'subtitle': subtitle,
        'goal': goal,
        'isActive': isActive,
        'createdBy': createdBy,
        'createdAt': FieldValue.serverTimestamp(),
      };

  static DateTime _ts(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }
}

/// Per-user denormalized contribution to a campaign.
class Contribution {
  const Contribution({
    required this.uid,
    required this.displayName,
    required this.count,
    required this.lastUpdated,
  });

  final String uid;
  final String displayName;
  final int count;
  final DateTime lastUpdated;

  factory Contribution.fromMap(String uid, Map<String, dynamic> data) {
    return Contribution(
      uid: uid,
      displayName: (data['displayName'] as String?) ?? '',
      count: (data['count'] as num?)?.toInt() ?? 0,
      lastUpdated: Campaign._ts(data['lastUpdated']),
    );
  }
}

/// Activity feed event.
class ActivityEvent {
  const ActivityEvent({
    required this.id,
    required this.uid,
    required this.displayName,
    required this.count,
    required this.createdAt,
  });

  final String id;
  final String uid;
  final String displayName;
  final int count;
  final DateTime createdAt;

  factory ActivityEvent.fromMap(String id, Map<String, dynamic> data) {
    return ActivityEvent(
      id: id,
      uid: (data['uid'] as String?) ?? '',
      displayName: (data['displayName'] as String?) ?? '',
      count: (data['count'] as num?)?.toInt() ?? 0,
      createdAt: Campaign._ts(data['createdAt']),
    );
  }
}
