import 'package:flutter/material.dart';
import '../models/facility.dart';

class Symptom {
  final String id;
  final String name;
  final IconData icon;

  const Symptom(this.id, this.name, this.icon);
}

const allSymptoms = [
  Symptom('fever', 'Fever', Icons.thermostat),
  Symptom('cough', 'Cough', Icons.air),
  Symptom('headache', 'Headache', Icons.psychology),
  Symptom('throat', 'Sore Throat', Icons.record_voice_over),
  Symptom('stomach', 'Stomach Pain', Icons.sick),
  Symptom('chest', 'Chest Pain', Icons.monitor_heart),
  Symptom('breathing', 'Breathing Issues', Icons.masks),
  Symptom('injury', 'Injury/Cut', Icons.healing),
  Symptom('rash', 'Skin Rash', Icons.back_hand),
  Symptom('back', 'Back Pain', Icons.accessibility_new),
  Symptom('ear', 'Ear Pain', Icons.hearing),
  Symptom('eye', 'Eye Issues', Icons.visibility),
  Symptom('nausea', 'Nausea/Vomiting', Icons.sick_outlined),
  Symptom('allergy', 'Allergic Reaction', Icons.coronavirus),
  Symptom('uti', 'UTI Symptoms', Icons.water_drop),
  Symptom('anxiety', 'Anxiety/Panic', Icons.self_improvement),
];

const ageOptions = {
  'under18': 'Under 18',
  '18-39': '18-39',
  '40-64': '40-64',
  '65+': '65+',
};

const flagOptions = {
  'pregnant': 'Pregnant',
  'fever103': 'Fever over 103°F',
  'chronic': 'Chronic conditions',
  'bloodthinners': 'On blood thinners',
};

class TriageOption {
  final String id;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  const TriageOption(this.id, this.title, this.subtitle, this.color, this.icon);
}

const severityOptions = [
  TriageOption('mild', 'Mild', 'Uncomfortable but manageable', Color(0xFF00875A), Icons.sentiment_satisfied),
  TriageOption('moderate', 'Moderate', 'Significant discomfort, affecting daily activities', Color(0xFFE6A200), Icons.sentiment_neutral),
  TriageOption('severe', 'Severe', 'Intense pain or symptoms, hard to function', Color(0xFFFF3B5C), Icons.sentiment_dissatisfied),
  TriageOption('emergency', 'Emergency', 'Life-threatening, difficulty breathing, chest pain', Color(0xFFD32F2F), Icons.warning),
];

const durationOptions = [
  TriageOption('hours', 'Just started', 'Less than 24 hours ago', Color(0xFF0066FF), Icons.schedule),
  TriageOption('days', 'A few days', '2-5 days', Color(0xFF0066FF), Icons.today),
  TriageOption('week', 'About a week', '5-10 days', Color(0xFFE6A200), Icons.date_range),
  TriageOption('chronic', 'More than a week', 'Ongoing or recurring', Color(0xFFFF3B5C), Icons.calendar_month),
];

class TriageResult {
  final String level;
  final String title;
  final String subtitle;
  final List<String> advice;
  final Facility? facility;
  final bool showTelehealth;

  const TriageResult({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.advice,
    required this.facility,
    required this.showTelehealth,
  });
}

Facility? bestFacility(List<Facility> all, String type) {
  var pool = all.where((f) => type == 'er' ? f.type == 'er' : f.type != 'er').toList();
  if (pool.isEmpty) pool = [...all];
  if (pool.isEmpty) return null;
  pool.sort((a, b) => a.totalTime.compareTo(b.totalTime));
  return pool.first;
}

String _stepUp(String severity) {
  if (severity == 'mild') return 'moderate';
  if (severity == 'moderate') return 'severe';
  return 'emergency';
}

