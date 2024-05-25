import 'package:flutter/material.dart';
import 'settings_service.dart';
import 'package:soramai/providers/anime_provider.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  // Make SettingsService a private variable so it is not used directly.
  final SettingsService _settingsService;

  // Make ThemeMode a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  late ThemeMode _themeMode;

  // Make language a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  late bool _isSub;

  // Make provider a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  late AnimeProvider _provider;

  // Allow Widgets to read the user's preferred ThemeMode.
  ThemeMode get themeMode => _themeMode;

  // Allow Widgets to read the user's preferred language.
  bool get isSub => _isSub;

  // Allow Widgets to read the user's preferred provider.
  AnimeProvider get provider => _provider;

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _isSub = await _settingsService.language();
    _provider = await _settingsService.provider();

    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    // Do not perform any work if new and old ThemeMode are identical
    if (newThemeMode == _themeMode) return;

    // Otherwise, store the new ThemeMode in memory
    _themeMode = newThemeMode;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService.updateThemeMode(newThemeMode);
  }

  /// Update and persist the language based on the user's selection.
  Future<void> updateLanguage(bool newIsSub) async {
    // Do not perform any work if new and old language are identical
    if (newIsSub == _isSub) return;

    // Otherwise, store the new language in memory
    _isSub = newIsSub;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService.updateLanguage(newIsSub);
  }

  /// Update and persist the provider based on the user's selection.
  Future<void> updateProvider(AnimeProvider newProvider) async {
    // Do not perform any work if new and old provider are identical
    if (newProvider.toString() == _provider.toString()) return;

    // Otherwise, store the new provider in memory
    _provider = newProvider;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService.updateProvider(newProvider);
  }
}
