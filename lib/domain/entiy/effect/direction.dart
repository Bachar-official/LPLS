import 'package:flutter/material.dart';

enum Direction {
  left(Icon(Icons.arrow_circle_left_outlined, size: 30.0,), 'Shift left'),
  right(Icon(Icons.arrow_circle_right_outlined, size: 30.0,), 'Shift right'),
  up(Icon(Icons.arrow_circle_up, size: 30.0,), 'Shift up'),
  down(Icon(Icons.arrow_circle_down, size: 30.0,), 'Shift down');

  final Widget icon;
  final String tooltip;
  const Direction(this.icon, this.tooltip);
}
