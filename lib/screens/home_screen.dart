import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../logic/profile_store.dart';
import '../models/facility.dart';
import '../widgets/facility_card.dart';
import '../widgets/facility_detail_sheet.dart';

class HomeScreen extends StatefulWidget {
    final void Function(int tab) onNavigate;
  final void Function(String query) onSearch;

  const HomeScreen({super.key, required this.onNavigate, required this.onSearch});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filter = 'all';
    String _insurance = '';
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadInsurance();
  }

  Future<void> _loadInsurance() async {
    final profile = await ProfileStore.load();
    if (mounted) setState(() => _insurance = profile.insurance);
  }

  List<Facility> get _filtered {
    final list = sampleFacilities.where((f) {
      if (_filter == 'open') return f.isOpen;
      if (_filter == 'lowwait') return f.wait < 15;
      if (_filter == 'innetwork') return f.acceptsInsurance(_insurance);
      return true;
    }).toList();
    list.sort((a, b) => a.totalTime.compareTo(b.totalTime));
    return list;
  }

  String get _emptyMessage {
    if (_filter == 'innetwork' && _insurance.isEmpty) {
      return 'Pick your insurance on the Profile tab to see in-network clinics.';
    }
    return 'No facilities match this filter. Try a different one.';
  }

  Widget _chip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) => setState(() => _filter = value),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0066FF), Color(0xFF002D75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Get care faster,\nnot closer',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Smart wait time estimates, guided symptom check, and visit planning in one app.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          TextField(controller: _search,
            decoration: InputDecoration(
              hintText: "What's bothering you? (e.g. sore throat)",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => widget.onSearch(_search.text),
              ),
            ),
            onSubmitted: widget.onSearch,
          ),
        ],
      ),
    );
  }

  Widget _action(IconData icon, Color color, String title, String subtitle, VoidCallback onTap) {
    return SizedBox(
      width: 150,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEmergency() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency'),
        content: const Text('If this is a life-threatening emergency, call 911 now.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => launchUrl(Uri.parse('tel:911')),
            child: const Text('Call 911'),
          ),
        ],
      ),
    );
  }

  void _showTelehealth() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Telehealth is coming in a later lesson.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _filtered;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _hero(),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _action(Icons.medical_services, const Color(0xFF0066FF), 'Symptom Check', 'Guided triage', () => widget.onNavigate(1)),
            _action(Icons.location_on, const Color(0xFFFF3B5C), 'Nearby Care', 'Live wait times', () => widget.onNavigate(2)),
            _action(Icons.show_chart, const Color(0xFF38A169), 'Best Time to Go', 'Plan your visit', () => widget.onNavigate(3)),
            _action(Icons.phone, const Color(0xFFE6A200), 'Emergency', 'Immediate help', _showEmergency),
            _action(Icons.videocam, const Color(0xFF805AD5), 'Telehealth', 'See a doctor now', _showTelehealth),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Recommended For You',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (_insurance.isNotEmpty && _insurance != 'No Insurance')
          Text(
            'Checking in-network status for $_insurance',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _chip('All', 'all'),
            _chip('Open Now', 'open'),
            _chip('Low Wait (<15m)', 'lowwait'),
            _chip('In-Network', 'innetwork'),
          ],
        ),
        const SizedBox(height: 12),
        if (sorted.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              _emptyMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        for (var i = 0; i < sorted.length; i++)
          GestureDetector(
            onTap: () => showFacilityDetail(context, sorted[i]),
            child: FacilityCard(
              facility: sorted[i],
              rank: i + 1,
              inNetwork: sorted[i].acceptsInsurance(_insurance),
            ),
          ),
      ],
    );
  }
}