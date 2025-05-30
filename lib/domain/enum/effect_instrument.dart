import 'package:flutter/material.dart';

enum EffectInstrument {
  brush('brush.png'),
  pipette('pipette.png'),
  filling('filling.png');

  final String assetName;

  const EffectInstrument(this.assetName);

  Image toImage() {
    return Image.asset('assets/icons/$assetName', width: 30, height: 30);
  }
}
