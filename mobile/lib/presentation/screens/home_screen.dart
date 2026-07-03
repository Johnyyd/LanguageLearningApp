import 'package:flutter/material.dart';
import 'japanese_screen.dart';
import 'ielts_screen.dart';
import 'chat_tutor_screen.dart';
import 'dashboard_screen.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});

    @override
    State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    int _selectedIndex = 0;

    late final List<Widget> _screens = [
        DashboardScreen(onNavigate: (idx) => setState(() => _selectedIndex = idx)),
        const JapaneseScreen(),
        const IeltsScreen(),
        const ChatTutorScreen(),
    ];

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: IndexedStack(
                index: _selectedIndex,
                children: _screens,
            ),
            bottomNavigationBar: Container(
                decoration: BoxDecoration(
                    boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, -4)),
                    ],
                ),
                child: NavigationBar(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    indicatorColor: _selectedIndex == 0
                        ? AppColors.successGreen.withValues(alpha: 0.25)
                        : (_selectedIndex == 1
                            ? AppColors.sakuraPink.withValues(alpha: 0.25)
                            : (_selectedIndex == 2
                                ? AppColors.goldAccent.withValues(alpha: 0.25)
                                : AppColors.softIndigo.withValues(alpha: 0.25))),
                    destinations: [
                        NavigationDestination(
                            icon: const Icon(Icons.dashboard_outlined),
                            selectedIcon: Icon(Icons.dashboard, color: Theme.of(context).brightness == Brightness.dark ? AppColors.successGreen : AppColors.successGreen),
                            label: "Tổng quan",
                        ),
                        NavigationDestination(
                            icon: const Icon(Icons.language_outlined),
                            selectedIcon: Icon(Icons.language, color: Theme.of(context).brightness == Brightness.dark ? AppColors.sakuraPink : AppColors.deepIndigo),
                            label: "Tiếng Nhật N5",
                        ),
                        NavigationDestination(
                            icon: const Icon(Icons.edit_document),
                            selectedIcon: Icon(Icons.edit, color: Theme.of(context).brightness == Brightness.dark ? AppColors.goldAccent : AppColors.academicNavy),
                            label: "IELTS Writing",
                        ),
                        NavigationDestination(
                            icon: const Icon(Icons.smart_toy_outlined),
                            selectedIcon: Icon(Icons.smart_toy, color: Theme.of(context).brightness == Brightness.dark ? AppColors.sakuraPink : AppColors.sakuraPink),
                            label: "3D AI Tutor",
                        ),
                    ],
                ),
            ),
        );
    }
}
