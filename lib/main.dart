import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_colors.dart';
import 'theme/theme_notifier.dart';

import 'pages/home_page.dart';
import 'pages/calendar_page.dart';
import 'pages/choreography_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: BunheadScribbleApp(),
    ),
  );
}

class BunheadScribbleApp extends StatelessWidget {
  const BunheadScribbleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        final palette = themeNotifier.currentPalette;

        return MaterialApp(
          title: 'Bunhead Scribble',
          theme: ThemeData(
            brightness: themeNotifier.isDarkMode ? Brightness.dark : Brightness.light,
            primaryColor: palette.primary,
            scaffoldBackgroundColor: palette.background,
            appBarTheme: AppBarTheme(
              backgroundColor: palette.appBar,
              foregroundColor: palette.text,
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: palette.bottomNavBackground,
              selectedItemColor: palette.bottomNavSelected,
              unselectedItemColor: palette.bottomNavUnselected,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.accent,
                foregroundColor: Colors.white,
              ),
            ),
            textTheme: TextTheme(
              bodyMedium: TextStyle(color: palette.text),
            ),
          ),
          home: const MainNavigation(),
        );
      },
    );
  }
}

// class _BunheadScribbleAppState extends State<BunheadScribbleApp> {
//   bool _isDarkTheme = false;

//   void _toggleTheme() {
//     setState(() {
//       _isDarkTheme = !_isDarkTheme;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Bunhead Scribble',
//       theme: ThemeData(
//         brightness: _isDarkTheme ? Brightness.dark : Brightness.light,

//         scaffoldBackgroundColor: _isDarkTheme ? AppColors.darkBackground : AppColors.lightBackground,
      
//         primaryColor: _isDarkTheme ? AppColors.darkPrimary : AppColors.lightPrimary,

//         appBarTheme: AppBarTheme(
//           backgroundColor: _isDarkTheme ? AppColors.darkAppBar : AppColors.lightAppBar,

//           foregroundColor: Colors.white,
//         ),

//         bottomNavigationBarTheme: BottomNavigationBarThemeData(
//           backgroundColor: _isDarkTheme
//             ? AppColors.darkBottomNavBackground
//             : AppColors.lightBottomNavBackground,
//           selectedItemColor: _isDarkTheme
//             ? AppColors.darkBottomNavSelected
//             : AppColors.lightBottomNavSelected,
//           unselectedItemColor: _isDarkTheme
//             ? AppColors.darkBottomNavUnselected
//             : AppColors.lightBottomNavUnselected,
//         ),

//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor:
//               _isDarkTheme ? AppColors.darkAccent : AppColors.lightAccent,
//             foregroundColor: Colors.white,
//           ),
//         ),

//         textTheme: TextTheme(
//           bodyMedium: TextStyle(
//             color: _isDarkTheme ? AppColors.darkText : AppColors.lightText,
//           ),
//         ),
//       ),
//       home: MainNavigation(
//         toggleTheme: _toggleTheme, // pass the function down
//       ),
//     );
//   }
// }

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    HomePage(),
    CalendarPage(),
    ChoreographyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Get the notifier directly
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bunhead Scribble'),
        actions: [
          IconButton(
            onPressed: () => themeNotifier.toggleDarkMode(),
            icon: Icon(
              themeNotifier.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
          ),
          PopupMenuButton<AppTheme>(
            icon: const Icon(Icons.palette),
            onSelected: (theme) => themeNotifier.setTheme(theme),
            itemBuilder: (context) => AppColors.allThemes
              .map((theme) => PopupMenuItem(
                value: theme,
                child: Text(theme.name),
                ))
              .toList(),
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