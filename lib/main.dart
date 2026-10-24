import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'logic/live_facilities.dart';
import 'screens/home_screen.dart';
import 'screens/triage_screen.dart';
import 'screens/best_time_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  liveFacilities.start();
  runApp(const QuickCareApp());
}

class QuickCareApp extends StatelessWidget {
  const QuickCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0066FF),
        scaffoldBackgroundColor: const Color(0xFFF7FAFC),
        fontFamily: GoogleFonts.inter().fontFamily,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0066FF),
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;
  String? _triageQuery;

  void _goTo(int tab) {
    setState(() {
      _tab = tab;
      _triageQuery = null;
    });
  }

  void _searchSymptoms(String query) {
    setState(() {
      _triageQuery = query;
      _tab = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onNavigate: _goTo, onSearch: _searchSymptoms),
      TriageScreen(initialQuery: _triageQuery),
      const Center(child: Text('Map')),
      const BestTimeScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('QuickCare')),
      body: pages[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _goTo,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.healing), label: 'Triage'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.schedule), label: 'Best Time'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}