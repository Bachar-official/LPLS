import 'package:lpls/domain/enum/pad.dart';

List<Pad> buildGridPads() {
    const rows = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    const cols = ['1', '2', '3', '4', '5', '6', '7', '8'];

    return [
      for (final row in rows)
        for (final col in cols)
          Pad.values.firstWhere((p) => p.name == '$row$col')
    ];
  }