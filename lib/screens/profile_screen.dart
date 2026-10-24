import 'package:flutter/material.dart';
import '../logic/profile_store.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileData? _data;

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _allergies = TextEditingController();
  final _depName = TextEditingController();
  final _depAge = TextEditingController();
  String _depRelationship = 'Child';
  bool _showDependentForm = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_firstName, _lastName, _allergies, _depName, _depAge]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final data = await ProfileStore.load();
    _firstName.text = data.firstName;
    _lastName.text = data.lastName;
    _allergies.text = data.allergies;
    if (mounted) setState(() => _data = data);
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save({String? message}) async {
    final data = _data!;
    data.firstName = _firstName.text.trim();
    data.lastName = _lastName.text.trim();
    data.allergies = _allergies.text.trim();
    await ProfileStore.save(data);
    if (message != null && mounted) _toast(message);
  }

  void _addDependent() {
    final name = _depName.text.trim();
    final age = int.tryParse(_depAge.text.trim());
    if (name.isEmpty || age == null) {
      _toast('Please fill in name and age');
      return;
    }
    setState(() {
      _data!.dependents.add(Dependent(name: name, age: age, relationship: _depRelationship));
      _depName.clear();
      _depAge.clear();
      _showDependentForm = false;
    });
    _save(message: 'Dependent added');
  }

  void _removeDependent(int index) {
    setState(() {
      _data!.dependents.removeAt(index);
    });
    _save();
  }

  void _showPrivacy() {
    Widget heading(String text) => Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading('How We Handle Your Data'),
              const Text('QuickCare stores your preferences (insurance, pharmacy, dependents) only on this device. We do not send personal health information to external servers.'),
              heading('Location Data'),
              const Text('Your location is used only to find nearby facilities and calculate drive times. It is not stored or shared with third parties.'),
              heading('Medical Disclaimer'),
              const Text('QuickCare is not a substitute for professional medical advice, diagnosis, or treatment. The symptom checker provides general guidance only. Always consult a qualified healthcare provider.'),
              heading('Cost Estimates'),
              const Text('All cost figures are approximate ranges. Your actual costs will vary based on insurance coverage, treatment received, and facility billing.'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label,
      {ValueChanged<String>? onChanged, TextInputType? keyboard}) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboard,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    const visits = [
      ('QuickMed Urgent Care', 'Mar 8, 2026', 'Flu symptoms', '14 min', 5),
      ('Sunrise Hospital ER', 'Jan 22, 2026', 'Sprained ankle', '52 min', 4),
      ('CareNow Walk-In', 'Dec 5, 2025', 'Annual physical', '8 min', 5),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _section(
              icon: Icons.person,
              color: const Color(0xFF0066FF),
              title: 'Your Profile',
              subtitle: 'Manage your health preferences & insurance',
              children: [
                Row(
                  children: [
                    Expanded(child: _field(_firstName, 'First Name')),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_lastName, 'Last Name')),
                  ],
                ),
              ],
            ),
            _section(
              icon: Icons.shield,
              color: const Color(0xFF00C48C),
              title: 'Insurance Information',
              subtitle: "We'll match you with in-network facilities",
              children: [
                _label('Insurance Provider'),
                DropdownButton<String>(
                  value: data.insurance.isEmpty ? null : data.insurance,
                  hint: const Text('Select your provider...'),
                  isExpanded: true,
                  items: [
                    for (final o in insuranceOptions) DropdownMenuItem(value: o, child: Text(o)),
                  ],
                  onChanged: (v) {
                    setState(() => data.insurance = v ?? '');
                    _save();
                  },
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _save(message: 'Profile saved successfully'),
                  icon: const Icon(Icons.check),
                  label: const Text('Save Profile'),
                ),
              ],
            ),
            _section(
              icon: Icons.people,
              color: const Color(0xFF805AD5),
              title: 'Dependents',
              subtitle: 'Family members on your plan',
              children: [
                if (data.dependents.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No dependents added yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                for (var i = 0; i < data.dependents.length; i++)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(data.dependents[i].name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Age ${data.dependents[i].age} · ${data.dependents[i].relationship}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _removeDependent(i),
                    ),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _showDependentForm = !_showDependentForm),
                  icon: Icon(_showDependentForm ? Icons.close : Icons.add),
                  label: Text(_showDependentForm ? 'Cancel' : 'Add Dependent'),
                ),
                if (_showDependentForm) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(flex: 2, child: _field(_depName, 'Name')),
                      const SizedBox(width: 12),
                      Expanded(child: _field(_depAge, 'Age', keyboard: TextInputType.number)),
                    ],
                  ),
                  _label('Relationship'),
                  DropdownButton<String>(
                    value: _depRelationship,
                    isExpanded: true,
                    items: [
                      for (final r in relationshipOptions) DropdownMenuItem(value: r, child: Text(r)),
                    ],
                    onChanged: (v) => setState(() => _depRelationship = v ?? 'Child'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _addDependent,
                    icon: const Icon(Icons.check),
                    label: const Text('Save Dependent'),
                  ),
                ],
              ],
            ),
            _section(
              icon: Icons.tune,
              color: const Color(0xFF0066FF),
              title: 'Care Preferences',
              subtitle: 'Customize your experience',
              children: [
                _label('Preferred Pharmacy'),
                DropdownButton<String>(
                  value: data.pharmacy.isEmpty ? null : data.pharmacy,
                  hint: const Text('Select pharmacy...'),
                  isExpanded: true,
                  items: [
                    for (final p in pharmacyOptions) DropdownMenuItem(value: p, child: Text(p)),
                  ],
                  onChanged: (v) {
                    setState(() => data.pharmacy = v ?? '');
                    _save();
                  },
                ),
                const SizedBox(height: 16),
                _field(_allergies, 'Allergies (e.g., Penicillin, Sulfa, Latex)', onChanged: (_) => _save()),
                _label('Preferred Care Mode'),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'in-person', label: Text('In-Person')),
                    ButtonSegment(value: 'telehealth', label: Text('Telehealth First')),
                    ButtonSegment(value: 'no-preference', label: Text('No Preference')),
                  ],
                  selected: {data.careMode},
                  onSelectionChanged: (s) {
                    setState(() => data.careMode = s.first);
                    _save();
                  },
                ),
              ],
            ),
            _section(
              icon: Icons.history,
              color: const Color(0xFFFFB020),
              title: 'Visit History',
              subtitle: 'Your recent care visits',
              children: [
                for (final (facility, date, reason, wait, rating) in visits)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(facility, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('$date · $reason'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Wait: $wait', style: const TextStyle(fontSize: 12)),
                        Text(
                          '${'★' * rating}${'☆' * (5 - rating)}',
                          style: const TextStyle(color: Color(0xFFE6A200)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            TextButton.icon(
              onPressed: _showPrivacy,
              icon: const Icon(Icons.lock, size: 16),
              label: const Text('Privacy Policy'),
            ),
          ],
        ),
      ),
    );
  }
}