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
      extendBody: true, // Cho phép nền tràn xuống dưới thanh điều hướng
      body: NeonBackground(
        child: _screens[_currentIndex],
      ),
      // Bọc SafeArea để nó không bị tràn xuống khu vực phím vuốt hệ thống
      bottomNavigationBar: SafeArea(
        child: Container(
          // Chỉnh margin để thanh điều hướng lơ lửng cách đáy và 2 bên 16px
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 0),
          child: GlassContainer(
            borderRadius: 25, // Bo góc cong tròn hẳn thành hình viên thuốc
            padding: const EdgeInsets.symmetric(vertical: 1), // Ép chiều cao lại cho gọn gàng
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.transparent, // Để lộ nền kính
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