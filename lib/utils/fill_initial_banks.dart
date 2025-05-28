import 'package:lpls/constants/pad_structure.dart';
import 'package:lpls/constants/paging_pads.dart';
import 'package:lpls/domain/entiy/pad_bank.dart';
import 'package:lpls/domain/enum/pad.dart';

PadStructure fillInitialBanks() {
  final PadStructure result = {};

  for (int page = 0; page <= 7; page++) {
    result[page] = {};

    for(var pad in Pad.values.toSet().difference(managingPads.toSet())) {
      result[page]?[pad] = PadBank.initial();
    }
  }

  return result;
}

bool isPadStructureEmpty(PadStructure structure) => structure.values.every((grid) => grid.values.every((pad) => pad.isEmpty));