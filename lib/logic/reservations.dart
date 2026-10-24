import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class Reservation {
  final String code;
  final String facilityName;
  final String patientName;
  final String phone;
  final String reason;
  final DateTime createdAt;
  final DateTime arrival;
  String status;

  Reservation({
    required this.code,
    required this.facilityName,
    required this.patientName,
    required this.phone,
    required this.reason,
    required this.createdAt,
    required this.arrival,
    this.status = 'confirmed',
  });

  Map<String, dynamic> toJson() => {
        'confirmationCode': code,
        'facilityName': facilityName,
        'patientName': patientName,
        'phone': phone,
        'visitReason': reason,
        'createdAt': createdAt.toIso8601String(),
        'arrival': arrival.toIso8601String(),
        'status': status,
      };

  factory Reservation.fromJson(Map<String, dynamic> json) => Reservation(
        code: json['confirmationCode'] as String? ?? '',
        facilityName: json['facilityName'] as String? ?? '',
        patientName: json['patientName'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        reason: json['visitReason'] as String? ?? 'General Visit',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        arrival: DateTime.tryParse(json['arrival'] as String? ?? '') ?? DateTime.now(),
        status: json['status'] as String? ?? 'confirmed',
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

class ReservationStore {
  static const _key = 'qc_reservations';

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

  static Future<void> cancel(String code) async {
    final all = await load();
    for (final r in all) {
      if (r.code == code) r.status = 'cancelled';
    }
    await saveAll(all);
  }
}