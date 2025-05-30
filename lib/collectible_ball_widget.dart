import 'package:flutter/material.dart';

class CollectibleBallWidget extends StatelessWidget {
  final Color color;
  final double size;

  const CollectibleBallWidget({
    super.key,
    required this.color,
    this.size = 30.0, // Default size
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
