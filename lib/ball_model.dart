import 'package:flutter/material.dart';

class CollectibleBallModel {
  final UniqueKey id; // To uniquely identify balls for removal
  final Color color;
  final int lane; // 0 to 3
  double verticalPosition; // 0.0 (top) to 1.0 (bottom of visible road area)

  CollectibleBallModel({
    required this.color,
    required this.lane,
    this.verticalPosition = 0.0, // Starts at the top
  }) : id = UniqueKey();
}
