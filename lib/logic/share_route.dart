import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';
import '../models/facility.dart';

String directionsUrl(Facility f) {
  return 'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(f.name)}';
}

Future<void> shareRoute(BuildContext context, Facility f) async {
  final box = context.findRenderObject() as RenderBox?;
  final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;

  await SharePlus.instance.share(
    ShareParams(
      text: 'Directions to ${f.name} (${f.typeName}): ${directionsUrl(f)}',
      subject: 'QuickCare route',
      sharePositionOrigin: origin,
    ),
  );
}