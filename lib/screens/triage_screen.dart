import 'package:flutter/material.dart';
import '../logic/triage.dart';
import '../models/facility.dart';
import '../widgets/facility_detail_sheet.dart';

class TriageScreen extends StatefulWidget {
  const TriageScreen({super.key});

  @override
  State<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends State<TriageScreen> {
  int _step = 1;
  final Set<String> _symptoms = {};
  String _age = '';
  final Set<String> _flags = {};
  String? _severity;
  String? _duration;
  TriageResult? _result;

  void _warn(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _goToStep(int step) {
    if (step == 2 && _symptoms.isEmpty) {
      _warn('Please select at least one symptom');
      return;
    }
    if (step == 4 && _severity == null) {
      _warn('Please select severity');
      return;
    }
    setState(() => _step = step);
  }

  void _analyze() {
    if (_duration == null) {
      _warn('Please select duration');
      return;
    }
    setState(() {
      _result = runTriage(
        symptoms: _symptoms,
        age: _age,
        flags: _flags,
        severity: _severity!,
        duration: _duration!,
        facilities: sampleFacilities,
      );
      _step = 5;
    });
  }

  void _reset() {
    setState(() {
      _step = 1;
      _symptoms.clear();
      _age = '';
      _flags.clear();
      _severity = null;
      _duration = null;
      _result = null;
    });
  }

  Widget _dots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= 5; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == _step ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i <= _step ? const Color(0xFF0066FF) : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }

  Widget _question(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _navButtons({required int back, required String nextLabel, required VoidCallback onNext}) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(onPressed: () => _goToStep(back), child: const Text('Back')),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton(onPressed: onNext, child: Text(nextLabel)),
        ),
      ],
    );
  }

  Widget _step1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _question('What symptoms are you experiencing?'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in allSymptoms)
              FilterChip(
                avatar: Icon(s.icon, size: 18),
                label: Text(s.name),
                selected: _symptoms.contains(s.id),
                onSelected: (on) => setState(() {
                  if (on) {
                    _symptoms.add(s.id);
                  } else {
                    _symptoms.remove(s.id);
                  }
                }),
              ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(onPressed: () => _goToStep(2), child: const Text('Continue')),
        ),
      ],
    );
  }

  Widget _step2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _question('Tell us a bit about yourself'),
        const Text('Age range', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in ageOptions.entries)
              ChoiceChip(
                label: Text(e.value),
                selected: _age == e.key,
                onSelected: (_) => setState(() => _age = e.key),
              ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Check any that apply', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in flagOptions.entries)
              FilterChip(
                label: Text(e.value),
                selected: _flags.contains(e.key),
                onSelected: (on) => setState(() {
                  if (on) {
                    _flags.add(e.key);
                  } else {
                    _flags.remove(e.key);
                  }
                }),
              ),
          ],
        ),
        const SizedBox(height: 24),
        _navButtons(back: 1, nextLabel: 'Continue', onNext: () => _goToStep(3)),
      ],
    );
  }

  Widget _pickOne({
    required String question,
    required List<TriageOption> options,
    required String? selected,
    required void Function(String id) onPick,
    required int back,
    required String nextLabel,
    required VoidCallback onNext,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _question(question),
        for (final o in options)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: selected == o.id ? const Color(0xFF0066FF) : Colors.transparent,
                width: 2,
              ),
            ),
            child: ListTile(
              onTap: () => onPick(o.id),
              leading: CircleAvatar(
                backgroundColor: o.color.withValues(alpha: 0.15),
                child: Icon(o.icon, color: o.color),
              ),
              title: Text(o.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(o.subtitle),
            ),
          ),
        const SizedBox(height: 16),
        _navButtons(back: back, nextLabel: nextLabel, onNext: onNext),
      ],
    );
  }

  Widget _resultView() {
    final r = _result!;
    const colors = {
      'er': Color(0xFFFF3B5C),
      'uc': Color(0xFFFFB020),
      'home': Color(0xFF00C48C),
    };
    const icons = {
      'er': Icons.local_hospital,
      'uc': Icons.medical_services,
      'home': Icons.home,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors[r.level],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icons[r.level], color: Colors.white, size: 40),
              const SizedBox(height: 8),
              Text(
                r.title,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(r.subtitle, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final a in r.advice)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF0066FF), size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(a)),
              ],
            ),
          ),
        if (r.showTelehealth) ...[
          const SizedBox(height: 12),
          const Card(
            color: Color(0xFFF5F0FF),
            child: ListTile(
              leading: Icon(Icons.videocam, color: Color(0xFF805AD5)),
              title: Text('Skip the wait: see a provider by video'),
              subtitle: Text('Telehealth is coming in a later lesson.'),
            ),
          ),
        ],
        if (r.facility != null) ...[
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => showFacilityDetail(context, r.facility!),
            icon: const Icon(Icons.info_outline),
            label: Text('See ${r.facility!.name}'),
          ),
        ],
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.refresh),
          label: const Text('Start Over'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = switch (_step) {
      1 => _step1(),
      2 => _step2(),
      3 => _pickOne(
          question: 'How severe are your symptoms?',
          options: severityOptions,
          selected: _severity,
          onPick: (id) => setState(() => _severity = id),
          back: 2,
          nextLabel: 'Continue',
          onNext: () => _goToStep(4),
        ),
      4 => _pickOne(
          question: 'How long have you had these symptoms?',
          options: durationOptions,
          selected: _duration,
          onPick: (id) => setState(() => _duration = id),
          back: 3,
          nextLabel: 'Analyze Symptoms',
          onNext: _analyze,
        ),
      _ => _resultView(),
    };

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(Icons.monitor_heart, size: 48, color: Color(0xFF0066FF)),
            const SizedBox(height: 8),
            const Text(
              'Symptom Checker',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Tell us what's going on and we'll guide you to the right care",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _dots(),
            const SizedBox(height: 24),
            body,
            const SizedBox(height: 24),
            const Text(
              'QuickCare is not a medical diagnostic tool. Always seek professional medical advice for serious symptoms. Wait times are estimates and may vary.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}