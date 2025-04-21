enum Mode {
  audio(106),
  midi(107);

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
