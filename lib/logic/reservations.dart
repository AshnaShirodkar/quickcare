import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

const reservationStatuses = ['pending', 'confirmed', 'arrived', 'in-room', 'completed'];

String statusLabel(String status) {
  if (status == 'in-room') return 'In Room';
  if (status == 'no-show') return 'No-Show';
  if (status.isEmpty) return '';
  return status[0].toUpperCase() + status.substring(1);
}

List<(String, String)> nextStepsFor(String status) {
  switch (status) {
    case 'pending':
      return [('Confirm', 'confirmed'), ('Cancel', 'cancelled')];
    case 'confirmed':
      return [('Arrived', 'arrived'), ('No-Show', 'no-show'), ('Cancel', 'cancelled')];
    case 'arrived':
      return [('To Room', 'in-room')];
    case 'in-room':
      return [('Complete', 'completed')];
    default:
      return [];
  }
}

class Reservation {
  final String code;
  final String facilityName;
  final String patientName;
  final String phone;
  final String reason;
  final DateTime createdAt;
  final DateTime arrival;
  final String insurance;
  final String allergies;
  final String pharmacy;
  final bool intakeComplete;
  final bool isDemo;
  String status;
  String notes;

  Reservation({
    required this.code,
    required this.facilityName,
    required this.patientName,
    required this.phone,
    required this.reason,
    required this.createdAt,
    required this.arrival,
    this.insurance = '',
    this.allergies = '',
    this.pharmacy = '',
    this.intakeComplete = true,
    this.isDemo = false,
    this.status = 'pending',
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'confirmationCode': code,
        'facilityName': facilityName,
        'patientName': patientName,
        'phone': phone,
        'visitReason': reason,
        'createdAt': createdAt.toIso8601String(),
        'arrival': arrival.toIso8601String(),
        'insurance': insurance,
        'allergies': allergies,
        'pharmacy': pharmacy,
        'intakeComplete': intakeComplete,
        'isDemo': isDemo,
        'status': status,
        'notes': notes,
      };

  factory Reservation.fromJson(Map<String, dynamic> json) => Reservation(
        code: json['confirmationCode'] as String? ?? '',
        facilityName: json['facilityName'] as String? ?? '',
        patientName: json['patientName'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        reason: json['visitReason'] as String? ?? 'General Visit',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        arrival: DateTime.tryParse(json['arrival'] as String? ?? '') ?? DateTime.now(),
        insurance: json['insurance'] is String ? json['insurance'] as String : '',
        allergies: json['allergies'] as String? ?? '',
        pharmacy: json['pharmacy'] as String? ?? '',
        intakeComplete: json['intakeComplete'] as bool? ?? true,
        isDemo: json['isDemo'] as bool? ?? false,
        status: json['status'] as String? ?? 'pending',
        notes: json['notes'] as String? ?? '',
      );
}

String newConfirmationCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final random = Random();
  final letters = List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  return 'QC-$letters';
}

String formatTime(DateTime t) {
  final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final minute = t.minute.toString().padLeft(2, '0');
  final amPm = t.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $amPm';
}

String formatDate(DateTime t) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[t.month - 1]} ${t.day}, ${t.year}';
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class ReservationStore {
  static const _key = 'qc_reservations';
  static const _seededDayKey = 'qc_seeded_day';

  static Future<List<Reservation>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = jsonDecode(prefs.getString(_key) ?? '[]') as List<dynamic>;
    return [for (final r in list) Reservation.fromJson(r as Map<String, dynamic>)];
  }

  static Future<void> saveAll(List<Reservation> reservations) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode([for (final r in reservations) r.toJson()]));
  }

  static Future<Reservation> add(Reservation reservation) async {
    final all = await load();
    all.add(reservation);
    await saveAll(all);
    return reservation;
  }

  static Future<void> updateStatus(String code, String status) async {
    final all = await load();
    for (final r in all) {
      if (r.code == code) r.status = status;
    }
    await saveAll(all);
  }

  static Future<void> cancel(String code) => updateStatus(code, 'cancelled');

  static Future<void> saveNotes(String code, String notes) async {
    final all = await load();
    for (final r in all) {
      if (r.code == code) r.notes = notes;
    }
    await saveAll(all);
  }

  static Future<void> seedDemoIfNeeded({bool force = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = '${now.year}-${now.month}-${now.day}';
    if (!force && prefs.getString(_seededDayKey) == today) return;

    final all = await load();
    all.removeWhere((r) => r.isDemo);
    all.addAll(_demoReservations(now));
    await saveAll(all);
    await prefs.setString(_seededDayKey, today);
  }

  static List<Reservation> _demoReservations(DateTime now) {
    const first = ['Sarah', 'James', 'Maria', 'David', 'Emily', 'Robert', 'Linda', 'Michael', 'Jennifer', 'William'];
    const last = ['Johnson', 'Smith', 'Garcia', 'Williams', 'Brown', 'Davis', 'Martinez', 'Wilson', 'Anderson', 'Thomas'];
    const reasons = ['Sore Throat', 'Flu Symptoms', 'Minor Laceration', 'Sprained Ankle', 'Ear Infection', 'Rash', 'Back Pain', 'Allergic Reaction', 'UTI Symptoms', 'Headache'];
    const insurances = ['Blue Cross Blue Shield', 'UnitedHealthcare', 'Aetna', 'Cigna', 'Humana', 'No Insurance', 'Medicare', 'Medicaid (Nevada)', 'Kaiser Permanente', 'Aetna'];
    const statuses = ['pending', 'confirmed', 'confirmed', 'arrived', 'in-room', 'completed', 'completed', 'cancelled', 'no-show', 'pending'];
    const pharmacies = ['CVS', 'Walgreens', 'Rite Aid'];

    final random = Random();
    final start = DateTime(now.year, now.month, now.day, 7);
    final list = <Reservation>[];

    for (var i = 0; i < 10; i++) {
      final createdAt = start.add(Duration(minutes: i * 70 + random.nextInt(30)));
      list.add(Reservation(
        code: newConfirmationCode(),
        facilityName: 'QuickMed Urgent Care',
        patientName: '${first[i]} ${last[i]}',
        phone: '(702) 555-01${10 + i}',
        reason: reasons[i],
        createdAt: createdAt,
        arrival: createdAt.add(Duration(minutes: 10 + random.nextInt(30))),
        insurance: insurances[i],
        allergies: i % 3 == 0 ? 'Penicillin' : (i % 4 == 0 ? 'Sulfa, Latex' : 'None known'),
        pharmacy: pharmacies[i % 3],
        intakeComplete: i % 3 != 2,
        isDemo: true,
        status: statuses[i],
        notes: i == 4 ? 'Patient called ahead, running 5 min late' : '',
      ));
    }
    return list;
  }
}
