import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../logic/share_route.dart';
import '../models/facility.dart';
import 'reserve_sheet.dart';

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
    await launchUrl(Uri.parse(directionsUrl(facility)), mode: LaunchMode.externalApplication);
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
          if (f.insurance.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Accepts: ${f.insurance.join(', ')}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openDirections,
                  icon: const Icon(Icons.directions),
                  label: const Text('Directions'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: f.isOpen ? () => showReserveSheet(context, f) : null,
                  icon: const Icon(Icons.event_available),
                  label: Text(f.isOpen ? 'Reserve' : 'Closed'),
                ),
              ),
              const SizedBox(width: 8),
              Builder(
                builder: (buttonContext) => IconButton.outlined(
                  tooltip: 'Share route',
                  onPressed: () => shareRoute(buttonContext, f),
                  icon: const Icon(Icons.share),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}