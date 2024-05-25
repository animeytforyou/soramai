import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'settings_controller.dart';
import 'package:soramai/providers/anime_provider.dart';
import 'package:soramai/providers/allanime.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    // Define the list of providers
    final providers = [
      AllAnime(),
      // Add more providers here
    ];

    // Find the initial provider
    final initialProvider = providers.firstWhere(
      (provider) => provider.toString() == controller.provider.toString(),
      orElse: () => providers.first,
    );

    // Determine if the theme is dark
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme selection
            DropdownButton<ThemeMode>(
              value: controller.themeMode,
              onChanged: controller.updateThemeMode,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System Theme'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light Theme'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark Theme'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Language selection
            Row(
              children: [
                const Text('Language: '),
                Switch(
                  value: controller.isSub,
                  onChanged: (bool value) {
                    controller.updateLanguage(value);
                  },
                ),
                Text(controller.isSub ? 'Sub' : 'Dub'),
              ],
            ),
            const SizedBox(height: 16),

            // Provider selection
            CustomDropdown<AnimeProvider>(
              hintText: 'Select provider',
              hintBuilder: (context, hint) {
                return Text(
                  hint,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                );
              },
              initialItem: initialProvider,
              items: providers,
              onChanged: (AnimeProvider? newProvider) {
                if (newProvider != null) {
                  controller.updateProvider(newProvider);
                }
              },
              listItemBuilder: (context, provider, isSelected, onItemSelect) {
                return ListTile(
                  title: Text(
                    provider.toString(),
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
              decoration: CustomDropdownDecoration(
                listItemStyle: TextStyle(
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
                closedFillColor: Theme.of(context).cardColor,
                expandedFillColor: isDarkTheme
                    ? Colors.grey[850]
                    : Theme.of(context).cardColor,
                closedBorderRadius: BorderRadius.circular(8),
                expandedBorderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                closedBorder: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
