import 'package:flutter/material.dart';
import '../models/facility.dart';

class FacilityCard extends StatelessWidget {
  final Facility facility;
  final int rank;
  final bool inNetwork;

  const FacilityCard({
    super.key,
    required this.facility,
    required this.rank,
    this.inNetwork = false,
  });

  Color get timeColor {
    if (facility.totalTime <= 20) return const Color(0xFF00C48C);
    if (facility.totalTime <= 45) return const Color(0xFFFFB020);
    return const Color(0xFFFF3B5C);
  }

  Widget _badge(String text, Color background, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
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
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _badge(facility.typeName, const Color(0xFFE6F0FF), const Color(0xFF0066FF)),
                      if (rank == 1)
                        _badge('TOP PICK', const Color(0xFFE6FFF0), const Color(0xFF00875A)),
                      if (inNetwork)
                        _badge('IN-NETWORK', const Color(0xFF00C48C), Colors.white),
                    ],
                  ),
                  const SizedBox(height: 4),
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
                Text(
                  '${facility.totalTime}m',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: timeColor),
                ),
                const Text('total time', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}