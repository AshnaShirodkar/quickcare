import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Dependent {
  final String name;
  final int age;
  final String relationship;

  const Dependent({required this.name, required this.age, required this.relationship});

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'relationship': relationship,
      };

  factory Dependent.fromJson(Map<String, dynamic> json) => Dependent(
        name: json['name'] as String? ?? '',
        age: int.tryParse('${json['age']}') ?? 0,
        relationship: json['relationship'] as String? ?? 'Other',
      );
}

class ProfileData {
  String firstName = '';
  String lastName = '';
  String insurance = '';
  String pharmacy = '';
  String allergies = '';
  String careMode = 'no-preference';
  List<Dependent> dependents = [];
}

const insuranceOptions = [
  'UnitedHealthcare',
  'Blue Cross Blue Shield',
  'Aetna',
  'Cigna',
  'Humana',
  'Kaiser Permanente',
  'Molina Healthcare',
  'Medicaid (Nevada)',
  'Medicare',
  'No Insurance',
];

const pharmacyOptions = ['CVS', 'Walgreens', 'Rite Aid', 'Other'];

const relationshipOptions = ['Child', 'Spouse', 'Parent', 'Other'];

class ProfileStore {
  static const _profileKey = 'quickcare_profile';
  static const _dependentsKey = 'quickcare_dependents';
  static const _careModeKey = 'quickcare_caremode';

  static Future<ProfileData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = ProfileData();

    final profile = jsonDecode(prefs.getString(_profileKey) ?? '{}') as Map<String, dynamic>;
    data.firstName = profile['firstName'] as String? ?? '';
    data.lastName = profile['lastName'] as String? ?? '';
    data.insurance = profile['insurance'] as String? ?? '';
    data.pharmacy = profile['pharmacy'] as String? ?? '';
    data.allergies = profile['allergies'] as String? ?? '';

    final deps = jsonDecode(prefs.getString(_dependentsKey) ?? '[]') as List<dynamic>;
    data.dependents = [
      for (final d in deps) Dependent.fromJson(d as Map<String, dynamic>),
    ];

    data.careMode = prefs.getString(_careModeKey) ?? 'no-preference';
    return data;
  }

  static Future<void> save(ProfileData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _profileKey,
      jsonEncode({
        'firstName': data.firstName,
        'lastName': data.lastName,
        'insurance': data.insurance,
        'pharmacy': data.pharmacy,
        'allergies': data.allergies,
      }),
    );
    await prefs.setString(
      _dependentsKey,
      jsonEncode([for (final d in data.dependents) d.toJson()]),
    );
    await prefs.setString(_careModeKey, data.careMode);
  }
}