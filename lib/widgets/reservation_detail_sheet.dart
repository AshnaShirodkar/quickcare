import 'package:flutter/material.dart';
import '../logic/reservations.dart';

Color statusColor(String status) {
  switch (status) {
    case 'pending':
      return const Color(0xFFE6A200);
    case 'confirmed':
      return const Color(0xFF0066FF);
    case 'arrived':
      return const Color(0xFF805AD5);
    case 'in-room':
      return const Color(0xFFDD6B20);
    case 'completed':
      return const Color(0xFF00A876);
    default:
      return const Color(0xFFFF3B5C);
  }
}

Widget statusBadge(String status) {
  final color = statusColor(status);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      statusLabel(status),
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
    ),
  );
}

Future<void> showReservationDetail(BuildContext context, Reservation reservation) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => ReservationDetailSheet(reservation: reservation),
  );
}

class ReservationDetailSheet extends StatefulWidget {
  final Reservation reservation;

  const ReservationDetailSheet({super.key, required this.reservation});

  @override
  State<ReservationDetailSheet> createState() => _ReservationDetailSheetState();
}

class _ReservationDetailSheetState extends State<ReservationDetailSheet> {
  late final _notes = TextEditingController(text: widget.reservation.notes);
  late String _status = widget.reservation.status;
  bool _notesSaved = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _setStatus(String next) async {
    await ReservationStore.updateStatus(widget.reservation.code, next);
    if (mounted) setState(() => _status = next);
  }

  Future<void> _saveNotes() async {
    await ReservationStore.saveNotes(widget.reservation.code, _notes.text.trim());
    if (mounted) setState(() => _notesSaved = true);
  }

  Widget _field(String label, String value) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(value.isEmpty ? '--' : value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _timeline() {
    final index = reservationStatuses.indexOf(_status);
    final stopped = _status == 'cancelled' || _status == 'no-show';

    return Row(
      children: [
        for (var i = 0; i < reservationStatuses.length; i++)
          Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: !stopped && i < index || _status == 'completed' && i == index
                      ? const Color(0xFF00C48C)
                      : !stopped && i == index
                          ? const Color(0xFF0066FF)
                          : Colors.grey.withValues(alpha: 0.3),
                  child: Icon(
                    !stopped && i <= index ? Icons.check : null,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusLabel(reservationStatuses[i]),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reservation;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.patientName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(r.code, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                statusBadge(_status),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _field('Phone', r.phone),
                _field('ETA', formatTime(r.arrival)),
                _field('Booked at', formatTime(r.createdAt)),
                _field('Visit reason', r.reason),
                _field('Facility', r.facilityName),
                _field('Insurance', r.insurance),
                _field('Allergies', r.allergies),
                _field('Pharmacy', r.pharmacy),
                _field('Intake', r.intakeComplete ? 'Complete' : 'Incomplete'),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Status Timeline', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _timeline(),
            if (_status == 'cancelled' || _status == 'no-show')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'This visit was marked ${statusLabel(_status)}.',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (label, next) in nextStepsFor(_status))
                  FilledButton.tonal(onPressed: () => _setStatus(next), child: Text(label)),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _notes,
              minLines: 3,
              maxLines: 6,
              onChanged: (_) {
                if (_notesSaved) setState(() => _notesSaved = false);
              },
              decoration: const InputDecoration(
                labelText: 'Clinic notes',
                hintText: 'Add notes about this patient...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _saveNotes,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Notes'),
                ),
                const SizedBox(width: 12),
                if (_notesSaved)
                  const Text('Saved ✓', style: TextStyle(color: Color(0xFF00A876))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
