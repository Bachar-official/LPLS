import 'package:lpls/constants/pad_structure.dart';
import 'package:lpls/constants/paging_pads.dart';
import 'package:lpls/domain/entiy/pad_bank.dart';
import 'package:lpls/domain/enum/pad.dart';

import 'package:minisound/engine_flutter.dart' as minisound;

PadStructure fillInitialBanks(minisound.Engine engine) {
  final PadStructure result = {};

  for (int page = 0; page <= 7; page++) {
    result[page] = {};

    for(var pad in Pad.values.toSet().difference(managingPads.toSet())) {
      result[page]?[pad] = PadBank.initial(engine);
    }
  }

  return result;
}

bool isPadStructureEmpty(PadStructure structure) => structure.values.every((grid) => grid.values.every((pad) => pad.isEmpty));