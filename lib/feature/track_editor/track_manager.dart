import 'package:lpls/domain/di.dart';
import 'package:lpls/domain/entiy/manager_deps.dart';
import 'package:lpls/domain/entiy/pad_bank.dart';
import 'package:lpls/domain/enum/mode.dart';
import 'package:lpls/domain/enum/pad.dart';
import 'package:lpls/feature/home/home_manager.dart';
import 'package:lpls/feature/track_editor/track_holder.dart';
import 'package:lpls/feature/track_editor/track_state.dart';
import 'package:lpls/utils/ui_utils.dart';

class TrackManager {
  final TrackHolder holder;
  final ManagerDeps deps;
  final HomeManager homeManager;
  TrackManager({
    required this.deps,
    required this.holder,
    required this.homeManager,
  });

  TrackState get state => holder.rState;

  void setBank(PadBank? bank) => holder.setBank(bank);
  void setPad(Pad? pad) => holder.setPad(pad);

  void reorderTracks(oldIndex, newIndex) async {
    debug(
      deps,
      'Try to reorder ${di.projectManager.state.mode} track from $oldIndex to $newIndex',
    );
    final pad = state.pad;
    final bank = state.bank;
    if (bank != null && pad != null) {
      final newBank = await bank.reorderFiles(
        oldIndex,
        newIndex,
        isMidi: di.projectManager.state.mode == Mode.midi,
      );
      setBank(newBank);
      di.projectManager.setBank(newBank, pad);
      success(deps, 'Reordered successfully');
    }
  }

  Future<void> removeFile(int index, bool isMidi) async {
    debug(deps, 'Try to remove track number $index from pad ${state.pad}');
    holder.setLoading(true);
    await di.projectManager.removeFileFromBank(
      pad: state.pad!,
      bank: state.bank!,
      index: index,
      isMidi: isMidi,
    );
    holder.setLoading(false);
  }

  void goBack() {
    holder.clearState();
    homeManager.toProjectScreen();
  }
}
