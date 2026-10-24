import 'package:flutter/material.dart';
  import '../models/facility.dart';
 
  class FacilityCard extends StatelessWidget {
    final Facility facility;
    final int rank;
 
    const FacilityCard({super.key, required this.facility, required this.rank});
 
   Color get timeColor {
     if (facility.totalTime <= 20) return const Color(0xFF00C48C);
     if (facility.totalTime <= 45) return const Color(0xFFFFB020);
     return const Color(0xFFFF3B5C);
   }

   @override
   Widget build(BuildContext context) {
     return Card(
       margin: const EdgeInsets.only(bottom: 12),
       child: Padding(
         padding: const EdgeInsets.all(16),
         child: Row(
           children: [
             CircleAvatar(
               backgroundColor: rank == 1 ? const Color(0xFFFFD700) : Colors.grey.shade300,
               child: Text('$rank'),
             ),
             const SizedBox(width: 16),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(facility.typeName, style: const TextStyle(fontSize: 12, color: Color(0xFF0066FF))),
                   Text(facility.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 4),
                   Text('${facility.miles} mi · ${facility.drive} min drive · ${facility.wait}m wait'),
                   Text(
                     facility.isOpen ? 'Open Now' : 'Closed',
                     style: TextStyle(color: facility.isOpen ? Colors.green : Colors.red),
                   ),
                 ],
               ),
             ),
             Column(
               children: [
                 Text('${facility.totalTime}m', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: timeColor)),
                 const Text('total time', style: TextStyle(fontSize: 12)),
               ],
             ),
           ],
         ),
       ),
     );
   }
 }
