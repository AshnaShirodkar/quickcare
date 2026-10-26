import 'package:flutter/material.dart';
import '../logic/profile_store.dart';

Future<void> showTelehealthSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const TelehealthSheet(),
  );
}

class TelehealthSheet extends StatefulWidget {
  const TelehealthSheet({super.key});

  @override
  State<TelehealthSheet> createState() => _TelehealthSheetState();
}

class _TelehealthSheetState extends State<TelehealthSheet> {
  String _pharmacy = '';
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    _loadPharmacy();
  }

  Future<void> _loadPharmacy() async {
    final profile = await ProfileStore.load();
    if (mounted) setState(() => _pharmacy = profile.pharmacy);
  }

  Widget _perk(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF00C48C)),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pharmacyLine = _pharmacy.isEmpty || _pharmacy == 'Other'
        ? 'Prescriptions sent to your pharmacy'
        : 'Prescriptions sent to your $_pharmacy';

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFE6F0FF),
              child: Icon(Icons.videocam, size: 36, color: Color(0xFF0066FF)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _connecting ? 'Connecting you to a provider…' : 'Connect with a Provider',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (!_connecting) ...[
            Text.rich(
              const TextSpan(
                text: 'Average wait: ',
                children: [
                  TextSpan(
                    text: 'Under 5 minutes',
                    style: TextStyle(color: Color(0xFF00C48C), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 20),
            _perk('Board-certified physicians 24/7'),
            _perk(pharmacyLine),
            _perk('Most insurance accepted, \$0-\$25 copay'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => setState(() => _connecting = true),
              icon: const Icon(Icons.videocam),
              label: const Text('Start Video Visit, \$49'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Or free with most insurance',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ] else ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              "You're 2nd in line. Estimated wait: about 4 minutes.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Demo only: no real video call is placed.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Leave Waiting Room'),
            ),
          ],
        ],
      ),
    );
  }
}