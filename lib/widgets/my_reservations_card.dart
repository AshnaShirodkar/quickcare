import 'package:flutter/material.dart';
import '../logic/reservations.dart';

class MyReservationsCard extends StatefulWidget {
  const MyReservationsCard({super.key});

  @override
  State<MyReservationsCard> createState() => _MyReservationsCardState();
}

class _MyReservationsCardState extends State<MyReservationsCard> {
  List<Reservation>? _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await ReservationStore.load();
    final active = all.where((r) => r.status != 'cancelled' && r.status != 'no-show').toList();
    active.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (mounted) setState(() => _items = active);
  }

  Future<void> _cancel(Reservation r) async {
    await ReservationStore.cancel(r.code);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reservation ${r.code} cancelled')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFF0066FF),
                  child: Icon(Icons.event_available, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Reservations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Active reservations', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (items == null)
              const Center(child: CircularProgressIndicator())
            else if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No reservations yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              for (final r in items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(r.facilityName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${r.reason} · ${formatDate(r.createdAt)}\n'
                    'Arrive ${formatTime(r.arrival)} · ${r.code}',
                  ),
                  isThreeLine: true,
                  trailing: TextButton(
                    onPressed: () => _cancel(r),
                    child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}