import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/hydration_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

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
        debugPrint('Notification clicked: ${response.payload}');
      },
    );

    _isInitialized = true;
  }

  Future<void> scheduleHydrationReminders(HydrationGoal goal) async {
    if (!_isInitialized) await init();

    // Cancel previous scheduled reminders
    await _notificationsPlugin.cancelAll();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'aquasoothe_hydration_channel',
      'Hydration Reminders',
      channelDescription: 'Gentle hydration alerts designed for senior wellness',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    final now = DateTime.now();
    final wakeTime = DateTime(now.year, now.month, now.day, goal.wakeHour, goal.wakeMinute);
    final sleepTime = DateTime(now.year, now.month, now.day, goal.sleepHour, goal.sleepMinute);

    final intervalMinutes = (goal.intervalHours * 60).round();
    int notificationId = 100;

    DateTime currentScheduled = wakeTime.isBefore(now)
        ? now.add(Duration(minutes: intervalMinutes))
        : wakeTime;

    // Schedule gentle hydration reminders during waking hours
    for (int i = 0; i < 4; i++) {
      if (currentScheduled.isAfter(sleepTime)) break;

      final scheduledTZ = tz.TZDateTime.from(currentScheduled, tz.local);

      try {
        await _notificationsPlugin.zonedSchedule(
          id: notificationId++,
          title: 'Time for a Sip of Water',
          body: 'Staying hydrated keeps your mind clear and your body energized. Have a glass of water now.',
          scheduledDate: scheduledTZ,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } catch (e) {
        debugPrint("Notice scheduling local notification: $e");
      }

      currentScheduled = currentScheduled.add(Duration(minutes: intervalMinutes));
    }

    // Schedule 30-Minute Bedtime Wind-Down Reminder
    await scheduleBedtimeWindDownNotification(goal, notificationDetails);
  }

  Future<void> scheduleBedtimeWindDownNotification(
    HydrationGoal goal,
    NotificationDetails details,
  ) async {
    final now = DateTime.now();
    var windDownTime = DateTime(now.year, now.month, now.day, goal.sleepHour, goal.sleepMinute)
        .subtract(const Duration(minutes: 30));

    if (windDownTime.isBefore(now)) {
      windDownTime = windDownTime.add(const Duration(days: 1));
    }

    final scheduledTZ = tz.TZDateTime.from(windDownTime, tz.local);

    try {
      await _notificationsPlugin.zonedSchedule(
        id: 999,
        title: 'Bedtime Wind-Down',
        body: '30 minutes to bedtime. Turn on your soothing sleep soundscape and enjoy a restful night.',
        scheduledDate: scheduledTZ,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint("Notice scheduling wind-down notification: $e");
    }
  }

  Future<void> sendTestNotification() async {
    if (!_isInitialized) await init();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'aquasoothe_hydration_channel',
      'Hydration Reminders',
      channelDescription: 'Gentle hydration alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id: 0,
      title: 'AquaSoothe Water Reminder',
      body: 'Here is a quick reminder to enjoy a refreshing glass of water today!',
      notificationDetails: details,
    );
  }
}
