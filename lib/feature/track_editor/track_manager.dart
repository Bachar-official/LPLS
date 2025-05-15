import 'package:lpls/domain/di.dart';
import 'package:lpls/domain/entiy/manager_deps.dart';
import 'package:lpls/domain/entiy/pad_bank.dart';
import 'package:lpls/domain/enum/mode.dart';
import 'package:lpls/feature/track_editor/track_holder.dart';
import 'package:lpls/feature/track_editor/track_state.dart';

class TrackManager {
  final TrackHolder holder;
  final ManagerDeps deps;
  TrackManager({required this.deps, required this.holder});

  TrackState get state => holder.rState;

  void setBank(PadBank? bank) => holder.setBank(bank);

  void reorderTracks(oldIndex, newIndex) {
    
  }
}