import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'recipe_feed_screen.dart';
import 'brew_selection_screen.dart';
import 'toolkit_screen.dart';
import 'settings_screen.dart';
import '../services/audio_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    RecipeFeedScreen(),
    BrewSelectionScreen(),
    ToolkitScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          AudioService.playClick();
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            activeIcon: Icon(CupertinoIcons.house_fill),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book),
            activeIcon: Icon(CupertinoIcons.book_fill),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.timer),
            activeIcon: Icon(CupertinoIcons.timer_fill),
            label: 'Brew',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.wrench_fill),
            activeIcon: Icon(CupertinoIcons.wrench_fill),
            label: 'Toolkit',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            activeIcon: Icon(CupertinoIcons.person_solid),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
