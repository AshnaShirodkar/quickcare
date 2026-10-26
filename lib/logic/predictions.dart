import 'dart:math';
import '../models/facility.dart';

const predictDays = ['Today', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const firstHour = 6;
const lastHour = 22;

String hourLabel(int hour) {
  if (hour < 12) return '${hour}AM';
  if (hour == 12) return '12PM';
  return '${hour - 12}PM';
}

List<int> predictWaits(Facility facility, String day) {
  final random = Random(facility.name.hashCode + day.hashCode);
  final waits = <int>[];

  for (var hour = firstHour; hour <= lastHour; hour++) {
    double base = facility.wait.toDouble();

    if (hour >= 9 && hour <= 11) {
      base *= 1.8;
    } else if (hour >= 16 && hour <= 19) {
      base *= 1.5;
    } else if (hour >= 12 && hour <= 14) {
      base *= 1.3;
    } else if (hour >= 20) {
      base *= 0.6;
    } else {
      base *= 0.8;
    }

    if (day == 'Mon') base *= 1.2;
    if (day == 'Sat' || day == 'Sun') base *= 0.7;

    base += (random.nextDouble() - 0.5) * 10;
    waits.add(max(5, base.round()));
  }

  return waits;
}