import 'dart:io';

import 'package:flutter/material.dart';

/// Notification service for handling local notifications
/// Note: In production, add flutter_local_notifications package
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // In production with flutter_local_notifications:
    // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    //     FlutterLocalNotificationsPlugin();
    //
    // const AndroidInitializationSettings initializationSettingsAndroid =
    //     AndroidInitializationSettings('@mipmap/ic_launcher');
    //
    // const DarwinInitializationSettings initializationSettingsIOS =
    //     DarwinInitializationSettings(
    //   requestAlertPermission: true,
    //   requestBadgePermission: true,
    //   requestSoundPermission: true,
    // );
    //
    // const InitializationSettings initializationSettings = InitializationSettings(
    //   android: initializationSettingsAndroid,
    //   iOS: initializationSettingsIOS,
    // );
    //
    // await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    _isInitialized = true;
    debugPrint('NotificationService initialized');
  }

  /// Request notification permissions (iOS/Android 13+)
  Future<bool> requestPermissions() async {
    // In production with flutter_local_notifications:
    // if (Platform.isIOS) {
    //   final result = await flutterLocalNotificationsPlugin
    //       .resolvePlatformSpecificImplementation<
    //           IOSFlutterLocalNotificationsPlugin>()
    //       ?.requestPermissions(
    //         alert: true,
    //         badge: true,
    //         sound: true,
    //       );
    //   return result ?? false;
    // } else if (Platform.isAndroid) {
    //   final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    //       flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
    //           AndroidFlutterLocalNotificationsPlugin>();
    //   final bool? granted = await androidImplementation?.requestNotificationsPermission();
    //   return granted ?? false;
    // }
    return true;
  }

  /// Schedule daily reading reminder
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    // In production with flutter_local_notifications:
    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //   0, // ID
    //   title,
    //   body,
    //   _nextInstanceOfTime(hour, minute),
    //   const NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       'daily_reminder',
    //       'Daily Reading Reminder',
    //       channelDescription: 'Reminds you to read every day',
    //       importance: Importance.high,
    //       priority: Priority.high,
    //       icon: '@mipmap/ic_launcher',
    //     ),
    //     iOS: DarwinNotificationDetails(
    //       sound: 'default',
    //       presentAlert: true,
    //       presentBadge: true,
    //       presentSound: true,
    //     ),
    //   ),
    //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    //   uiLocalNotificationDateInterpretation:
    //       UILocalNotificationDateInterpretation.absoluteTime,
    //   matchDateTimeComponents: DateTimeComponents.time,
    // );
    debugPrint('Scheduled daily reminder at $hour:$minute');
  }

  /// Cancel daily reading reminder
  Future<void> cancelDailyReminder() async {
    // In production:
    // await flutterLocalNotificationsPlugin.cancel(0);
    debugPrint('Cancelled daily reminder');
  }

  /// Schedule goal deadline reminder
  Future<void> scheduleGoalReminder({
    required int id,
    required String goalTitle,
    required DateTime deadline,
  }) async {
    // Schedule reminder 1 day before deadline
    final reminderTime = deadline.subtract(const Duration(days: 1));
    if (reminderTime.isBefore(DateTime.now())) return;

    // In production:
    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //   id,
    //   'Goal Deadline Approaching',
    //   '$goalTitle is due tomorrow!',
    //   tz.TZDateTime.from(reminderTime, tz.local),
    //   const NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       'goal_reminder',
    //       'Goal Reminders',
    //       channelDescription: 'Reminds you about upcoming goal deadlines',
    //       importance: Importance.high,
    //       priority: Priority.high,
    //       icon: '@mipmap/ic_launcher',
    //     ),
    //     iOS: DarwinNotificationDetails(
    //       sound: 'default',
    //       presentAlert: true,
    //       presentBadge: true,
    //       presentSound: true,
    //     ),
    //   ),
    //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    //   uiLocalNotificationDateInterpretation:
    //       UILocalNotificationDateInterpretation.absoluteTime,
    // );
    debugPrint('Scheduled goal reminder for $goalTitle on $reminderTime');
  }

  /// Show immediate notification (e.g., achievement unlocked)
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // In production:
    // await flutterLocalNotificationsPlugin.show(
    //   id,
    //   title,
    //   body,
    //   const NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       'general',
    //       'General Notifications',
    //       channelDescription: 'General app notifications',
    //       importance: Importance.defaultImportance,
    //       priority: Priority.defaultPriority,
    //       icon: '@mipmap/ic_launcher',
    //     ),
    //     iOS: DarwinNotificationDetails(
    //       sound: 'default',
    //       presentAlert: true,
    //       presentBadge: true,
    //       presentSound: true,
    //     ),
    //   ),
    //   payload: payload,
    // );
    debugPrint('Showing notification: $title - $body');
  }

  /// Show reading streak notification
  Future<void> showStreakNotification(int streakDays) async {
    await showNotification(
      id: 100 + streakDays,
      title: '🔥 $streakDays Day Streak!',
      body: 'Keep up the great work! Read today to maintain your streak.',
    );
  }

  /// Show achievement unlocked notification
  Future<void> showAchievementNotification({
    required String achievementTitle,
    required String achievementDescription,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: '🏆 Achievement Unlocked!',
      body: achievementTitle,
      payload: 'achievement',
    );
  }

  /// Show goal completed notification
  Future<void> showGoalCompletedNotification(String goalTitle) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: '🎉 Goal Completed!',
      body: 'Congratulations! You completed: $goalTitle',
      payload: 'goal',
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    // In production:
    // await flutterLocalNotificationsPlugin.cancelAll();
    debugPrint('Cancelled all notifications');
  }

  /// Cancel specific notification
  Future<void> cancel(int id) async {
    // In production:
    // await flutterLocalNotificationsPlugin.cancel(id);
    debugPrint('Cancelled notification $id');
  }
}

/// Notification IDs for the app
class NotificationIds {
  NotificationIds._();

  static const int dailyReminder = 0;
  static const int goalReminderBase = 1000;
  static const int achievementBase = 2000;
  static const int streakBase = 3000;
}
