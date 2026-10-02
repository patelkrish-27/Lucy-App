import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'tasks_screen.dart';
import 'activity_screen.dart';
import 'settings_screen.dart';

class LucyShell extends StatefulWidget {
  const LucyShell({super.key});

  @override
  State<LucyShell> createState() => _LucyShellState();
}

class _LucyShellState extends State<LucyShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    TasksScreen(),
    ActivityScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.checklist_rounded), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.bolt_outlined), selectedIcon: Icon(Icons.bolt_rounded), label: 'Activity'),
          NavigationDestination(icon: Icon(Icons.tune_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}
