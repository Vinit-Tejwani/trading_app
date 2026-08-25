import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class StorageExceptionMessages {
  StorageExceptionMessages._();

  static const localStorageNotInitialized =
      'Local storage is not initialized. Call LocalStorage.init().';
}

class LocalStorage {
  LocalStorage(this._prefs);

  final SharedPreferences _prefs;

  static LocalStorage? _instance;
  static LocalStorage get instance {
    final i = _instance;
    if (i == null) {
      throw StateError(StorageExceptionMessages.localStorageNotInitialized);
    }
    return i;
  }

  static Future<LocalStorage> init() async {
    final prefs = await SharedPreferences.getInstance();
    final ls = LocalStorage(prefs);
    _instance = ls;
    return ls;
  }

  Future<void> _writeJson(String key, Object value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  T? _readJson<T>(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as T;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveWatchlists(List<Map<String, dynamic>> data) =>
      _writeJson(AppConstants.prefKeyWatchlists, data);

  List<Map<String, dynamic>>? readWatchlists() =>
      _readJson<List<dynamic>>(AppConstants.prefKeyWatchlists)
          ?.cast<Map<String, dynamic>>();

  Future<void> saveHoldings(List<Map<String, dynamic>> data) =>
      _writeJson(AppConstants.prefKeyHoldings, data);

  List<Map<String, dynamic>>? readHoldings() =>
      _readJson<List<dynamic>>(AppConstants.prefKeyHoldings)
          ?.cast<Map<String, dynamic>>();

  Future<void> saveOrders(List<Map<String, dynamic>> data) =>
      _writeJson(AppConstants.prefKeyOrders, data);

  List<Map<String, dynamic>>? readOrders() =>
      _readJson<List<dynamic>>(AppConstants.prefKeyOrders)
          ?.cast<Map<String, dynamic>>();

  Future<void> saveWallet(Map<String, dynamic> data) =>
      _writeJson(AppConstants.prefKeyWallet, data);

  Map<String, dynamic>? readWallet() =>
      _readJson<Map<String, dynamic>>(AppConstants.prefKeyWallet);

  Future<void> setTickRate(int ms) =>
      _prefs.setInt(AppConstants.prefKeyTickRate, ms);

  int? readTickRate() => _prefs.getInt(AppConstants.prefKeyTickRate);

  Future<void> setThemeMode(String mode) =>
      _prefs.setString(AppConstants.prefKeyThemeMode, mode);

  String? readThemeMode() => _prefs.getString(AppConstants.prefKeyThemeMode);
}
