import 'package:flutter/cupertino.dart';

import 'dart:ui' as ui;

class ProfilePainter extends CustomPainter {
  ProfilePainter(this.image, this.width, this.height);
  final ui.Image image;
  final double width;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    //Offset((width * 0.5) - painter.width * 0.5, (height * 0.5) - painter.height * 0.5
    // TODO: implement paint

    canvas.drawImage(
        image,
        Offset((width * 0.5) - image.width * 0.5,
            (height * 0.5) - image.height * 0.5),
        Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    throw UnimplementedError();
  }
}
