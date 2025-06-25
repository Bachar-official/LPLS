import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lpls/utils/file_utils.dart';

class SampleWidget extends StatelessWidget {
  final File file;
  final int index;
  final void Function(int, bool) onRemove;
  final bool? isMidi;
  const SampleWidget({
    super.key,
    required this.file,
    required this.index,
    required this.onRemove,
    this.isMidi,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: ColoredBox(
        color: isMidi ?? false ? Colors.green : Colors.red,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => onRemove(index, isMidi ?? false),
            ),
            const Spacer(flex: 2),
            Transform.rotate(
              angle: -pi / 2,
              child: Text(
                overflow: TextOverflow.visible,
                softWrap: false,
                maxLines: 1,
                FileUtils.getBaseName(file.path),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
