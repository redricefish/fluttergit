import 'package:flutter/material.dart';

class RoadWidget extends StatelessWidget {
  final List<Color> colors;
  final ScrollController controller;

  const RoadWidget({
    super.key,
    required this.colors,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 4, // Each road takes 1/4th of the screen width
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
        controller: controller,
        itemBuilder: (context, index) {
          return Container(
            height: 50, // Height of each stripe
            color: colors[index % colors.length],
          );
        },
      ),
    );
  }
}
