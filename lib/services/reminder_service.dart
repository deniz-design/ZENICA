import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Local notification service.
///
/// Re-schedules a one-shot reminder 24h from the moment the app starts, so
/// the notification always lands "24h after last use".
class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  static const int reminderId = 24;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initializes the plugin and timezone database. Call once in main().
  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings: settings);

    // Resolve the device's real IANA timezone so TZDateTime is correct.
    tz.initializeTimeZones();
    // flutter_timezone v5 returns a TimezoneInfo; fall back to UTC on error.
    String local = 'UTC';
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      local = info.identifier;
    } catch (_) {
      // keep UTC
    }
    tz.setLocalLocation(tz.getLocation(local));

    _initialized = true;
  }

  /// Schedules a one-shot notification 24 hours from now.
  /// Because it is re-scheduled on every app launch, it tracks "last use".
  Future<void> scheduleDailyReminder() async {
    if (!_initialized) return;
    await _plugin.cancel(id: reminderId);

    final scheduledAt = tz.TZDateTime.now(tz.local).add(const Duration(hours: 24));

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Reminder',
      channelDescription: 'A daily nudge to hop in and burn some calories with yoga.',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      id: reminderId,
      title: 'Yoga time 🧘',
      body: 'Hop in for a quick session and burn some calories!',
      scheduledDate: scheduledAt,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Requests Android 13+ POST_NOTIFICATIONS runtime permission.
  /// Checks the current status first so it does not re-prompt when already
  /// permanently denied (which shows a greyed-out, untappable dialog).
  /// Returns true when notifications are granted.
  Future<bool> requestPermission() async {
    if (!_initialized) return false;
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl == null) return false;

    final current = await androidImpl.areNotificationsEnabled();
    if (current == true) return true; // already granted

    final granted = await androidImpl.requestNotificationsPermission();
    // NOTE: cannot request exact-alarm permission via the plugin — on Android 12+
    // it launches a full Settings screen users find confusing, and it isn't
    // needed anyway: we schedule with AndroidScheduleMode.inexactAllowWhileIdle.
    return granted == true;
  }
}