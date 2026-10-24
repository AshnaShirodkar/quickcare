import 'dart:math';
import 'package:flutter/material.dart';
import '../logic/clinic_settings.dart';
import '../logic/predictions.dart';
import '../logic/reservations.dart';
import '../widgets/bar_charts.dart';

class ClinicAnalyticsView extends StatefulWidget {
  const ClinicAnalyticsView({super.key});

  @override
  State<ClinicAnalyticsView> createState() => _ClinicAnalyticsViewState();
}

class _ClinicAnalyticsViewState extends State<ClinicAnalyticsView> {
  List<Reservation>? _all;

  static const _blue = Color(0xFF0066FF);
  static const _green = Color(0xFF00C48C);
  static const _amber = Color(0xFFFFB020);
  static const _red = Color(0xFFFF3B5C);

  static const _inNetworkPlans = [
    'Blue Cross Blue Shield',
    'UnitedHealthcare',
    'Aetna',
    'Cigna',
    'Medicare',
    'Medicaid (Nevada)',
  ];

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await ReservationStore.load();
    if (mounted) setState(() => _all = all);
  }

  String _money(int amount) {
    final digits = amount.toString();
    final out = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
      out.write(digits[i]);
    }
    return '\$$out';
  }

  int _pct(int part, int whole) => whole == 0 ? 0 : (part * 100 / whole).round();

  Widget _kpi(String value, String label, Color color, {String? sub}) {
    return SizedBox(
      width: 170,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              if (sub != null) Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chartCard(String title, Widget chart, {String? note}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            chart,
            if (note != null) ...[
              const SizedBox(height: 8),
              Text(note, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final all = _all;
    if (all == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final now = DateTime.now();
    final today = all.where((r) => isSameDay(r.createdAt, now)).toList();

    int countIn(List<Reservation> list, bool Function(Reservation r) test) => list.where(test).length;

    final arrivals = countIn(today, (r) => ['arrived', 'in-room', 'completed'].contains(r.status));
    final completed = countIn(today, (r) => r.status == 'completed');
    final noShows = countIn(today, (r) => r.status == 'no-show');

    final hourBars = [
      for (var h = 7; h <= 19; h++)
        VBar(hourLabel(h), countIn(today, (r) => r.createdAt.hour == h).toDouble(), _blue),
    ];

    final reasonCounts = <String, int>{};
    for (final r in all) {
      reasonCounts[r.reason] = (reasonCounts[r.reason] ?? 0) + 1;
    }
    final topReasons = reasonCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    var inNetwork = 0;
    var outOfNetwork = 0;
    var selfPay = 0;
    for (final r in all) {
      if (r.insurance.isEmpty || r.insurance == 'No Insurance') {
        selfPay++;
      } else if (_inNetworkPlans.contains(r.insurance)) {
        inNetwork++;
      } else {
        outOfNetwork++;
      }
    }
    final insuranceTotal = inNetwork + outOfNetwork + selfPay;

    final weekBars = <VBar>[];
    for (var i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final real = countIn(all, (r) => isSameDay(r.createdAt, day));
      final sample = 3 + Random(day.year * 400 + day.month * 31 + day.day).nextInt(10);
      weekBars.add(VBar(
        _dayNames[day.weekday - 1],
        (real > 0 ? real : sample).toDouble(),
        real > 0 ? _blue : Colors.grey.shade400,
      ));
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Clinic Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                IconButton(tooltip: 'Refresh', onPressed: _load, icon: const Icon(Icons.refresh)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _kpi('${today.length}', "Today's Reservations", _blue),
                _kpi('$arrivals', 'Arrivals', _green, sub: '${_pct(completed, today.length)}% completed'),
                _kpi('${_pct(noShows, today.length)}%', 'No-Show Rate', _red),
                _kpi('${clinicSettings.waitTime + 6}m', 'Est. Wait-to-Room', _amber),
                _kpi(_money(completed * 300), 'Est. Revenue', _green, sub: 'about \$300 per visit'),
              ],
            ),
            const SizedBox(height: 16),
            _chartCard('Reservations by Hour (today)', VBarChart(bars: hourBars)),
            _chartCard(
              'Top Visit Reasons',
              HBarChart(bars: [
                for (final e in topReasons.take(6)) HBar(e.key, e.value.toDouble(), _blue, '${e.value}'),
              ]),
            ),
            _chartCard(
              'Insurance Mix',
              HBarChart(bars: [
                HBar('In-Network', inNetwork.toDouble(), _green, '${_pct(inNetwork, insuranceTotal)}%'),
                HBar('Out-of-Network', outOfNetwork.toDouble(), _amber, '${_pct(outOfNetwork, insuranceTotal)}%'),
                HBar('Self-Pay', selfPay.toDouble(), Colors.grey, '${_pct(selfPay, insuranceTotal)}%'),
              ]),
            ),
            _chartCard(
              'Weekly Trend (last 7 days)',
              VBarChart(bars: weekBars),
              note: 'Blue = real bookings. Grey = sample data for days with no bookings yet.',
            ),
            _chartCard(
              'Visit Funnel (today)',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HBarChart(bars: [
                    HBar('Reservations', today.length.toDouble(), _blue, '${today.length}'),
                    HBar('Arrivals', arrivals.toDouble(), _amber, '$arrivals'),
                    HBar('Completed', completed.toDouble(), _green, '$completed'),
                  ]),
                  const SizedBox(height: 8),
                  Text(
                    '${_pct(arrivals, today.length)}% of reservations arrived · '
                    '${_pct(completed, arrivals)}% of arrivals completed',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
