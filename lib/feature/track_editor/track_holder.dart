import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lpls/domain/entiy/pad_bank.dart';
import 'package:lpls/domain/enum/pad.dart';
import 'package:lpls/feature/track_editor/track_state.dart';

class TrackHolder extends StateNotifier<TrackState> {
  TrackHolder(): super(TrackState.initial());

  TrackState get rState => state;

  void setBank(PadBank? bank) {
    state = state.copyWith(bank: bank, nullableBank: bank == null);
  }

  void setPad(Pad? pad) {
    state = state.copyWith(pad: pad, nullablePad: pad == null);
  }

  void clearState() {
    state = TrackState.initial();
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }
}