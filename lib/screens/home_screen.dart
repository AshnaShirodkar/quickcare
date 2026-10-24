import 'package:flutter/material.dart';
import '../models/facility.dart';
import '../widgets/facility_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filter = 'all';

  List<Facility> get _filtered {
    final list = sampleFacilities.where((f) {
      if (_filter == 'open') return f.isOpen;
      if (_filter == 'lowwait') return f.wait < 15;
      return true;
    }).toList();
    list.sort((a, b) => a.totalTime.compareTo(b.totalTime));
    return list;
  }

  Widget _chip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _filter == value,
        onSelected: (_) => setState(() => _filter = value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _filtered;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Recommended For You',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _chip('All', 'all'),
            _chip('Open Now', 'open'),
            _chip('Low Wait (<15m)', 'lowwait'),
          ],
        ),
        const SizedBox(height: 12),
        if (sorted.isEmpty)
          const Text('No facilities match this filter. Try a different one.'),
        for (var i = 0; i < sorted.length; i++)
          FacilityCard(facility: sorted[i], rank: i + 1),
      ],
    );
  }
}
