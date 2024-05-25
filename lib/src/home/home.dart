import 'package:flutter/material.dart';
import 'package:soramai/src/home/search.dart';
import 'package:soramai/src/settings/settings_view.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
  static const routeName = "/";
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () {
              Navigator.restorablePushNamed(context, SearchPage.routeName);
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: const Column(),
    );
  }
}
