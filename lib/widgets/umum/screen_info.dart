import 'package:flutter/material.dart';

class ScreenInfo extends StatelessWidget {
  const ScreenInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final orientation = MediaQuery.orientationOf(context);
    final padding = MediaQuery.paddingOf(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          'Ukuran       : ${size.width.toStringAsFixed(0)} × ${size.height.toStringAsFixed(0)} dp\n'
          'Orientasi    : ${orientation.name}\n'
          'Padding atas : ${padding.top.toStringAsFixed(0)} | bawah: ${padding.bottom.toStringAsFixed(0)}\n'
          'Pixel ratio  : $pixelRatio\n'
          'Text scale   : $textScale',
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
    );
  }
}
