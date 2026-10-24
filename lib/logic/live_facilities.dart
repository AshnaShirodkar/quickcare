import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/facility.dart';

class LiveFacilities extends ChangeNotifier {
  List<Facility> _all = [...sampleFacilities];
  Map<String, int> _baseWait = {for (final f in sampleFacilities) f.name: f.wait};
  DateTime _updatedAt = DateTime.now();
  Timer? _timer;
  final _random = Random();

  List<Facility> get all => List.unmodifiable(_all);
  DateTime get updatedAt => _updatedAt;

  int get averageWait {
    if (_all.isEmpty) return 0;
    final total = _all.fold<int>(0, (sum, f) => sum + f.wait);
    return (total / _all.length).round();
  }

  void start({Duration every = const Duration(seconds: 5)}) {
    _timer?.cancel();
    _timer = Timer.periodic(every, (_) => _tick());
  }

  void _tick() {
    _all = [
      for (final f in _all) f.copyWith(wait: _nudge(f)),
    ];
    _updatedAt = DateTime.now();
    notifyListeners();
  }

  int _nudge(Facility f) {
    final base = _baseWait[f.name] ?? f.wait;
    final change = _random.nextInt(5) - 2;
    final low = max(3, base - 10);
    final high = base + 15;
    return (f.wait + change).clamp(low, high).toInt();
  }

  void replaceAll(List<Facility> facilities) {
    _all = [...facilities];
    _baseWait = {for (final f in facilities) f.name: f.wait};
    _updatedAt = DateTime.now();
    notifyListeners();
  }

    void updateFacility(String name, {int? wait, bool? isOpen}) {
    _all = [
      for (final f in _all) f.name == name ? f.copyWith(wait: wait, isOpen: isOpen) : f,
    ];
    if (wait != null) _baseWait[name] = wait;
    _updatedAt = DateTime.now();
    notifyListeners();
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final liveFacilities = LiveFacilities();