import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  // Singleton pattern
  static final PreferencesManager _instance = PreferencesManager._internal();
  factory PreferencesManager() => _instance;
  PreferencesManager._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Ключі для зберігання
  static const String _keyName = 'user_name';
  static const String _keyEmail = 'user_email';
  static const String _keyAge = 'user_age';
  static const String _keyRegDate = 'user_reg_date';

  static const String _keyTheme = 'ui_theme';
  static const String _keyFontSize = 'ui_font_size';
  static const String _keyLanguage = 'ui_language';
  static const String _keyCompactMode = 'ui_compact_mode';

  static const String _keyPushNotifications = 'notif_push';
  static const String _keyEmailNotifications = 'notif_email';
  static const String _keySoundNotifications = 'notif_sound';
  static const String _keyReminderFrequency = 'notif_frequency';

  static const String _keyCategories = 'fav_categories';

  // --- ПРОФІЛЬ ---
  Future<bool> saveName(String name) async => await _safeSave((p) => p.setString(_keyName, name));
  String getName() => _prefs?.getString(_keyName) ?? 'Іван Іванов';

  Future<bool> saveEmail(String email) async => await _safeSave((p) => p.setString(_keyEmail, email));
  String getEmail() => _prefs?.getString(_keyEmail) ?? 'user@example.com';

  Future<bool> saveAge(int age) async => await _safeSave((p) => p.setInt(_keyAge, age));
  int getAge() => _prefs?.getInt(_keyAge) ?? 25;

  Future<bool> saveRegDate(String date) async => await _safeSave((p) => p.setString(_keyRegDate, date));
  String getRegDate() => _prefs?.getString(_keyRegDate) ?? DateTime.now().toIso8601String().split('T')[0];

  // --- UI / ВИГЛЯД ---
  Future<bool> saveTheme(String theme) async => await _safeSave((p) => p.setString(_keyTheme, theme));
  String getTheme() => _prefs?.getString(_keyTheme) ?? 'system';

  Future<bool> saveFontSize(double size) async => await _safeSave((p) => p.setDouble(_keyFontSize, size));
  double getFontSize() => _prefs?.getDouble(_keyFontSize) ?? 14.0;

  Future<bool> saveLanguage(String lang) async => await _safeSave((p) => p.setString(_keyLanguage, lang));
  String getLanguage() => _prefs?.getString(_keyLanguage) ?? 'Українська';

  Future<bool> saveCompactMode(bool isCompact) async => await _safeSave((p) => p.setBool(_keyCompactMode, isCompact));
  bool getCompactMode() => _prefs?.getBool(_keyCompactMode) ?? false;

  // --- СПОВІЩЕННЯ ---
  Future<bool> savePush(bool value) async => await _safeSave((p) => p.setBool(_keyPushNotifications, value));
  bool getPush() => _prefs?.getBool(_keyPushNotifications) ?? true;

  Future<bool> saveEmailNotif(bool value) async => await _safeSave((p) => p.setBool(_keyEmailNotifications, value));
  bool getEmailNotif() => _prefs?.getBool(_keyEmailNotifications) ?? false;

  Future<bool> saveSound(bool value) async => await _safeSave((p) => p.setBool(_keySoundNotifications, value));
  bool getSound() => _prefs?.getBool(_keySoundNotifications) ?? true;

  Future<bool> saveFrequency(int days) async => await _safeSave((p) => p.setInt(_keyReminderFrequency, days));
  int getFrequency() => _prefs?.getInt(_keyReminderFrequency) ?? 1;

  // --- КАТЕГОРІЇ ---
  Future<bool> saveCategories(List<String> categories) async => await _safeSave((p) => p.setStringList(_keyCategories, categories));
  List<String> getCategories() => _prefs?.getStringList(_keyCategories) ?? ['Спорт', 'Технології', 'Книги'];

  // --- ДОПОМІЖНІ МЕТОДИ ---
  Future<bool> _safeSave(Future<bool> Function(SharedPreferences p) action) async {
    try {
      if (_prefs == null) await init();
      return await action(_prefs!);
    } catch (e) {
      print('Помилка збереження даних: $e');
      return false;
    }
  }

  // Скинути до типових
  Future<bool> clearAll() async {
    try {
      if (_prefs == null) await init();
      return await _prefs!.clear();
    } catch (e) {
      print('Помилка очищення SharedPreferences: $e');
      return false;
    }
  }

  // Експорт у JSON
  Map<String, dynamic> exportToJson() {
    return {
      'profile': {
        'name': getName(),
        'email': getEmail(),
        'age': getAge(),
        'registration_date': getRegDate(),
      },
      'ui': {
        'theme': getTheme(),
        'font_size': getFontSize(),
        'language': getLanguage(),
        'compact_mode': getCompactMode(),
      },
      'notifications': {
        'push': getPush(),
        'email': getEmailNotif(),
        'sound': getSound(),
        'frequency_days': getFrequency(),
      },
      'categories': getCategories(),
    };
  }
}