TriageResult runTriage({
  required Set<String> symptoms,
  required String age,
  required Set<String> flags,
  required String severity,
  required String duration,
  required List<Facility> facilities,
}) {
  final escalate = age == '65+' ||
      age == 'under18' ||
      flags.contains('pregnant') ||
      flags.contains('fever103');
  final bloodThinnerInjury = flags.contains('bloodthinners') && symptoms.contains('injury');

  var effective = severity;
  if (bloodThinnerInjury) {
    effective = 'emergency';
  } else if (escalate) {
    effective = _stepUp(severity);
  }

  final isEmergency = effective == 'emergency' ||
      symptoms.contains('chest') ||
      symptoms.contains('breathing');
  final isMild = effective == 'mild' && duration == 'hours';
  final showTelehealth = (effective == 'mild' || effective == 'moderate') &&
      (duration == 'hours' || duration == 'days');

  String visit(Facility? f) => f == null
      ? 'Visit the nearest facility.'
      : '${f.name}: ${f.wait} min wait, ${f.miles} mi away (${f.drive} min drive).';

  String level;
  String title;
  String subtitle;
  List<String> advice;
  Facility? facility;

  if (isEmergency) {
    facility = bestFacility(facilities, 'er');
    level = 'er';
    title = 'Go to Emergency Room';
    subtitle = 'Your symptoms may require immediate attention';
    advice = [
      'If life-threatening, call 911 immediately.',
      visit(facility),
      'Do not delay care.',
      'Bring insurance card and ID.',
    ];
    if (bloodThinnerInjury) {
      advice.add('Note: blood thinner use with an injury requires ER evaluation.');
    }
  } else if (effective == 'severe') {
    facility = bestFacility(facilities, 'uc');
    level = 'uc';
    title = 'Visit Urgent Care';
    subtitle = 'Your symptoms warrant prompt attention';
    advice = [
      visit(facility),
      'A provider can evaluate and prescribe today.',
      'Best: early morning or after 6 PM.',
      'If symptoms worsen, go to ER.',
    ];
  } else if (isMild) {
    final later = bestFacility(facilities, 'uc');
    facility = null;
    level = 'home';
    title = 'Home Care Recommended';
    subtitle = 'Your symptoms appear mild';
    advice = [
      'Rest, hydrate, take OTC medication.',
      'Consider telehealth for a professional opinion.',
      'If symptoms persist 48h+, visit ${later?.name ?? 'an urgent care'}.',
      'Seek ER for high fever, breathing difficulty, chest pain.',
    ];
  } else {
    facility = bestFacility(facilities, 'uc');
    level = 'uc';
    title = 'Visit Urgent Care';
    subtitle = 'We recommend getting checked';
    advice = [
      visit(facility),
      'A provider should evaluate you today.',
      'Current waits are below average.',
      'Estimated copay: \$25-\$75.',
    ];
  }

  if (escalate && effective != severity) {
    advice.add('Note: severity was raised based on your age or health factors.');
  }

  return TriageResult(
    level: level,
    title: title,
    subtitle: subtitle,
    advice: advice,
    facility: facility,
    showTelehealth: showTelehealth,
  );
}

const symptomKeywords = {
  'fever': ['fever', 'temperature', 'chills'],
  'cough': ['cough'],
  'headache': ['headache', 'head', 'migraine'],
  'throat': ['throat'],
  'stomach': ['stomach', 'belly', 'abdomen', 'abdominal'],
  'chest': ['chest'],
  'breathing': ['breath', 'breathing', 'asthma', 'wheez'],
  'injury': ['injury', 'cut', 'wound', 'bleeding', 'sprain', 'burn'],
  'rash': ['rash', 'itch', 'skin', 'hives'],
  'back': ['back'],
  'ear': ['ear'],
  'eye': ['eye', 'vision'],
  'nausea': ['nausea', 'vomit', 'throwing up', 'nauseous'],
  'allergy': ['allerg', 'swelling'],
  'uti': ['uti', 'urinary', 'bladder'],
  'anxiety': ['anxiety', 'anxious', 'panic'],
};

Set<String> findSymptoms(String query) {
  final text = query.toLowerCase();
  final found = <String>{};
  symptomKeywords.forEach((id, words) {
    for (final word in words) {
      if (RegExp(r'\b' + RegExp.escape(word)).hasMatch(text)) {
        found.add(id);
        break;
      }
    }
  });
  return found;
}