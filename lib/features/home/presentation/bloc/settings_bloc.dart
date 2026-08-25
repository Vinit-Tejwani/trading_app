import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_storage.dart';
import 'settings_state.dart';

export 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(this._storage)
      : super(SettingsState(
          tickRateMs: _storage.readTickRate() ?? AppConstants.defaultTickRateMs,
          themeMode: _parseTheme(_storage.readThemeMode()),
        )) {
    on<SettingsTickRateChanged>(_onTickRate);
    on<SettingsThemeModeChanged>(_onThemeMode);
  }

  final LocalStorage _storage;

  static ThemeMode _parseTheme(String? v) {
    switch (v) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.dark;
    }
  }

  Future<void> _onTickRate(
    SettingsTickRateChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await _storage.setTickRate(event.ms);
    emit(SettingsState(
      tickRateMs: event.ms,
      themeMode: state.themeMode,
    ));
  }

  Future<void> _onThemeMode(
    SettingsThemeModeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await _storage.setThemeMode(event.mode.name);
    emit(SettingsState(
      tickRateMs: state.tickRateMs,
      themeMode: event.mode,
    ));
  }
}
