import 'package:lpls/domain/entiy/pad_bank.dart';
import 'package:lpls/domain/enum/pad.dart';

class TrackState {
  final Pad? pad;
  final PadBank? bank;
  final bool isLoading;

  const TrackState({required this.bank, required this.pad, required this.isLoading});

  TrackState.initial() : bank = null, pad = null, isLoading = false;

  TrackState copyWith({
    PadBank? bank,
    bool nullableBank = false,
    Pad? pad,
    bool nullablePad = false,
    bool? isLoading,
  }) => TrackState(
    bank: nullableBank ? null : bank ?? this.bank,
    pad: nullablePad ? null : pad ?? this.pad,
    isLoading: isLoading ?? this.isLoading,
  );
}
