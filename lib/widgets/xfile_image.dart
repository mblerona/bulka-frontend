import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// An [ImageProvider] for a locally-picked image (an `image_picker`
/// `XFile`, or a `File` built from one) that works on every platform —
/// `FileImage`/`Image.file` both hard-fail on Flutter Web (the browser has
/// no real filesystem access), but on web the picked file's `.path` is
/// actually a `blob:` URL the browser can fetch directly, so
/// [NetworkImage] is the correct provider there instead.
ImageProvider xfileImageProvider(String path) {
  return kIsWeb ? NetworkImage(path) : FileImage(File(path)) as ImageProvider;
}

/// [Image] widget counterpart to [xfileImageProvider], for call sites that
/// render with `Image.file(...)` directly rather than a `DecorationImage`.
class XFileImage extends StatelessWidget {
  const XFileImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit,
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(path, width: width, height: height, fit: fit);
    }
    return Image.file(File(path), width: width, height: height, fit: fit);
  }
}
