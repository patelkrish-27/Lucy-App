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

  static const _items = [
    _WorkspaceItem(
      'Sessions',
      'Control your connected agents',
      Icons.terminal_rounded,
    ),
    _WorkspaceItem(
      'Files',
      'Browse your connected workspace',
      Icons.folder_rounded,
    ),
    _WorkspaceItem(
      'Config',
      'Pair and customize Lucy',
      Icons.tune_rounded,
    ),
  ];

  final _pages = const [
    SessionsScreen(),
    FilesScreen(),
    ConfigScreen(),
  ];

  String get _title => _items[_index].title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: _WorkspaceButton(
        label: _title,
        onTap: _showWorkspaceMenu,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showWorkspaceMenu() {
    showGeneralDialog<void>(
      context: context,
      barrierLabel: 'Workspace',
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: .52),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => _WorkspaceOverlay(
        selectedIndex: _index,
        items: _items,
        onSelected: (value) {
          Navigator.of(context).pop();
          setState(() => _index = value);
        },
      ),
      transitionBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: .96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _WorkspaceButton extends StatelessWidget {
  const _WorkspaceButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: const Color(0xFF17131D).withValues(alpha: .94),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFB879FF).withValues(alpha: .32),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB879FF).withValues(alpha: .13),
                blurRadius: 22,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: Color(0xFFD9B6FF),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_up_rounded,
                size: 19,
                color: Color(0xFFAAA0B5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkspaceOverlay extends StatelessWidget {
  const _WorkspaceOverlay({
    required this.selectedIndex,
    required this.items,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<_WorkspaceItem> items;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(14, 20, 14, bottom + 14),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF15121B),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFFB879FF).withValues(alpha: .24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .38),
                    blurRadius: 34,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: const Color(0xFF9C5CFF).withValues(alpha: .10),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF62586B),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(10, 2, 10, 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 17,
                          color: Color(0xFFB879FF),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Lucy workspace',
                          style: TextStyle(
                            fontWeight: FontWeight.w750,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...List.generate(items.length, (index) {
                    final item = items[index];
                    final selected = index == selectedIndex;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(19),
                        onTap: () => onSelected(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFB879FF).withValues(alpha: .12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(19),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFFB879FF).withValues(alpha: .28)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xFFB879FF).withValues(alpha: .16)
                                      : const Color(0xFF25202B),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  item.icon,
                                  color: selected
                                      ? const Color(0xFFD9B6FF)
                                      : const Color(0xFFAAA0B5),
                                  size: 21,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.subtitle,
                                      style: const TextStyle(
                                        color: Color(0xFF8F8798),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (selected)
                                const Icon(
                                  Icons.check_rounded,
                                  color: Color(0xFFB879FF),
                                  size: 19,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkspaceItem {
  const _WorkspaceItem(this.title, this.subtitle, this.icon);

  final String title;
  final String subtitle;
  final IconData icon;
}
