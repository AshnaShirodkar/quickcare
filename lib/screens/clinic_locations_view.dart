import 'package:flutter/material.dart';
import '../logic/clinic_settings.dart';
import '../widgets/bar_charts.dart';

class _Location {
  final String name;
  final String area;
  final int wait;
  final int capacity;
  final int queue;
  final bool open;

  const _Location(this.name, this.area, this.wait, this.capacity, this.queue, this.open);
}

class ClinicLocationsView extends StatelessWidget {
  const ClinicLocationsView({super.key});

  static const _green = Color(0xFF00C48C);
  static const _amber = Color(0xFFFFB020);
  static const _red = Color(0xFFFF3B5C);

  Color _capacityColor(int capacity) {
    if (capacity < 60) return _green;
    if (capacity < 85) return _amber;
    return _red;
  }

  List<_Location> _locations(ClinicSettings s) {
    final w = s.waitTime;
    return [
      _Location('QuickMed - Main Campus', 'Las Vegas, NV', w, 72, 8, s.isOpen),
      _Location('QuickMed - Summerlin', 'Las Vegas, NV', (w * 0.8).round(), 45, 4, true),
      _Location('QuickMed - Henderson', 'Henderson, NV', (w * 1.6).round(), 91, 14, true),
      _Location('QuickMed - North Las Vegas', 'North Las Vegas, NV', (w * 0.6).round(), 33, 3, true),
    ];
  }

  Widget _stat(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _locationCard(BuildContext context, _Location loc, _Location lightest) {
    final color = _capacityColor(loc.capacity);

    return SizedBox(
      width: 360,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text(loc.area, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _stat('${loc.wait}m', 'Wait', color),
                  _stat('${loc.queue}', 'In Queue', const Color(0xFF0A1628)),
                  _stat('${loc.capacity}%', 'Capacity', color),
                  _stat(loc.open ? 'Open' : 'Closed', 'Status', loc.open ? _green : _red),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: loc.capacity / 100,
                  minHeight: 8,
                  color: color,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
              if (loc.capacity >= 85) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Demo: rerouting new patients to ${lightest.name}')),
                    ),
                    icon: const Icon(Icons.alt_route),
                    label: const Text('Reroute Patients'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: clinicSettings,
      builder: (context, _) {
        final locations = _locations(clinicSettings);
        final overloaded = locations.where((l) => l.capacity >= 85).toList();
        final lightest = locations.reduce((a, b) => a.capacity < b.capacity ? a : b);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Multi-Location Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Sample locations for the demo. Main Campus follows your Settings tab.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Card(
                  color: overloaded.isEmpty ? const Color(0xFFE6FFF5) : const Color(0xFFFFF8E6),
                  child: ListTile(
                    leading: Icon(
                      overloaded.isEmpty ? Icons.check_circle : Icons.lightbulb,
                      color: overloaded.isEmpty ? _green : _amber,
                    ),
                    title: Text(
                      overloaded.isEmpty
                          ? 'All locations operating within normal capacity.'
                          : 'Suggested action: ${overloaded.first.name} is at ${overloaded.first.capacity}% capacity. '
                              'Route new patients to ${lightest.name} (${lightest.wait}m wait).',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final loc in locations) _locationCard(context, loc, lightest),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Wait Times Comparison',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        HBarChart(
                          labelWidth: 140,
                          bars: [
                            for (final loc in locations)
                              HBar(
                                loc.name.replaceFirst('QuickMed - ', ''),
                                loc.wait.toDouble(),
                                _capacityColor(loc.capacity),
                                '${loc.wait}m',
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}