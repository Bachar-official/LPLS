enum Mode {
  audio(0),
  midi(1);

  final int value;
  const Mode(this.value);

  factory Mode.fromCoords(int coords) {
    if (coords == 109) {
      return Mode.audio;
    } else if (coords == 110) {
      return Mode.midi;
    } else {
      throw Exception('Unknown mode');
    }
  }
}
