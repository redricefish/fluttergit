import 'package:flutter/material.dart';
// import 'package:color_switch_game/game_colors.dart'; // Not needed if color is passed

class PlayerBallWidget extends StatelessWidget {
  final Color color;
  final double size;

  const PlayerBallWidget({
    super.key,
    required this.color,
    this.size = 50.0,
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
