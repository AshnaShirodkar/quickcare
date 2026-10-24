class Facility {
  final String name;
  final String type;
  final double miles;
  final int drive;
  final int wait;
  final double rating;
  final bool isOpen;
  final List<String> insurance;

  const Facility({
    required this.name,
    required this.type,
    required this.miles,
    required this.drive,
    required this.wait,
    required this.rating,
    required this.isOpen,
    this.insurance = const [],
  });

  int get totalTime => drive + wait;

  String get typeName {
    if (type == 'er') return 'Emergency Room';
    if (type == 'uc') return 'Urgent Care';
    return 'Clinic';
  }

  bool acceptsInsurance(String userInsurance) {
    if (userInsurance.isEmpty || userInsurance == 'No Insurance') return false;

    var short = userInsurance;
    if (userInsurance.contains('Blue Cross')) short = 'BCBS';
    if (userInsurance.contains('United')) short = 'UHC';

    final mine = short.toLowerCase();
    return insurance.any((plan) {
      final theirs = plan.toLowerCase();
      return mine.contains(theirs) || theirs.contains(mine);
    });
  }
}

const sampleFacilities = [
  Facility(
    name: 'Valley ER',
    type: 'er',
    miles: 2.4,
    drive: 8,
    wait: 42,
    rating: 4.1,
    isOpen: true,
    insurance: ['BCBS', 'Aetna', 'UHC', 'Cigna', 'Medicare', 'Medicaid'],
  ),
  Facility(
    name: 'QuickMed Urgent Care',
    type: 'uc',
    miles: 1.1,
    drive: 4,
    wait: 12,
    rating: 4.6,
    isOpen: true,
    insurance: ['BCBS', 'Aetna', 'UHC', 'Cigna', 'Humana'],
  ),
  Facility(
    name: 'Lakeside Family Clinic',
    type: 'clinic',
    miles: 3.0,
    drive: 10,
    wait: 9,
    rating: 4.3,
    isOpen: false,
    insurance: ['BCBS', 'Aetna', 'Cigna'],
  ),
  Facility(
    name: 'Sunrise Urgent Care',
    type: 'uc',
    miles: 4.2,
    drive: 13,
    wait: 18,
    rating: 4.4,
    isOpen: true,
    insurance: ['UHC', 'Cigna', 'Humana', 'Kaiser'],
  ),
];