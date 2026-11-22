import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:qr/qr.dart';

import '../../../helpers/frame.dart';

const String uri =
    'otpauth://totp/Monthra:ana%40example.com?algorithm=SHA1&digits=6'
    '&issuer=Monthra&period=30&secret=JBSWY3DPEHPK3PXPJBSWY3DPEHPK3PXP';

void main() {
  final modules =
      QrImage(QrCode(payload: QrPayload.fromString(uri))).moduleCount +
      2 * QrCodeView.quietZone;

  testWidgets('is an image with its label', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpFrame(
      const Center(
        child: QrCodeView(data: uri, semanticLabel: 'Código QR'),
      ),
    );
    expect(
      tester.getSemantics(find.byType(QrCodeView)),
      isSemantics(label: 'Código QR', isImage: true),
    );
    semantics.dispose();
  });

  testWidgets('modules are whole pixels, within the size asked', (
    tester,
  ) async {
    await tester.pumpFrame(
      const Center(
        child: QrCodeView(data: uri, semanticLabel: 'QR'),
      ),
    );
    final side = tester.getSize(find.byType(CustomPaint).last).width;
    final module = side / modules;
    expect(side, lessThanOrEqualTo(240));
    expect(module, module.roundToDouble());
    expect(module, greaterThanOrEqualTo(3));
  });

  for (final brightness in Brightness.values) {
    testWidgets('paints ink on white with a quiet zone, ${brightness.name}', (
      tester,
    ) async {
      final boundary = GlobalKey();
      await tester.pumpFrame(
        Center(
          child: RepaintBoundary(
            key: boundary,
            child: const QrCodeView(data: uri, semanticLabel: 'QR'),
          ),
        ),
        brightness: brightness,
      );
      final render =
          boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final module = render.size.width / modules;
      final bytes = await tester.runAsync(() async {
        final image = await render.toImage();
        final data = await image.toByteData();
        return (data!, image.width);
      });
      final (data, width) = bytes!;
      Color at(double x, double y) {
        final i = (y.toInt() * width + x.toInt()) * 4;
        return Color.fromARGB(
          data.getUint8(i + 3),
          data.getUint8(i),
          data.getUint8(i + 1),
          data.getUint8(i + 2),
        );
      }

      final quiet = module * QrCodeView.quietZone;
      // The middle of the quiet zone, then the finder pattern's corner.
      expect(at(quiet / 2, render.size.height / 2), MonthraPalette.white);
      expect(at(quiet + module / 2, quiet + module / 2), MonthraPalette.ink);
      // The finder's light ring, one module in.
      expect(
        at(quiet + module * 1.5, quiet + module * 1.5),
        MonthraPalette.white,
      );
    });
  }
}
