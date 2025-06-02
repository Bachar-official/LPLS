import 'dart:convert';
import 'dart:io';

import 'package:lpls/domain/entiy/effect/direction.dart';
import 'package:lpls/domain/entiy/effect/mk1_effect_serializer.dart';
import 'package:lpls/domain/entiy/effect/mk2_effect_serializer.dart';
import 'package:lpls/domain/enum/color_mk1.dart';
import 'package:lpls/domain/enum/color_mk2.dart';
import 'package:lpls/domain/enum/lp_color.dart';
import 'package:lpls/domain/enum/pad.dart';
import 'package:lpls/domain/type/frame.dart';
import 'package:lpls/domain/type/full_color.dart';
import 'package:lpls/utils/bpm_utils.dart';

class Effect<T extends LPColor> {
  final int frameTime;
  final int beats;
  final List<Frame<T>> frames;

  const Effect({
    required this.frameTime,
    required this.frames,
    required this.beats,
  });

  factory Effect.initial() => Effect<T>(frameTime: 500, frames: [], beats: 1);

  Effect<T> copyWith({int? frameTime, List<Frame<T>>? frames, int? beats}) =>
      Effect(
        frameTime: frameTime ?? this.frameTime,
        frames: frames ?? this.frames,
        beats: beats ?? this.beats,
      );

  Effect withPadColored(int frameIndex, Pad pad, FullColor<T>? color) {
    if (frameIndex >= frames.length) {
      throw RangeError('Frame $frameIndex does not exist.');
    }

    final newFrames = List<Frame<T>>.from(frames);
    final newFrame = Map<Pad, FullColor<T>>.from(newFrames[frameIndex]);

    if (color != null) {
      newFrame[pad] = color;
    } else {
      newFrame.remove(pad);
    }

    newFrames[frameIndex] = newFrame;

    return copyWith(frames: newFrames);
  }

  Effect<T> withNewFrame() {
    final newFrames = List<Frame<T>>.from(frames);
    if (frames.isEmpty) {
      newFrames.add({});
    } else {
      newFrames.add(Map.from(frames.last));
    }
    return copyWith(frames: newFrames);
  }

  Effect<T> withoutFrame(int frameIndex) {
    if (frameIndex < frames.length) {
      final newFrames = List<Frame<T>>.from(frames)..removeAt(frameIndex);
      return copyWith(frames: newFrames);
    }
    return this;
  }

  void toFile(String path) async {
    var content = '';
    if (T is ColorMk1) {
      content = jsonEncode(
        Mk1EffectSerializer().toMap(
          this as Effect<ColorMk1>,
          bpm: BpmUtils.millisToBpm(frameTime, beats),
          palette: 'mk1',
        ),
      );
    } else if (T is ColorMk2) {
      content = jsonEncode(
        Mk2EffectSerializer().toMap(
          this as Effect<ColorMk2>,
          bpm: BpmUtils.millisToBpm(frameTime, beats),
          palette: 'mk2',
        ),
      );
    } else {
      throw Exception('Unsupported palette');
    }
    await File(path).writeAsString(content);
  }

  factory Effect.fromFile(File file) {
    final map = jsonDecode(file.readAsStringSync());
    var palette = map['palette'];
    if (palette == null) {
      throw Exception('Unsupported effect file');
    }
    if (palette == 'mk1') {
      return Mk1EffectSerializer().fromMap(map) as Effect<T>;
    } else if (palette == 'mk2') {
      return Mk2EffectSerializer().fromMap(map) as Effect<T>;
    } else {
      throw Exception('Unsupported palette');
    }
  }

  Effect withBPM(int bpm) {
    return copyWith(frameTime: BpmUtils.bpmToMillis(bpm, beats));
  }

  Effect<T> withBeats(int newBeats, {required int bpm}) {
    return copyWith(
      beats: newBeats,
      frameTime: BpmUtils.bpmToMillis(bpm, newBeats),
    );
  }

  Effect<T> shift(Direction direction) {
    if (frames.isEmpty) return this;

    final shiftedFrames =
        frames.map((frame) {
          final shiftedFrame = <Pad, FullColor<T>>{};

          for (final entry in frame.entries) {
            final newPad = _getShiftedPad(entry.key, direction);
            if (newPad != null) {
              shiftedFrame[newPad] = entry.value;
            }
          }

          return shiftedFrame;
        }).toList();

    return copyWith(frames: shiftedFrames);
  }

  Pad? _getShiftedPad(Pad pad, Direction direction) {
    final coords = pad.coordinates;
    if (coords == null) return null;

    int newX = coords.x;
    int newY = coords.y;

    switch (direction) {
      case Direction.left:
        newX--;
        break;
      case Direction.right:
        newX++;
        break;
      case Direction.up:
        newY--;
        break;
      case Direction.down:
        newY++;
        break;
    }

    if (newX >= 0 && newX < 8 && newY >= 0 && newY < 8) {
      return Pad.fromCoordinates(x: newX, y: newY);
    }

    return null;
  }
}
