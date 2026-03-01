import 'package:cloud_firestore/cloud_firestore.dart';

/// 디데이에 연결된 알람 항목 모델
class AlarmItem {
  final String id;

  /// 디데이 기준 N일 전 (0 = 당일)
  final int daysBeforeTarget;

  /// 알람 시 (0~23)
  final int hour;

  /// 알람 분 (0~59)
  final int minute;

  /// 발화 시점이 과거면 false (로컬 등록 생략)
  final bool isActive;

  const AlarmItem({
    required this.id,
    required this.daysBeforeTarget,
    required this.hour,
    required this.minute,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'daysBeforeTarget': daysBeforeTarget,
      'hour': hour,
      'minute': minute,
      'isActive': isActive,
    };
  }

  factory AlarmItem.fromMap(Map<String, dynamic> map) {
    return AlarmItem(
      id: map['id'] as String,
      daysBeforeTarget: map['daysBeforeTarget'] as int,
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  AlarmItem copyWith({bool? isActive}) {
    return AlarmItem(
      id: id,
      daysBeforeTarget: daysBeforeTarget,
      hour: hour,
      minute: minute,
      isActive: isActive ?? this.isActive,
    );
  }
}

class DDay {
  final String id;
  final String title;
  final DateTime targetDate;
  final String emoji;
  final int colorValue;
  final DateTime createdAt;

  /// 이 디데이에 등록된 알람 목록
  final List<AlarmItem> alarms;

  DDay({
    required this.id,
    required this.title,
    required this.targetDate,
    this.emoji = '📅',
    this.colorValue = 0xFF6C63FF,
    required this.createdAt,
    this.alarms = const [],
  });

  /// 오늘 기준 디데이 계산
  /// 오늘보다 미래면 D-N, 오늘이면 D-Day, 과거면 D+N
  int get dayDiff {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return target.difference(todayDate).inDays;
  }

  String get ddayLabel {
    final diff = dayDiff;
    if (diff == 0) return 'D-Day';
    if (diff > 0) return 'D-$diff';
    return 'D+${diff.abs()}';
  }

  bool get isPast => dayDiff < 0;
  bool get isToday => dayDiff == 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetDate': Timestamp.fromDate(targetDate),
      'emoji': emoji,
      'colorValue': colorValue,
      'createdAt': Timestamp.fromDate(createdAt),
      'alarms': alarms.map((a) => a.toMap()).toList(),
    };
  }

  factory DDay.fromMap(Map<String, dynamic> map) {
    final rawAlarms = map['alarms'] as List<dynamic>? ?? [];
    return DDay(
      id: map['id'] as String,
      title: map['title'] as String,
      targetDate: (map['targetDate'] as Timestamp).toDate(),
      emoji: map['emoji'] as String? ?? '📅',
      colorValue: map['colorValue'] as int? ?? 0xFF6C63FF,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      alarms: rawAlarms
          .map((e) => AlarmItem.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  DDay copyWith({
    String? id,
    String? title,
    DateTime? targetDate,
    String? emoji,
    int? colorValue,
    List<AlarmItem>? alarms,
  }) {
    return DDay(
      id: id ?? this.id,
      title: title ?? this.title,
      targetDate: targetDate ?? this.targetDate,
      emoji: emoji ?? this.emoji,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt,
      alarms: alarms ?? this.alarms,
    );
  }
}
