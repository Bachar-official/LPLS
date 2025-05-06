enum Pad {
  a1,
  a2,
  a3,
  a4,
  a5,
  a6,
  a7,
  a8,
  b1,
  b2,
  b3,
  b4,
  b5,
  b6,
  b7,
  b8,
  c1,
  c2,
  c3,
  c4,
  c5,
  c6,
  c7,
  c8,
  d1,
  d2,
  d3,
  d4,
  d5,
  d6,
  d7,
  d8,
  e1,
  e2,
  e3,
  e4,
  e5,
  e6,
  e7,
  e8,
  f1,
  f2,
  f3,
  f4,
  f5,
  f6,
  f7,
  f8,
  g1,
  g2,
  g3,
  g4,
  g5,
  g6,
  g7,
  g8,
  h1,
  h2,
  h3,
  h4,
  h5,
  h6,
  h7,
  h8,
  a,
  b,
  c,
  d,
  e,
  f,
  g,
  h;

  const Pad();

  static List<Pad> get regularPads => Pad.values.where((p) => p.name.length == 2).toList();

  factory Pad.fromString(String val) => Pad.values.firstWhere((pad) => pad.name == val);

  ({int x, int y})? get coordinates {
    final name = this.name;
    if (name.length != 2) return null;
    final rowChar = name[0];
    final colChar = name[1];
    final x = int.tryParse(colChar);
    final y = 'abcdefgh'.indexOf(rowChar);
    if (x == null || y == -1) return null;
    return (x: x - 1, y: y); // x от 0 до 7, y от 0 до 7
  }

  static Pad? fromCoordinates({required int x, required int y}) {
    if (x < 0 || x > 7 || y < 0 || y > 7) return null;
    final rowChar = 'abcdefgh'[y];
    final col = x + 1;
    return Pad.values.firstWhere(
      (p) => p.name == '$rowChar$col',
    );
  }
}