import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/calendar_page.dart';
import 'pages/choreography_page.dart';

void main() {
  runApp(BunheadScribbleApp());
}

class BunheadScribbleApp extends StatelessWidget {
  const BunheadScribbleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bunhead Scribble',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

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