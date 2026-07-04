import 'package:flutter/material.dart';
import 'japanese_screen.dart';
// import 'ielts_screen.dart'; // Ẩn tab IELTS theo yêu cầu tập trung vào Tiếng Nhật
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
                        ? AppColors.duoGreen.withValues(alpha: 0.25)
                        : (_selectedIndex == 1
                            ? AppColors.duoBlue.withValues(alpha: 0.25)
                            : AppColors.duoYellow.withValues(alpha: 0.25)),
                    destinations: [
                        NavigationDestination(
                            icon: const Icon(Icons.dashboard_outlined),
                            selectedIcon: const Icon(Icons.dashboard, color: AppColors.duoGreen),
                            label: "Tổng quan",
                        ),
                        NavigationDestination(
                            icon: const Icon(Icons.language_outlined),
                            selectedIcon: const Icon(Icons.language, color: AppColors.duoBlue),
                            label: "Tiếng Nhật N5",
                        ),
                        NavigationDestination(
                            icon: const Icon(Icons.smart_toy_outlined),
                            selectedIcon: const Icon(Icons.smart_toy, color: AppColors.duoYellow),
                            label: "3D AI Tutor",
                        ),
                    ],
                ),
            ),
        );
    }
}
