import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:screenshot/screenshot.dart';

class PageCurlWidget extends StatefulWidget {
  final Widget child;

  const PageCurlWidget({Key? key, required this.child}) : super(key: key);

  @override
  _PageCurlWidgetState createState() => _PageCurlWidgetState();
}

class _PageCurlWidgetState extends State<PageCurlWidget> {
  final ScreenshotController _screenshotController = ScreenshotController();
  double _pointer = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _pointer += details.delta.dx;
        });
      },
      child: Screenshot(
        controller: _screenshotController,
        child: ShaderBuilder(
          assetKey: 'assets/inkwell.frag',
          (context, shader, child) {
            return AnimatedSampler(
              (image, size, canvas) {
                shader.setFloat(0, size.width);
                shader.setFloat(1, size.height);
                shader.setFloat(2, _pointer);
                shader.setImageSampler(0, image);
                canvas.drawRect(
                  Offset.zero & size,
                  Paint()..shader = shader,
                );
              },
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}