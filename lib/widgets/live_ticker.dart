import 'dart:math';
import 'package:flutter/material.dart';
import '../logic/reservations.dart';
import '../models/facility.dart';

class LiveTicker extends StatefulWidget {
  final List<Facility> facilities;
  final DateTime updatedAt;

  const LiveTicker({super.key, required this.facilities, required this.updatedAt});

  @override
  State<LiveTicker> createState() => _LiveTickerState();
}

class _LiveTickerState extends State<LiveTicker> with SingleTickerProviderStateMixin {
  final _scroll = ScrollController();
  late final AnimationController _animation;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(vsync: this, duration: const Duration(seconds: 30))
      ..addListener(_move)
      ..repeat();
  }

  @override
  void dispose() {
    _animation.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _move() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    final oneCopy = (position.maxScrollExtent + position.viewportDimension) / 4;
    _scroll.jumpTo(min(_animation.value * oneCopy, position.maxScrollExtent));
  }

  Color _dotColor(int wait) {
    if (wait <= 15) return const Color(0xFF00C48C);
    if (wait <= 35) return const Color(0xFFFFB020);
    return const Color(0xFFFF3B5C);
  }

  Widget _item(Facility f) {
    return Padding(
      padding: const EdgeInsets.only(right: 40),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: _dotColor(f.wait), shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '${f.name}: ${f.wait}m wait',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _oneCopy() {
    return Row(
      children: [
        for (final f in widget.facilities) _item(f),
        Padding(
          padding: const EdgeInsets.only(right: 40),
          child: Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: Colors.white38),
              const SizedBox(width: 4),
              Text(
                'Last updated: ${formatTime(widget.updatedAt)}',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A1628),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: [_oneCopy(), _oneCopy(), _oneCopy(), _oneCopy()],
        ),
      ),
    );
  }
}