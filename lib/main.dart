import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'logic/live_facilities.dart';
import 'logic/clinic_settings.dart';
import 'screens/best_time_screen.dart';
import 'screens/clinic_portal_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/triage_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await clinicSettings.load();
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
  bool _clinicMode = false;

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

  void _toggleMode() {
    setState(() => _clinicMode = !_clinicMode);
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
      appBar: AppBar(
        title: Text(_clinicMode ? 'QuickCare Clinic' : 'QuickCare'),
        backgroundColor: _clinicMode ? const Color(0xFF0A1628) : null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: _toggleMode,
              icon: Icon(_clinicMode ? Icons.person : Icons.local_hospital),
              label: Text(_clinicMode ? 'Patient mode' : 'Clinic mode'),
            ),
          ),
        ],
      ),
      body: _clinicMode ? const ClinicPortalScreen() : pages[_tab],
      bottomNavigationBar: _clinicMode
          ? null
          : NavigationBar(
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