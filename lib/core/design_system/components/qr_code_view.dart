import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/tokens/palette.dart';
import 'package:monthra/core/design_system/tokens/radii.dart';
import 'package:qr/qr.dart';

/// [data] as a QR code (an `otpauth://` URI, say), read out as
/// [semanticLabel]. Give the same data as text beside it: a QR code is no
/// alternative for someone who cannot see it.
///
/// The one component that reads the palette: scanners expect dark modules
/// on a light ground, so it paints ink on white in both themes, with the
/// standard quiet zone of four modules. Modules snap to whole logical
/// pixels (no blurry seams), so the code comes out at most [size] wide.
class QrCodeView extends StatefulWidget {
  const new({
    required this.data,
    required this.semanticLabel,
    this.size = 240,
    super.key,
  });

  final String data;
  final String semanticLabel;
  final double size;

  /// The quiet zone around the code, in modules.
  static const int quietZone = 4;

  @override
  State<QrCodeView> createState() => _QrCodeViewState();
}

class _QrCodeViewState extends State<QrCodeView> {
  late QrImage _image = _encode();

  // The default error correction (medium) survives a smudged screen.
  QrImage _encode() =>
      QrImage(QrCode(payload: QrPayload.fromString(widget.data)));

  @override
  void didUpdateWidget(QrCodeView old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data) _image = _encode();
  }

  @override
  Widget build(BuildContext context) {
    final modules = _image.moduleCount + 2 * QrCodeView.quietZone;
    final module = math.max(1, (widget.size / modules).floor()).toDouble();
    return Semantics(
      image: true,
      label: widget.semanticLabel,
      child: ClipRRect(
        borderRadius: MonthraRadii.smAll,
        child: CustomPaint(
          size: Size.square(module * modules),
          painter: _QrPainter(_image, module),
        ),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  new(this.image, this.module);

  final QrImage image;
  final double module;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = MonthraPalette.white);
    final dark = Path();
    const offset = QrCodeView.quietZone;
    for (var row = 0; row < image.moduleCount; row++) {
      for (var col = 0; col < image.moduleCount; col++) {
        if (image.isDark(row, col)) {
          dark.addRect(
            Rect.fromLTWH(
              (col + offset) * module,
              (row + offset) * module,
              module,
              module,
            ),
          );
        }
      }
    }
    canvas.drawPath(
      dark,
      Paint()
        ..color = MonthraPalette.ink
        ..isAntiAlias = false,
    );
  }

  @override
  bool shouldRepaint(_QrPainter old) =>
      old.image != image || old.module != module;
}
