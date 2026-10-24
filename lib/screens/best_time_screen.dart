import 'dart:math';
import 'package:flutter/material.dart';
import '../logic/predictions.dart';
import '../models/facility.dart';

class BestTimeScreen extends StatefulWidget {
  const BestTimeScreen({super.key});

  @override
  State<BestTimeScreen> createState() => _BestTimeScreenState();
}

class _BestTimeScreenState extends State<BestTimeScreen> {
  Facility _facility = sampleFacilities.first;
  String _day = 'Today';

  static const _green = Color(0xFF00C48C);
  static const _yellow = Color(0xFFFFB020);
  static const _red = Color(0xFFFF3B5C);
  static const _blue = Color(0xFF0066FF);

  Color _color(int wait) {
    if (wait <= 15) return _green;
    if (wait <= 35) return _yellow;
    return _red;
  }

  Widget _card(String title, Widget child) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _chart(List<int> waits) {
    final maxWait = waits.reduce(max);
    final nowHour = DateTime.now().hour;

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < waits.length; i++)
                Expanded(
                  child: Tooltip(
                    message: '${hourLabel(firstHour + i)}: ${waits[i]}m',
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 170 * waits[i] / maxWait,
                      decoration: BoxDecoration(
                        color: _color(waits[i]),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        border: _day == 'Today' && firstHour + i == nowHour
                            ? Border.all(color: _blue, width: 2)
                            : null,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var i = 0; i < waits.length; i++)
              Expanded(
                child: i.isEven
                    ? FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          hourLabel(firstHour + i),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      )
                    : const SizedBox(),
              ),
          ],
        ),
      ],
    );
  }

  Widget _insight(String value, String label, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tip(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final waits = predictWaits(_facility, _day);
    final minWait = waits.reduce(min);
    final maxWait = waits.reduce(max);
    final avgWait = (waits.reduce((a, b) => a + b) / waits.length).round();
    final bestHour = hourLabel(firstHour + waits.indexOf(minWait));
    final weekend = _day == 'Sat' || _day == 'Sun';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Best Time to Go',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Estimated wait patterns based on time-of-day modeling',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _card(
              'Select a facility',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<Facility>(
                    value: _facility,
                    isExpanded: true,
                    items: [
                      for (final f in sampleFacilities)
                        DropdownMenuItem(value: f, child: Text('${f.name} (${f.typeName})')),
                    ],
                    onChanged: (f) {
                      if (f != null) setState(() => _facility = f);
                    },
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final d in predictDays)
                        ChoiceChip(
                          label: Text(d),
                          selected: _day == d,
                          onSelected: (_) => setState(() => _day = d),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            _card('Predicted wait times by hour', _chart(waits)),
            Row(
              children: [
                _insight('${minWait}m', 'Shortest Wait', _green),
                _insight(bestHour, 'Best Time', _blue),
                _insight('${avgWait}m', 'Average Wait', _yellow),
                _insight('${maxWait}m', 'Peak Wait', _red),
              ],
            ),
            _card(
              'Visit tips',
              Column(
                children: [
                  _tip(Icons.auto_awesome, _blue,
                      'Best time: visit at $bestHour for about $minWait min wait.'),
                  _tip(Icons.lightbulb, _yellow,
                      'Avoid the 9-11 AM and 4-7 PM rushes. ${weekend ? 'Weekends have about 30% shorter waits.' : 'Weekends are about 30% less busy.'}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}