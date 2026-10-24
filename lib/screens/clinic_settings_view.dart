import 'package:flutter/material.dart';
import '../logic/clinic_settings.dart';

class ClinicSettingsView extends StatelessWidget {
  const ClinicSettingsView({super.key});

  Widget _card(IconData icon, Color color, String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _switch(String title, bool value, ValueChanged<bool> onChanged, {String? subtitle}) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: clinicSettings,
      builder: (context, _) {
        final s = clinicSettings;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('Clinic Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _card(Icons.schedule, const Color(0xFF0066FF), 'Wait & Status', [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Current wait time'),
                    subtitle: const Text('Shown to patients in the app'),
                    trailing: Text(
                      '${s.waitTime} min',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Slider(
                    value: s.waitTime.toDouble(),
                    min: 0,
                    max: 120,
                    divisions: 24,
                    label: '${s.waitTime} min',
                    onChanged: (v) => s.update(() => s.waitTime = v.round()),
                  ),
                  _switch(
                    'Open',
                    s.isOpen,
                    (v) => s.update(() => s.isOpen = v),
                    subtitle: s.isOpen ? 'Patients can see you and reserve' : 'Shown as Closed to patients',
                  ),
                  _switch('Accepting walk-ins', s.walkIns, (v) => s.update(() => s.walkIns = v)),
                  _switch('Telehealth visits', s.telehealth, (v) => s.update(() => s.telehealth = v)),
                ]),
                _card(Icons.medical_services, const Color(0xFF00C48C), 'Services', [
                  _switch('X-Ray', s.xray, (v) => s.update(() => s.xray = v)),
                  _switch('Lab Work', s.lab, (v) => s.update(() => s.lab = v)),
                  _switch('Stitches', s.stitches, (v) => s.update(() => s.stitches = v)),
                  _switch('Pediatric', s.pediatric, (v) => s.update(() => s.pediatric = v)),
                ]),
                _card(Icons.groups, const Color(0xFFFFB020), 'Staffing', [
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: [
                      for (final e in staffingLevels.entries)
                        ButtonSegment(value: e.key, label: Text(e.value)),
                    ],
                    selected: {s.staffing},
                    onSelectionChanged: (v) => s.update(() => s.staffing = v.first),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Surge Mode shows a red banner across the clinic portal.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }
}