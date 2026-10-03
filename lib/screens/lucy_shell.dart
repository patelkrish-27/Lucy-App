import 'package:flutter/material.dart';
import 'sessions_screen.dart';
import 'files_screen.dart';
import 'config_screen.dart';

class LucyShell extends StatefulWidget {
  const LucyShell({super.key});

  @override
  State<LucyShell> createState() => _LucyShellState();
}

class _LucyShellState extends State<LucyShell> {
  int _index = 0;

  final _pages = const [
    SessionsScreen(),
    FilesScreen(),
    ConfigScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        height: 74,
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.terminal_outlined),
            selectedIcon: Icon(Icons.terminal_rounded),
            label: 'Sessions',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Files',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Config',
          ),
        ],
      ),
    );
  }
}
