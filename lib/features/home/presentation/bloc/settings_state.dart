import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class SettingsTickRateChanged extends SettingsEvent {
  final int ms;
  const SettingsTickRateChanged(this.ms);
  @override
  List<Object?> get props => [ms];
}

class SettingsThemeModeChanged extends SettingsEvent {
  final ThemeMode mode;
  const SettingsThemeModeChanged(this.mode);
  @override
  List<Object?> get props => [mode];
}

class SettingsState extends Equatable {
  final int tickRateMs;
  final ThemeMode themeMode;

  const SettingsState({required this.tickRateMs, required this.themeMode});

  @override
  List<Object?> get props => [tickRateMs, themeMode];
}
