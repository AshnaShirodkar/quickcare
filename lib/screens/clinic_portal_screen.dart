import 'package:flutter/material.dart';
import '../logic/reservations.dart';
import '../widgets/reservation_detail_sheet.dart';

class ClinicPortalScreen extends StatefulWidget {
  const ClinicPortalScreen({super.key});

  @override
  State<ClinicPortalScreen> createState() => _ClinicPortalScreenState();
}

class _ClinicPortalScreenState extends State<ClinicPortalScreen> {
  List<Reservation>? _today;

  @override
  void initState() {
    super.initState();
    _load(seed: true);
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _load({bool seed = false, bool reset = false}) async {
    if (seed || reset) await ReservationStore.seedDemoIfNeeded(force: reset);
    final all = await ReservationStore.load();
    final now = DateTime.now();
    final today = all.where((r) => isSameDay(r.createdAt, now)).toList();
    today.sort((a, b) => a.arrival.compareTo(b.arrival));
    if (mounted) setState(() => _today = today);
  }

  Future<void> _setStatus(Reservation r, String status) async {
    await ReservationStore.updateStatus(r.code, status);
    await _load();
    if (mounted) _toast('${r.patientName}: ${statusLabel(status)}');
  }

  Future<void> _openDetail(Reservation r) async {
    await showReservationDetail(context, r);
    await _load();
  }

  Widget _countCard(String value, String label, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color)),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summary(List<Reservation> list) {
    int count(List<String> statuses) => list.where((r) => statuses.contains(r.status)).length;
    return Row(
      children: [
        _countCard('${count(['pending', 'confirmed'])}', 'Waiting', statusColor('confirmed')),
        _countCard('${count(['arrived'])}', 'Arrived', statusColor('arrived')),
        _countCard('${count(['in-room'])}', 'In Room', statusColor('in-room')),
        _countCard('${count(['completed'])}', 'Completed', statusColor('completed')),
      ],
    );
  }

  Widget _queueCard(Reservation r) {
    final steps = nextStepsFor(r.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openDetail(r),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(r.patientName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  statusBadge(r.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${r.code} · ETA ${formatTime(r.arrival)} · ${r.reason}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              Text(
                '${r.insurance.isEmpty ? 'Insurance not given' : r.insurance} · '
                'Intake ${r.intakeComplete ? 'complete' : 'incomplete'}',
                style: TextStyle(
                  fontSize: 12,
                  color: r.intakeComplete ? Colors.grey : const Color(0xFFE6A200),
                ),
              ),
              if (!r.isDemo)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Booked in the patient app',
                    style: TextStyle(fontSize: 12, color: Color(0xFF0066FF), fontWeight: FontWeight.w600),
                  ),
                ),
              if (steps.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (label, next) in steps)
                      next == 'cancelled' || next == 'no-show'
                          ? OutlinedButton(
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                              onPressed: () => _setStatus(r, next),
                              child: Text(label),
                            )
                          : FilledButton.tonal(
                              onPressed: () => _setStatus(r, next),
                              child: Text(label),
                            ),
                  ],
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
    final list = _today;
    if (list == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'QuickMed Urgent Care',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Clinic dashboard · ${formatDate(DateTime.now())}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh queue',
                  onPressed: () async {
                    await _load();
                    if (mounted) _toast('Queue refreshed');
                  },
                  icon: const Icon(Icons.refresh),
                ),
                TextButton(
                  onPressed: () => _load(reset: true),
                  child: const Text('Reset demo'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _summary(list),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("Today's Queue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text('${list.length} reservations', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No reservations for today.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            for (final r in list) _queueCard(r),
          ],
        ),
      ),
    );
  }
}