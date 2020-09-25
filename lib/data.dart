import 'package:flutter/material.dart';

class Doodle {
  final String name;
  final String time;
  final String content;
  final String stage;
  Color iconBackground;
  Icon icon;
Doodle(
      {this.name,
      this.time,
      this.content,
      this.stage,
      this.icon,
      this.iconBackground});
}
