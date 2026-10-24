import 'package:flutter/material.dart';
import '../logic/profile_store.dart';
import '../logic/reservations.dart';
import '../models/facility.dart';

Future<void> showReserveSheet(BuildContext context, Facility facility) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => ReserveSheet(facility: facility),
  );
}

class ReserveSheet extends StatefulWidget {
  final Facility facility;

  const ReserveSheet({super.key, required this.facility});

  @override
  State<ReserveSheet> createState() => _ReserveSheetState();
}

class _ReserveSheetState extends State<ReserveSheet> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _reason = TextEditingController();
  late final DateTime _arrival = DateTime.now().add(Duration(minutes: widget.facility.drive));
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _prefillName();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _prefillName() async {
    final profile = await ProfileStore.load();
    final fullName = '${profile.firstName} ${profile.lastName}'.trim();
    if (mounted && _name.text.isEmpty) _name.text = fullName;
  }

  Future<void> _confirm() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your name');
      return;
    }
    if (_phone.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your phone number');
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final reason = _reason.text.trim();

    final saved = await ReservationStore.add(Reservation(
      code: newConfirmationCode(),
      facilityName: widget.facility.name,
      patientName: _name.text.trim(),
      phone: _phone.text.trim(),
      reason: reason.isEmpty ? 'General Visit' : reason,
      createdAt: DateTime.now(),
      arrival: _arrival,
    ));

    navigator.pop();
    messenger.showSnackBar(
      SnackBar(content: Text('Spot reserved at ${saved.facilityName}! Confirmation: ${saved.code}')),
    );
  }

  InputDecoration _box(String label, {String? hint}) {
    return InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder());
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.facility;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Reserve Your Spot',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              f.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              '${f.typeName} · ${f.miles} mi',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(controller: _name, decoration: _box('Patient Name')),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: _box('Phone Number', hint: '(555) 123-4567'),
            ),
            const SizedBox(height: 12),
            TextField(controller: _reason, decoration: _box('Reason for visit (optional)')),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: _box('Estimated Arrival'),
              child: Text('${formatTime(_arrival)} (${f.drive} min from now)'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _saving ? null : _confirm,
              icon: const Icon(Icons.check_circle),
              label: const Text('Confirm Reservation (Free)'),
            ),
            const SizedBox(height: 8),
            const Text(
              'No charge. Cancel anytime.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}