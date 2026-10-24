class Facility {
    final String name;
    final String type;
    final double miles;
    final int drive;
    final int wait;
    final double rating;
    final bool isOpen;

   const Facility({
     required this.name,
     required this.type,
     required this.miles,
     required this.drive,
     required this.wait,
     required this.rating,
     required this.isOpen,
   });

   int get totalTime => drive + wait;

   String get typeName {
     if (type == 'er') return 'Emergency Room';
     if (type == 'uc') return 'Urgent Care';
     return 'Clinic';
   }
 }

 const sampleFacilities = [
   Facility(name: 'Valley ER', type: 'er', miles: 2.4, drive: 8, wait: 42, rating: 4.1, isOpen: true),
   Facility(name: 'QuickMed Urgent Care', type: 'uc', miles: 1.1, drive: 4, wait: 12, rating: 4.6, isOpen: true),
   Facility(name: 'Lakeside Family Clinic', type: 'clinic', miles: 3.0, drive: 10, wait: 9, rating: 4.3, isOpen: false),
   Facility(name: 'Sunrise Urgent Care', type: 'uc', miles: 4.2, drive: 13, wait: 18, rating: 4.4, isOpen: true),
 ];
