import 'package:lpls/domain/entiy/manager_deps.dart';
import 'package:lpls/domain/entiy/pad_bank.dart';
import 'package:lpls/feature/track_editor/track_holder.dart';

class TrackManager {
  final TrackHolder holder;
  final ManagerDeps deps;

  TrackManager({required this.deps, required this.holder});

  void setBank(PadBank? bank) => holder.setBank(bank);
}