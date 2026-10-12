import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/alarm_model.dart';
import '../models/hydration_model.dart';
import '../models/medication_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const String channelMedication = 'aquasoothe_medication_channel';
  static const String channelHydration = 'aquasoothe_hydration_channel';
  static const String channelAlarm = 'aquasoothe_alarm_channel';

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    _configureLocalTimeZone();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    // Request permissions for Android 13+ (API 33+) & exact alarm scheduling
    final androidImpl = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      try {
        await androidImpl.requestNotificationsPermission();
      } catch (e) {
        debugPrint('Notice requesting notification permission: $e');
      }
      try {
        await androidImpl.requestExactAlarmsPermission();
      } catch (e) {
        debugPrint('Notice requesting exact alarm permission: $e');
      }
    }

    _isInitialized = true;
  }

  void _configureLocalTimeZone() {
    try {
      final offset = DateTime.now().timeZoneOffset;
      for (final location in tz.timeZoneDatabase.locations.values) {
        if (location.currentTimeZone.offset == offset) {
          tz.setLocalLocation(location);
          return;
        }
      }
    } catch (e) {
      debugPrint('Fallback timeZone config notice: $e');
    }
  }

  /// Parses 12-hour or 24-hour time strings like '08:00 AM', '1:00 PM', '20:30'
  TimeOfDay? parseTimeString(String raw) {
    try {
      final clean = raw.trim().toUpperCase();
      final isPm = clean.contains('PM');
      final isAm = clean.contains('AM');
      final digits = clean.replaceAll(RegExp(r'[^0-9:]'), '');
      final parts = digits.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        if (isPm && hour < 12) hour += 12;
        if (isAm && hour == 12) hour = 0;
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      debugPrint('Error parsing time string "$raw": $e');
    }
    return null;
  }

  /// Calculates the next TZDateTime instance for a given hour and minute
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // =========================================================================
  // 1. MEDICATION & WATER REMINDERS (Daily Repeating, Exact Alarm)
  // =========================================================================

  Future<void> scheduleMedicationReminders(
    List<MedicationItem> items, {
    bool isSinhala = false,
  }) async {
    if (!_isInitialized) await init();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelMedication,
      'Medication & Water Reminders',
      channelDescription: 'Scheduled alerts to take medications and drink water at exact times',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true, presentBadge: true),
    );

    for (int i = 0; i < items.length; i++) {
      final med = items[i];
      final timeOfDay = parseTimeString(med.time);
      if (timeOfDay == null) continue;

      final scheduledTZ = _nextInstanceOfTime(timeOfDay.hour, timeOfDay.minute);
      final notificationId = 2000 + i;

      final title = isSinhala
          ? '💊 බෙහෙත් වේලාව: ${med.nameSi}'
          : '💊 Medication Reminder: ${med.name}';
      final body = isSinhala
          ? '${med.dosage} ලබාගෙන නැවුම් වතුර වීදුරුවක් (250ml) පානය කරන්න.'
          : 'Time for ${med.dosage}. Remember to drink a full glass of water (250ml).';

      try {
        await _notificationsPlugin.cancel(id: notificationId);
        await _notificationsPlugin.zonedSchedule(
          id: notificationId,
          title: title,
          body: body,
          scheduledDate: scheduledTZ,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time, // Repeats daily at this exact time!
        );
        debugPrint('Scheduled medication "$title" for $scheduledTZ (ID: $notificationId)');
      } catch (e) {
        debugPrint('Notice scheduling medication notification: $e');
      }
    }
  }

  // =========================================================================
  // 2. HYDRATION REMINDERS (Daily Repeating across waking hours)
  // =========================================================================

  Future<void> scheduleHydrationReminders(
    HydrationGoal goal, {
    bool isSinhala = false,
  }) async {
    if (!_isInitialized) await init();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelHydration,
      'Hydration Reminders',
      channelDescription: 'Gentle hydration alerts throughout the day',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
    );

    // Cancel prior hydration reminders (IDs 100 - 120)
    for (int id = 100; id <= 120; id++) {
      await _notificationsPlugin.cancel(id: id);
    }

    final wakeHour = goal.wakeHour;
    final sleepHour = goal.sleepHour;
    final intervalHours = goal.intervalHours > 0 ? goal.intervalHours : 2.5;

    int notifId = 100;
    double currentHour = wakeHour + intervalHours;

    while (currentHour < sleepHour && notifId < 115) {
      final hour = currentHour.floor();
      final minute = ((currentHour - hour) * 60).round();
      final scheduledTZ = _nextInstanceOfTime(hour, minute);

      final title = isSinhala
          ? '💧 වතුර වීදුරුවක් පානය කරන්න'
          : '💧 Time for a Glass of Water';
      final body = isSinhala
          ? 'නිරෝගී සුවය උදෙසා දැන් නැවුම් වතුර වීදුරුවක් පානය කර ශරීරය සජලීයව තබා ගන්න.'
          : 'Stay refreshed and healthy! Take a break and drink a clean glass of water.';

      try {
        await _notificationsPlugin.zonedSchedule(
          id: notifId++,
          title: title,
          body: body,
          scheduledDate: scheduledTZ,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (e) {
        debugPrint('Notice scheduling hydration reminder: $e');
      }

      currentHour += intervalHours;
    }

    // Bedtime wind-down reminder (30 mins before sleep)
    int windDownHour = sleepHour;
    int windDownMinute = (goal.sleepMinute - 30);
    if (windDownMinute < 0) {
      windDownMinute += 60;
      windDownHour = (windDownHour - 1 + 24) % 24;
    }
    final bedtimeTZ = _nextInstanceOfTime(windDownHour, windDownMinute);

    final bedTitle = isSinhala ? '🌙 සුවබර නින්දට සූදානම් වන්න' : '🌙 Bedtime Wind-Down';
    final bedBody = isSinhala
        ? 'නින්දට පෙර සන්සුන් ස්වභාවික නාදයන් අසමින් මනස නිවා සුවෙන් සැතපෙන්න.'
        : 'Prepare for deep sleep. Relax with soothing nature soundscapes tonight.';

    try {
      await _notificationsPlugin.zonedSchedule(
        id: 999,
        title: bedTitle,
        body: bedBody,
        scheduledDate: bedtimeTZ,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Notice scheduling wind-down reminder: $e');
    }
  }

  // =========================================================================
  // 3. GENTLE NATURE WAKE-UP ALARM
  // =========================================================================

  Future<void> scheduleGentleAlarm(
    AlarmModel alarm, {
    bool isSinhala = false,
  }) async {
    if (!_isInitialized) await init();

    const int alarmNotifId = 500;

    if (!alarm.isEnabled) {
      await _notificationsPlugin.cancel(id: alarmNotifId);
      return;
    }

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelAlarm,
      'Wake-Up Nature Alarm',
      channelDescription: 'Gentle nature sound morning wake-up alarm',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      styleInformation: const BigTextStyleInformation(''),
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'action_alarm_off',
          isSinhala ? 'ඇලාමය Off කරන්න' : 'Turn Off Alarm',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'action_alarm_snooze',
          isSinhala ? 'විනාඩි 5ක් පසුව' : 'Snooze (5m)',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(presentAlert: true, presentSound: true),
    );

    final scheduledTZ = _nextInstanceOfTime(alarm.hour, alarm.minute);
    final title = isSinhala
        ? '🌅 සුබ උදෑසනක් - ස්වභාවික අවදිවීම'
        : '🌅 Good Morning - Gentle Nature Wake-Up';
    final soundName = isSinhala ? alarm.soundTitleSi : alarm.soundTitleEn;
    final body = isSinhala
        ? 'නියමිත වේලාවයි! $soundName නාදයෙන් දවස සන්සුන්ව අරඹන්න.'
        : 'It is wake-up time! Rise gently with $soundName.';

    try {
      await _notificationsPlugin.cancel(id: alarmNotifId);
      await _notificationsPlugin.zonedSchedule(
        id: alarmNotifId,
        title: title,
        body: body,
        scheduledDate: scheduledTZ,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('Scheduled alarm for $scheduledTZ (ID: $alarmNotifId)');
    } catch (e) {
      debugPrint('Notice scheduling alarm: $e');
    }
  }

  // =========================================================================
  // 4. IMMEDIATE TEST NOTIFICATION (Pops up in phone's Notification Shade)
  // =========================================================================

  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String channelId = channelMedication,
  }) async {
    if (!_isInitialized) await init();

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      'AquaSoothe Reminders',
      channelDescription: 'Direct alerts to notification shade',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(body),
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(presentAlert: true, presentSound: true, presentBadge: true),
    );

    await _notificationsPlugin.show(
      id: 777,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  /// Direct test trigger for user testing
  Future<void> sendTestNotification({bool isSinhala = false}) async {
    final title = isSinhala
        ? '💊 AquaSoothe: බෙහෙත් සහ වතුර සිහිකැඳවීම් සක්‍රියයි!'
        : '💊 AquaSoothe: Medication & Water Alerts Active!';
    final body = isSinhala
        ? 'ඔබගේ දුරකථනයේ Notification Panel එකට නියමිත වේලාවට මෙසේ පණිවිඩ ලැබෙනු ඇත. App එක වැසුවද ක්‍රියා කරයි!'
        : 'Alerts will appear in your notification panel at the exact scheduled times, even when the app is closed!';

    await showImmediateNotification(title: title, body: body);
  }
}
