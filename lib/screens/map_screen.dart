import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../logic/live_facilities.dart';
import '../logic/maps_loader.dart';
import '../models/facility.dart';
import '../widgets/facility_detail_sheet.dart';

/// Demo "you are here" point in Las Vegas. Clinic distances in the sample data are measured from here.
const demoUserLocation = LatLng(36.1080, -115.1430);

/// google_maps_flutter only supports iOS, Android, and web (not macOS, Windows, or Linux).
bool get mapsSupported =>
    kIsWeb || defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android;

Color totalTimeColor(Facility f) {
  if (f.totalTime <= 20) return const Color(0xFF00C48C);
  if (f.totalTime <= 45) return const Color(0xFFFFB020);
  return const Color(0xFFFF3B5C);
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _filter = 'all';
  GoogleMapController? _controller;
  late final Future<void> _ready = mapsSupported ? ensureMapsLoaded() : Future.value();

  @override
  void initState() {
    super.initState();
    liveFacilities.addListener(_onLiveUpdate);
  }

  @override
  void dispose() {
    liveFacilities.removeListener(_onLiveUpdate);
    _controller?.dispose();
    super.dispose();
  }

  void _onLiveUpdate() {
    if (mounted) setState(() {});
  }

  List<Facility> get _visible {
    final list = liveFacilities.all
        .where((f) => f.lat != null && f.lng != null)
        .where((f) => _filter == 'all' || f.type == _filter)
        .toList();
    list.sort((a, b) => a.totalTime.compareTo(b.totalTime));
    return list;
  }

  double _hue(Facility f) {
    if (f.type == 'er') return BitmapDescriptor.hueRed;
    if (f.type == 'uc') return BitmapDescriptor.hueAzure;
    return BitmapDescriptor.hueGreen;
  }

  Set<Marker> _markers(List<Facility> facilities) {
    return {
      Marker(
        markerId: const MarkerId('you'),
        position: demoUserLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: const InfoWindow(title: 'You are here'),
      ),
      for (final f in facilities)
        Marker(
          markerId: MarkerId(f.name),
          position: LatLng(f.lat!, f.lng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(_hue(f)),
          alpha: f.isOpen ? 1 : 0.55,
          infoWindow: InfoWindow(
            title: f.name,
            snippet: '${f.totalTime}m total · ${f.wait}m wait · ${f.isOpen ? 'Open' : 'Closed'}  ›',
            onTap: () => showFacilityDetail(context, f),
          ),
        ),
    };
  }

  Future<void> _focus(Facility f) async {
    final controller = _controller;
    if (controller == null) {
      showFacilityDetail(context, f);
      return;
    }
    await controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(f.lat!, f.lng!), 14));
    await controller.showMarkerInfoWindow(MarkerId(f.name));
  }

  Widget _filterChips() {
    Widget chip(String label, String value) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(label),
            selected: _filter == value,
            onSelected: (_) => setState(() => _filter = value),
          ),
        );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: [
          chip('All', 'all'),
          chip('Urgent Care', 'uc'),
          chip('ER', 'er'),
          chip('Clinic', 'clinic'),
        ],
      ),
    );
  }

  Widget _facilityStrip(List<Facility> facilities, {required void Function(Facility) onTap}) {
    if (facilities.isEmpty) {
      return const Card(
        margin: EdgeInsets.all(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No facilities of this type nearby.', textAlign: TextAlign.center),
        ),
      );
    }
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        itemCount: facilities.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) => _FacilityMapCard(facility: facilities[i], onTap: () => onTap(facilities[i])),
      ),
    );
  }

  Widget _message(IconData icon, String title, String body, List<Facility> facilities) {
    return Column(
      children: [
        _filterChips(),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(body, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
        _facilityStrip(facilities, onTap: (f) => showFacilityDetail(context, f)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final facilities = _visible;

    if (!mapsSupported) {
      return _message(
        Icons.map_outlined,
        'The map runs on iPhone, Android, and web',
        "Google Maps doesn't support the macOS app. Run QuickCare on the iPhone simulator, an Android emulator, or Chrome to see the map.",
        facilities,
      );
    }

    return FutureBuilder<void>(
      future: _ready,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final missingKey = '${snapshot.error}'.contains('missing-key');
          return _message(
            Icons.key_off,
            missingKey ? 'Map needs a Google Maps key' : "Couldn't load Google Maps",
            missingKey
                ? 'Add MAPS_API_KEY to the .env file, then run with --dart-define-from-file=.env'
                : 'Check your internet connection and that the API key allows this site.',
            facilities,
          );
        }
        return Stack(
          children: [
            Positioned.fill(
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(target: demoUserLocation, zoom: 12),
                markers: _markers(facilities),
                onMapCreated: (controller) => _controller = controller,
                padding: const EdgeInsets.only(top: 56, bottom: 124),
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
            ),
            Positioned(top: 0, left: 0, right: 0, child: _filterChips()),
            Positioned(left: 0, right: 0, bottom: 0, child: _facilityStrip(facilities, onTap: _focus)),
          ],
        );
      },
    );
  }
}

class _FacilityMapCard extends StatelessWidget {
  final Facility facility;
  final VoidCallback onTap;

  const _FacilityMapCard({required this.facility, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final f = facility;
    return SizedBox(
      width: 230,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 3,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(f.typeName, style: const TextStyle(fontSize: 11, color: Color(0xFF0066FF), fontWeight: FontWeight.w600)),
                      Text(f.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        '${f.miles} mi · ${f.isOpen ? 'Open' : 'Closed'}',
                        style: TextStyle(fontSize: 12, color: f.isOpen ? Colors.green : Colors.red),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${f.totalTime}m', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: totalTimeColor(f))),
                    const Text('total', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
