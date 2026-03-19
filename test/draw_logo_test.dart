import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generate app icon', () async {
    const double size = 1024;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // NeoColors values
    const primary = Color(0xFFFFF500); // Yellow
    const background = Color(0xFFF2F0E9); // Beige
    const ink = Color(0xFF000000); // Black

    // 1. Draw Background
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, size, size),
      Paint()..color = background,
    );

    // 2. Draw Shadow (offset + 32px down and right)
    final shadowPaint = Paint()..color = ink;
    const boxSize = 640.0;
    const offset = 40.0;
    final shadowRect = Rect.fromCenter(
      center: const Offset(size / 2 + offset, size / 2 + offset),
      width: boxSize,
      height: boxSize,
    );
    canvas.drawRect(shadowRect, shadowPaint);

    // 3. Draw Yellow Box
    final boxPaint = Paint()..color = primary;
    final boxRect = Rect.fromCenter(
      center: const Offset(size / 2 - offset / 2, size / 2 - offset / 2),
      width: boxSize,
      height: boxSize,
    );
    canvas.drawRect(boxRect, boxPaint);

    // 4. Draw Black Border
    final borderPaint = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32.0; // Thick border
    canvas.drawRect(boxRect, borderPaint);

    // 5. Draw Dollar Sign ($)
    const textStyle = TextStyle(
      color: ink,
      fontSize: 400.0,
      fontWeight: FontWeight.w900,
      fontFamily: 'Roboto', // Fallback standard font
      height: 1.0,
    );
    final textSpan = TextSpan(text: '\$', style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(minWidth: boxSize, maxWidth: boxSize);

    // Center the text inside the box
    final textOffset = Offset(
      boxRect.left + (boxSize - textPainter.width) / 2,
      boxRect.top + (boxSize - textPainter.height) / 2,
    );
    textPainter.paint(canvas, textOffset);

    // Finalize image
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    // Ensure assets directory exists
    final dir = Directory('assets');
    if (!await dir.exists()) {
      await dir.create();
    }

    final file = File('assets/app_icon.png');
    await file.writeAsBytes(buffer);
    print('✅ App icon successfully written to assets/app_icon.png');
  });
}
