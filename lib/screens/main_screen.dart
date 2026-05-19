import 'package:flutter/material.dart';
import 'movies_screen.dart';
import 'tvs_screen.dart';
import 'watchlist_screen.dart';
import 'user_screen.dart';
import 'search_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    MoviesScreen(),
    TVsScreen(),
    WatchlistScreen(),
    UserScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo.png', height: 32),
            const SizedBox(width: 8),
            const Text('MoveTime', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen())),
          ),
        ],
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFFd97706),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Phim'),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'TVs'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Watchlist'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
        ],
      ),
    );
  }
}