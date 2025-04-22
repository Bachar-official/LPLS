import 'package:lpls/constants/pad_structure.dart';
import 'package:lpls/domain/entiy/pad_bank.dart';

PadStructure fillInitialBanks() {
  final PadStructure result = {};

  for (int page = 0; page < 7; page++) {
    result[page] = {};

    for (int row = 1; row <= 8; row++) {
      for (int col = 1; col <= 8; col++) {
        int padNum = row * 10 + col;
        result[page]![padNum] = PadBank.initial();
      }
    }
  }

  return result;
}