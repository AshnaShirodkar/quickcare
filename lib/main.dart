import 'package:flutter/material.dart';
 
  void main() {
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

   final _pages = const [
     Center(child: Text('Home')),
     Center(child: Text('Symptom Checker')),
     Center(child: Text('Map')),
     Center(child: Text('Best Time')),
     Center(child: Text('Profile')),
   ];

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(title: const Text('QuickCare')),
       body: _pages[_tab],
       bottomNavigationBar: NavigationBar(
         selectedIndex: _tab,
         onDestinationSelected: (i) => setState(() => _tab = i),
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

