import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/facility.dart';

void showFacilityDetail(BuildContext context, Facility f) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) => FacilityDetailSheet(facility: f),
  );
}

class FacilityDetailSheet extends StatelessWidget {
  final Facility facility;

  const FacilityDetailSheet({super.key, required this.facility});

  Future<void> _openDirections() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(facility.name)}',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final f = facility;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(f.typeName, style: const TextStyle(color: Color(0xFF0066FF))),
          Text(f.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            f.isOpen ? 'Open Now' : 'Closed',
            style: TextStyle(color: f.isOpen ? Colors.green : Colors.red),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _stat('${f.wait}m', 'wait'),
              _stat('${f.drive}m', 'drive'),
              _stat('${f.totalTime}m', 'total'),
              _stat('${f.rating}', 'rating'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openDirections,
              icon: const Icon(Icons.directions),
              label: const Text('Get Directions'),
            ),
          ),
        ],
      ),
    );
  }
}