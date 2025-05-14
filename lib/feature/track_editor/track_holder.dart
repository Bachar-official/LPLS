import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/entiy/pad_bank.dart';
import 'package:lpls/feature/track_editor/track_state.dart';

class TrackHolder extends StateNotifier<TrackState> {
  TrackHolder(): super(TrackState.initial());

  void setBank(PadBank? bank) {
    state = state.copyWith(bank: bank, nullableBank: bank == null);
  }
}