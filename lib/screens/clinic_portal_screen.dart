import 'package:flutter/material.dart';
import '../logic/clinic_settings.dart';
import '../logic/reservations.dart';
import '../widgets/reservation_detail_sheet.dart';
import 'clinic_settings_view.dart';

class ClinicPortalScreen extends StatelessWidget {
  const ClinicPortalScreen({super.key});

  String _longDate(DateTime d) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${days[d.weekday - 1]}, ${formatDate(d)}';
  }

  Color _staffingColor(String level) {
    if (level == 'surge') return const Color(0xFFFF3B5C);
    if (level == 'high') return const Color(0xFFE6A200);
    return const Color(0xFF00A876);
  }

  Widget _header(ClinicSettings s) {
    final staffColor = _staffingColor(s.staffing);

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(clinicFacilityName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(_longDate(DateTime.now()), style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilterChip(
                label: Text(s.isOpen ? 'Open' : 'Closed'),
                selected: s.isOpen,
                selectedColor: const Color(0xFFE6FFF5),
                onSelected: (v) => s.update(() => s.isOpen = v),
              ),
              FilterChip(
                label: Text(s.walkIns ? 'Walk-ins: Accepting' : 'Walk-ins: Paused'),
                selected: s.walkIns,
                selectedColor: const Color(0xFFE6FFF5),
                onSelected: (v) => s.update(() => s.walkIns = v),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: s.waitTime > 0 ? () => s.update(() => s.waitTime -= 1) : null,
                      icon: const Icon(Icons.remove, size: 18),
                    ),
                    Text('Wait ${s.waitTime} min', style: const TextStyle(fontWeight: FontWeight.w600)),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: s.waitTime < 120 ? () => s.update(() => s.waitTime += 1) : null,
                      icon: const Icon(Icons.add, size: 18),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: staffColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  s.staffingLabel,
                  style: TextStyle(fontWeight: FontWeight.bold, color: staffColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: clinicSettings,
      builder: (context, _) {
        final s = clinicSettings;
        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              _header(s),
              if (s.staffing == 'surge')
                Container(
                  width: double.infinity,
                  color: const Color(0xFFFF3B5C),
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    '⚠ SURGE MODE ACTIVE: all hands on deck',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              const Material(
                color: Colors.white,
                child: TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.checklist), text: 'Queue'),
                    Tab(icon: Icon(Icons.settings), text: 'Settings'),
                  ],
                ),
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    ClinicQueueView(),
                    ClinicSettingsView(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ClinicQueueView extends StatefulWidget {
  const ClinicQueueView({super.key});

  @override
  State<ClinicQueueView> createState() => _ClinicQueueViewState();
}

class _ClinicQueueViewState extends State<ClinicQueueView> {
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
            _summary(list),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("Today's Queue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${list.length} reservations', style: const TextStyle(color: Colors.grey)),
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