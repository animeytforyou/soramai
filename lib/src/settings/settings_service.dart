import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soramai/providers/allanime.dart';
import 'package:soramai/providers/anime_provider.dart';

class SettingsService {
  static const _themeModeKey = 'theme_mode';
  static const _languageKey = 'language';
  static const _providerKey = 'provider';

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  /// Loads the User's preferred ThemeMode from local storage.
  Future<ThemeMode> themeMode() async {
    final prefs = await _prefs;
    final themeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    return ThemeMode.values[themeIndex];
  }

  /// Persists the user's preferred ThemeMode to local storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    final prefs = await _prefs;
    await prefs.setInt(_themeModeKey, theme.index);
  }

  /// Loads the User's preferred language from local storage.
  /// Returns true for "sub" and false for "dub".
  Future<bool> language() async {
    final prefs = await _prefs;
    return prefs.getBool(_languageKey) ?? true;
  }

  /// Persists the user's preferred language to local storage.
  /// Set true for "sub" and false for "dub".
  Future<void> updateLanguage(bool isSub) async {
    final prefs = await _prefs;
    await prefs.setBool(_languageKey, isSub);
  }

  /// Loads the User's preferred provider from local storage.
  Future<AnimeProvider> provider() async {
    final prefs = await _prefs;
    final providerName = prefs.getString(_providerKey) ?? AllAnime().toString();
    return _getProviderFromName(providerName);
  }

  /// Persists the user's preferred provider to local storage.
  Future<void> updateProvider(AnimeProvider provider) async {
    final prefs = await _prefs;
    await prefs.setString(_providerKey, provider.toString());
  }

  /// Helper method to get an AnimeProvider instance from its name.
  AnimeProvider _getProviderFromName(String name) {
    switch (name) {
      case 'AllAnime':
        return AllAnime();
      // Add more cases here if you have additional providers
      default:
        return AllAnime();
    }
  }
}
