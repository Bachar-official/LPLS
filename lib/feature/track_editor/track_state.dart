import 'package:lpls/domain/entiy/pad_bank.dart';
import 'package:lpls/domain/enum/pad.dart';

class TrackState {
  final Pad? pad;
  final PadBank? bank;

  const TrackState({required this.bank, required this.pad});

  TrackState.initial() : bank = null, pad = null;

  TrackState copyWith({
    PadBank? bank,
    bool nullableBank = false,
    Pad? pad,
    bool nullablePad = false,
  }) => TrackState(
    bank: nullableBank ? null : bank ?? this.bank,
    pad: nullablePad ? null : pad ?? this.pad,
  );
}
