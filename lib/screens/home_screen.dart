import 'package:flutter/material.dart';
 import '../models/facility.dart';
 import '../widgets/facility_card.dart';
 
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
         for (var i = 0; i < sorted.length; i++)
         FacilityCard(facility: sorted[i], rank: i + 1),
       ],
     );
   }
 }