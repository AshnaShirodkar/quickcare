import 'dart:math';
import 'package:flutter/material.dart';

class HBar {
  final String label;
  final double value;
  final Color color;
  final String text;

  const HBar(this.label, this.value, this.color, this.text);
}

class HBarChart extends StatelessWidget {
  final List<HBar> bars;
  final double labelWidth;

  const HBarChart({super.key, required this.bars, this.labelWidth = 130});

  @override
  Widget build(BuildContext context) {
    final maxValue = bars.fold<double>(0, (m, b) => max(m, b.value));

    return Column(
      children: [
        for (final b in bars)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: labelWidth,
                  child: Text(b.label, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: maxValue == 0 ? 0 : b.value / maxValue,
                        child: Container(
                          height: 22,
                          decoration: BoxDecoration(
                            color: b.color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 44,
                  child: Text(
                    b.text,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class VBar {
  final String label;
  final double value;
  final Color color;

  const VBar(this.label, this.value, this.color);
}

class VBarChart extends StatelessWidget {
  final List<VBar> bars;
  final double height;

  const VBarChart({super.key, required this.bars, this.height = 160});

  @override
  Widget build(BuildContext context) {
    final maxValue = bars.fold<double>(0, (m, b) => max(m, b.value));

    return Column(
      children: [
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final b in bars)
                Expanded(
                  child: Tooltip(
                    message: '${b.label}: ${b.value.round()}',
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: maxValue == 0 ? 4.0 : max(4.0, (height - 10) * b.value / maxValue),
                      decoration: BoxDecoration(
                        color: b.color,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final b in bars)
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(b.label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}