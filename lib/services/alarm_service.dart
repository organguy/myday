import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/dday.dart';

/// 로컬 알람 등록/취소/재등록을 담당하는 싱글톤 서비스
class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'myday_alarms';
  static const String _channelName = '디데이 알람';

  /// 알람 서비스 초기화 — 앱 시작 시 1회 호출
  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  /// iOS 알림 권한 요청 (첫 알람 추가 시 호출)
  Future<bool> requestIOSPermission() async {
    final impl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    return await impl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  /// Android 정확한 알람 권한 여부 확인 (Android 12+)
  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;
    final impl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await impl?.canScheduleExactNotifications() ?? true;
  }

  /// 알람 등록
  /// 발화 시점이 이미 과거면 등록 생략 후 false 반환
  Future<bool> scheduleAlarm(DDay dday, AlarmItem alarm) async {
    /// 알람 발화 날짜 = 디데이 - N일
    final alarmDate = DateTime(
      dday.targetDate.year,
      dday.targetDate.month,
      dday.targetDate.day,
    ).subtract(Duration(days: alarm.daysBeforeTarget));

    final scheduledAt = DateTime(
      alarmDate.year,
      alarmDate.month,
      alarmDate.day,
      alarm.hour,
      alarm.minute,
    );

    if (scheduledAt.isBefore(DateTime.now())) return false;

    final tzScheduled = tz.TZDateTime.from(scheduledAt, tz.local);

    final title = '${dday.emoji} ${dday.title}';
    final body = alarm.daysBeforeTarget == 0
        ? 'D-Day · 오늘이에요!'
        : 'D-${alarm.daysBeforeTarget} · ${alarm.daysBeforeTarget}일 남았어요';

    await _plugin.zonedSchedule(
      _notificationId(dday.id, alarm.id),
      title,
      body,
      tzScheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    return true;
  }

  /// 개별 알람 취소
  Future<void> cancelAlarm(String ddayId, String alarmId) async {
    await _plugin.cancel(_notificationId(ddayId, alarmId));
  }

  /// 특정 D-Day에 연결된 모든 알람 취소
  Future<void> cancelAllAlarmsForDDay(DDay dday) async {
    for (final alarm in dday.alarms) {
      await _plugin.cancel(_notificationId(dday.id, alarm.id));
    }
  }

  /// 앱 시작 시 Firestore 데이터 기반으로 로컬 알람 전체 재등록
  /// (앱 재설치 또는 기기 재부팅 후 알람 복구)
  Future<void> rescheduleAllAlarms(List<DDay> ddays) async {
    await _plugin.cancelAll();
    for (final dday in ddays) {
      for (final alarm in dday.alarms) {
        await scheduleAlarm(dday, alarm);
      }
    }
  }

  /// ddayId + alarmId 조합으로 고유 int 알람 ID 생성
  int _notificationId(String ddayId, String alarmId) {
    return (ddayId + alarmId).hashCode;
  }
}
