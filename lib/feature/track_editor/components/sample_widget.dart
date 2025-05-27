import 'dart:io';

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
    return ColoredBox(
      color: isMidi ?? false ? Colors.green : Colors.red,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => onRemove(index, isMidi ?? false),
          ),
          Text(FileUtils.getBaseName(file.path)),
        ],
      ),
    );
  }
}
