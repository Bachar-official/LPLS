import 'package:lpls/domain/di/di.dart';
import 'package:lpls/domain/entiy/pad_bank.dart';
import 'package:lpls/domain/enum/pad.dart';

typedef PadStructure = Map<int, Map<Pad, PadBank>>;

abstract class PadStructureSerializer {
  static Map<String, dynamic> serialize(PadStructure structure) {
    return structure.map((rowIndex, padMap) {
      return MapEntry(
        rowIndex.toString(),
        padMap.map((pad, bank) => MapEntry(pad.name, bank.serialize())),
      );
    });
  }

  static Future<PadStructure> deserialize(Map<String, dynamic> map) async {
    final PadStructure result = {};

    for (final entry in map.entries) {
      final rowIndex = int.parse(entry.key);
      final padsData = Map<String, dynamic>.from(entry.value);
      final Map<Pad, PadBank> padMap = {};

      for (final padEntry in padsData.entries) {
        final pad = Pad.fromString(padEntry.key);
        final padBank = await PadBank.deserialize(Map<String, dynamic>.from(padEntry.value), di.audioEngine);
        padMap[pad] = padBank;
      }

      result[rowIndex] = padMap;
    }
    return result;
  }
}