import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/core/constants/app_constants.dart';
import 'package:trading_app/features/home/presentation/bloc/settings_bloc.dart';

import 'test_helpers.dart';

void main() {
  test('uses default tick rate and dark theme when storage is empty', () async {
    final bloc = SettingsBloc(await createStorage());

    expect(bloc.state.tickRateMs, AppConstants.defaultTickRateMs);
    expect(bloc.state.themeMode, ThemeMode.dark);
    await bloc.close();
  });

  test('loads persisted light and dark themes', () async {
    final light = SettingsBloc(await createStorage({
      'tick_rate_v1': 250,
      'theme_mode_v1': 'light',
    }));
    expect(light.state.tickRateMs, 250);
    expect(light.state.themeMode, ThemeMode.light);
    await light.close();

    final dark = SettingsBloc(await createStorage({
      'theme_mode_v1': 'dark',
    }));
    expect(dark.state.themeMode, ThemeMode.dark);
    await dark.close();

    final unknown = SettingsBloc(await createStorage({
      'theme_mode_v1': 'unexpected',
    }));
    expect(unknown.state.themeMode, ThemeMode.dark);
    await unknown.close();
  });

  test('persists tick-rate changes and preserves the theme', () async {
    final storage = await createStorage({
      'theme_mode_v1': 'light',
    });
    final bloc = SettingsBloc(storage);

    bloc.add(const SettingsTickRateChanged(200));
    await bloc.stream.first;

    expect(bloc.state.tickRateMs, 200);
    expect(bloc.state.themeMode, ThemeMode.light);
    expect(storage.readTickRate(), 200);
    await bloc.close();
  });

  test('persists theme changes and preserves the tick rate', () async {
    final storage = await createStorage({
      'tick_rate_v1': 500,
    });
    final bloc = SettingsBloc(storage);

    bloc.add(const SettingsThemeModeChanged(ThemeMode.light));
    await bloc.stream.first;

    expect(bloc.state.tickRateMs, 500);
    expect(bloc.state.themeMode, ThemeMode.light);
    expect(storage.readThemeMode(), 'light');
    await bloc.close();
  });

  test('equatable events and state expose their values', () {
    expect(
      const SettingsTickRateChanged(100),
      const SettingsTickRateChanged(100),
    );
    expect(
      const SettingsThemeModeChanged(ThemeMode.dark),
      const SettingsThemeModeChanged(ThemeMode.dark),
    );
    expect(SettingsState(tickRateMs: 1, themeMode: ThemeMode.dark),
        SettingsState(tickRateMs: 1, themeMode: ThemeMode.dark));
  });
}
