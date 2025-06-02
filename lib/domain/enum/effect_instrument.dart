import 'package:flutter/material.dart';

enum EffectInstrument {
  brush('brush.png', 'Brush'),
  pipette('pipette.png', 'Pipette tool'),
  filling('filling.png', 'Filling tool');

  final String assetName;
  final String displayName;

  const EffectInstrument(this.assetName, this.displayName);

  Image toImage() {
    return Image.asset('assets/icons/$assetName', width: 30, height: 30);
  }
}
