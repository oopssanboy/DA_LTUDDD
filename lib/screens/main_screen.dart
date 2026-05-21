import 'package:flutter/material.dart';
import 'movies_screen.dart';
import 'tvs_screen.dart';
import 'search_screen.dart';
import 'watchlist_screen.dart';
import 'user_screen.dart';
import '../theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    MoviesScreen(),
    TvsScreen(),
    SearchScreen(),
    WatchlistScreen(),
    UserScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, 
      body: NeonBackground(
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 0),
          child: GlassContainer(
            borderRadius: 25, 
            padding: const EdgeInsets.symmetric(vertical: 1), 
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppTheme.neonPink,
              unselectedItemColor: Colors.white54,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Phim'),
                BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'TV'),
                BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
                BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Watchlist'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tôi'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}