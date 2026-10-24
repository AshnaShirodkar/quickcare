import 'package:flutter/material.dart';
 import '../models/facility.dart';
 
  class HomeScreen extends StatelessWidget {
    const HomeScreen({super.key});
 
    @override
    Widget build(BuildContext context) {
      final sorted = [...sampleFacilities];
     sorted.sort((a, b) => a.totalTime.compareTo(b.totalTime));

     return ListView(
       padding: const EdgeInsets.all(16),
       children: [
         const Text(
           'Recommended For You',
           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
         ),
         const SizedBox(height: 12),
         for (final f in sorted)
           Card(
             child: ListTile(
               title: Text(f.name),
               subtitle: Text('${f.typeName} · ${f.miles} mi · ${f.wait}m wait'),
               trailing: Text('${f.totalTime}m'),
             ),
           ),
       ],
     );
   }
 }