import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistent app preferences. Single source of truth for the Settings
/// screen — every row reads from here, every mutation writes through here
/// to SharedPreferences.
///
/// Boots eagerly via [load] from `app.dart` so the first screen draw can
/// render the right toggle states without flicker.
class SettingsProvider extends ChangeNotifier {
  static const _kDailyReminders = 'aura.set.dailyReminders';
  static const _kReminderHour = 'aura.set.reminderHour';
  static const _kReminderMinute = 'aura.set.reminderMinute';
  static const _kAutoPlayAudio = 'aura.set.autoPlayAudio';
  static const _kLanguage = 'aura.set.language';
  static const _kThemeMode = 'aura.set.themeMode';

  final SharedPreferences _prefs;

  SettingsProvider({required SharedPreferences prefs}) : _prefs = prefs {
    _hydrate();
  }

  // ---------- backing fields ----------
  bool _dailyRemindersEnabled = true;
  int _reminderHour = 8;
  int _reminderMinute = 0;
  bool _autoPlayAudio = true;
  String _language = 'en';
  ThemeMode _themeMode = ThemeMode.system;

  // ---------- public getters ----------
  bool get dailyRemindersEnabled => _dailyRemindersEnabled;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;
  TimeOfDay get reminderTime =>
      TimeOfDay(hour: _reminderHour, minute: _reminderMinute);
  bool get autoPlayAudio => _autoPlayAudio;
  String get language => _language;
  String get languageLabel => _language == 'vi' ? 'Tiếng Việt' : 'English';
  ThemeMode get themeMode => _themeMode;
  String get themeModeLabel => switch (_themeMode) {
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
        ThemeMode.system => 'System',
      };

  void _hydrate() {
    _dailyRemindersEnabled = _prefs.getBool(_kDailyReminders) ?? true;
    _reminderHour = _prefs.getInt(_kReminderHour) ?? 8;
    _reminderMinute = _prefs.getInt(_kReminderMinute) ?? 0;
    _autoPlayAudio = _prefs.getBool(_kAutoPlayAudio) ?? true;
    _language = _prefs.getString(_kLanguage) ?? 'en';
    final modeName = _prefs.getString(_kThemeMode) ?? 'system';
    _themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == modeName,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setDailyRemindersEnabled(bool value) async {
    if (_dailyRemindersEnabled == value) return;
    _dailyRemindersEnabled = value;
    await _prefs.setBool(_kDailyReminders, value);
    notifyListeners();
  }

  /// Sets the daily reminder clock time. Caller is expected to chain
  /// `NotificationTriggers.instance.setReminderTime(...)` so the OS
  /// schedule reflects the new value immediately.
  Future<void> setReminderTime(TimeOfDay value) async {
    if (_reminderHour == value.hour && _reminderMinute == value.minute) return;
    _reminderHour = value.hour;
    _reminderMinute = value.minute;
    await _prefs.setInt(_kReminderHour, value.hour);
    await _prefs.setInt(_kReminderMinute, value.minute);
    notifyListeners();
  }

  Future<void> setAutoPlayAudio(bool value) async {
    if (_autoPlayAudio == value) return;
    _autoPlayAudio = value;
    await _prefs.setBool(_kAutoPlayAudio, value);
    notifyListeners();
  }

  /// Stores the user's display language. v1 just stores the choice; full
  /// l10n switch requires `flutter_localizations` + ARB assets, deferred.
  Future<void> setLanguage(String code) async {
    if (_language == code) return;
    _language = code;
    await _prefs.setString(_kLanguage, code);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _prefs.setString(_kThemeMode, mode.name);
    notifyListeners();
  }
}
