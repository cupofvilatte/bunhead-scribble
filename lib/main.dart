import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/calendar_page.dart';
import 'pages/choreography_page.dart';

void main() {
  runApp(BunheadScribbleApp());
}

class BunheadScribbleApp extends StatefulWidget {
  const BunheadScribbleApp({super.key});

  @override
  _BunheadScribbleAppState createState() => _BunheadScribbleAppState();
}

class _BunheadScribbleAppState extends State<BunheadScribbleApp> {
  bool _isDarkTheme = false;

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bunhead Scribble',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        brightness: _isDarkTheme ? Brightness.dark : Brightness.light,
        appBarTheme: AppBarTheme(
          backgroundColor: _isDarkTheme ? Colors.grey[900] : Colors.pink,
          foregroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: _isDarkTheme ? Colors.grey[850] : Colors.white,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: _isDarkTheme ? Colors.grey[900] : Colors.white,
          selectedItemColor: Colors.pink,
          unselectedItemColor: Colors.grey,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isDarkTheme ? Colors.pinkAccent : Colors.pink,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: MainNavigation(
        toggleTheme: _toggleTheme, // pass the function down
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final VoidCallback toggleTheme;
  
  const MainNavigation({super.key, required this.toggleTheme});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    CalendarPage(),
    ChoreographyPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bunhead Scribble'),
        actions: [
          IconButton(
            onPressed: widget.toggleTheme,
            icon: const Icon(Icons.color_lens),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_run), label: 'Choreo'),
        ],
      ),
    );
  }
}