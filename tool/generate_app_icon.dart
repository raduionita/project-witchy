// Regenerates assets/images/app_icon_1024.png - gold cat-moon on brand purple.
// Run: dart run tool/generate_app_icon.dart
import 'dart:io';

import 'package:image/image.dart';

const _size = 1024;
const _iconSize = 800;

void main() {
  final canvas = Image(width: _size, height: _size);
  fill(canvas, color: ColorRgba8(0x3B, 0x0A, 0x5E, 0xFF));
  final gold = decodePng(File('assets/images/cat-moon-gold-512.png').readAsBytesSync());
  if (gold == null) {
    stderr.writeln('Could not decode assets/images/cat-moon-gold-512.png');
    exitCode = 1;
    return;
  }
  final icon = copyResize(gold, width: _iconSize, height: _iconSize, interpolation: Interpolation.average);
  compositeImage(canvas, icon, dstX: (_size - _iconSize) ~/ 2, dstY: (_size - _iconSize) ~/ 2);
  File('assets/images/app_icon_1024.png').writeAsBytesSync(encodePng(canvas));
  stdout.writeln('Wrote assets/images/app_icon_1024.png');
}
