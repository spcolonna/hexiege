import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../i18n/i18n.dart';
import '../solo/daily.dart';
import '../ui/theme/settings.dart';

/// Aviso del desafío del día: notificaciones locales (sin servidor) a la hora
/// que eligió el jugador. Se programan los próximos [_days] días y se vuelven a
/// programar cada vez que abre la app o resuelve el desafío: si deja de jugar
/// una semana, los avisos se terminan solos en lugar de insistir para siempre.
class DailyReminder {
  static const _days = 7;
  static const _firstId = 100;

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          // El permiso se pide recién cuando el jugador acepta el aviso.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      _ready = true;
      await reschedule();
    } catch (e) {
      debugPrint('DailyReminder: $e'); // sin avisos (tests, plataforma sin soporte)
    }
  }

  /// Pide el permiso del sistema. Devuelve si quedó concedido.
  static Future<bool> requestPermission() async {
    if (!_ready) return false;
    try {
      final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) return await ios.requestPermissions(alert: true, sound: true) ?? false;
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) return await android.requestNotificationsPermission() ?? false;
    } catch (e) {
      debugPrint('DailyReminder: $e');
    }
    return false;
  }

  /// Prende el aviso si el sistema lo permite. Devuelve si quedó prendido.
  static Future<bool> enable() async {
    final ok = await requestPermission();
    AppSettings.instance.reminder = ok;
    await reschedule();
    return ok;
  }

  /// Borra los avisos pendientes y programa los de los próximos días. El de hoy
  /// no sale si ya lo resolvió o si la hora ya pasó.
  static Future<void> reschedule() async {
    if (!_ready) return;
    try {
      for (var i = 0; i < _days; i++) {
        await _plugin.cancel(id: _firstId + i);
      }
      final s = AppSettings.instance;
      if (!s.reminder) return;
      final now = tz.TZDateTime.now(tz.local);
      final today = Daily.today;
      final details = NotificationDetails(
        android: AndroidNotificationDetails('daily', tr('reminder.channel')),
        iOS: const DarwinNotificationDetails(),
      );
      for (var i = 0; i < _days; i++) {
        final at = tz.TZDateTime(tz.local, now.year, now.month, now.day + i, s.reminderHour);
        if (!at.isAfter(now) || (i == 0 && s.dailySolved(today))) continue;
        // La racha solo se sabe viva para el próximo aviso; los demás van genéricos.
        final streak = i == 0 || (i == 1 && s.dailySolved(today)) ? s.dailyStreakOn(today + i) : 0;
        await _plugin.zonedSchedule(
          id: _firstId + i,
          scheduledDate: at,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          title: tr('daily.title'),
          body: streak > 1 ? tr('reminder.streak', {'n': streak}) : tr('reminder.body'),
        );
      }
    } catch (e) {
      debugPrint('DailyReminder: $e');
    }
  }
}
