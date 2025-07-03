
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';



class PageSwipeShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double swipeProgress; // 0.0 to 1.0
  final ui.Image pageImage;
  final Size containerSize;
  final double cornerRadius;

  PageSwipeShaderPainter({
    required this.shader,
    required this.swipeProgress,
    required this.pageImage,
    required this.containerSize,
    this.cornerRadius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

   
    final pointer = containerSize.width * (1.0 - swipeProgress);
    final origin = containerSize.width;


    final container = Rect.fromLTWH(0, 0, containerSize.width, containerSize.height);



    shader.setFloat(0, size.width);           // resolution.x
    shader.setFloat(1, size.height);          // resolution.y
    shader.setFloat(2, pointer);              // pointer position
    shader.setFloat(3, origin);               // origin position
    shader.setFloat(4, container.left);       // container.x (left)
    shader.setFloat(5, container.top);        // container.y (top)
    shader.setFloat(6, container.right);      // container.z (right)
    shader.setFloat(7, container.bottom);     // container.w (bottom)
    shader.setFloat(8, cornerRadius);         // cornerRadius
    
    // Set the page image texture
    shader.setImageSampler(0, pageImage);     // image sampler

    paint.shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant PageSwipeShaderPainter oldDelegate) {
    return oldDelegate.swipeProgress != swipeProgress ||
           oldDelegate.pageImage != pageImage ||
           oldDelegate.containerSize != containerSize ||
           oldDelegate.cornerRadius != cornerRadius;
  }
}