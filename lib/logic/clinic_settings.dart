import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'live_facilities.dart';

const clinicFacilityName = 'QuickMed Urgent Care';

const staffingLevels = {
  'normal': 'Normal',
  'high': 'High Volume',
  'surge': 'Surge Mode',
};

class ClinicSettings extends ChangeNotifier {
  static const _key = 'qc_clinic_settings';

  bool isOpen = true;
  bool walkIns = true;
  bool telehealth = true;
  int waitTime = 12;
  bool xray = true;
  bool lab = true;
  bool stitches = true;
  bool pediatric = true;
  String staffing = 'normal';

  String get staffingLabel => staffingLevels[staffing] ?? 'Normal';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      isOpen = json['isOpen'] as bool? ?? true;
      walkIns = json['walkIns'] as bool? ?? true;
      telehealth = json['telehealth'] as bool? ?? true;
      waitTime = (json['waitTime'] as num?)?.toInt() ?? 12;
      xray = json['xray'] as bool? ?? true;
      lab = json['lab'] as bool? ?? true;
      stitches = json['stitches'] as bool? ?? true;
      pediatric = json['pediatric'] as bool? ?? true;
      staffing = json['staffing'] as String? ?? 'normal';
    }
    _applyToPatientSide();
    notifyListeners();
  }

  void update(void Function() change) {
    change();
    waitTime = waitTime.clamp(0, 120).toInt();
    _applyToPatientSide();
    notifyListeners();
    _save();
  }

  void _applyToPatientSide() {
    liveFacilities.updateFacility(clinicFacilityName, wait: waitTime, isOpen: isOpen);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode({
        'isOpen': isOpen,
        'walkIns': walkIns,
        'telehealth': telehealth,
        'waitTime': waitTime,
        'xray': xray,
        'lab': lab,
        'stitches': stitches,
        'pediatric': pediatric,
        'staffing': staffing,
      }),
    );
  }
}

final clinicSettings = ClinicSettings();