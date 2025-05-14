import 'package:lpls/domain/entiy/pad_bank.dart';

class TrackState {
  final PadBank? bank;

  const TrackState({required this.bank});

  TrackState.initial(): bank = null;

  TrackState copyWith({PadBank? bank, bool nullableBank = false}) => TrackState(bank: nullableBank ? null : bank ?? this.bank);
}