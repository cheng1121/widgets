import 'dart:ui';

import 'package:flutter/material.dart';

///带有进度条边框的按钮
class CountDownButton extends StatefulWidget {
  const CountDownButton({Key? key, required this.duration}) : super(key: key);
  final Duration duration;

  @override
  _CountDownButtonState createState() => _CountDownButtonState();
}

class _CountDownButtonState extends State<CountDownButton>
    with SingleTickerProviderStateMixin {
  String text = 'send';
  Color borderColor = Colors.grey.shade100;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: widget.duration, vsync: this);
    _animationController.addStatusListener(onStatusListener);
  }

  void onStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _animationController.reset();
      setState(() {
        text = 'send';
      });
    }
  }

  void onTap() {
    setState(() {
      if (text == 'send') {
        text = 'cancel';
        _animationController.forward();
      } else if (text == 'cancel') {
        text = 'send';
        _animationController.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _BorderPainter(
          _animationController,
          borderSide: const BorderSide(width: 3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          child: Text(text),
        ),
      ),
    );
  }
}

class _BorderPainter extends CustomPainter {
  _BorderPainter(this.animation,
      {this.borderRadius = BorderRadius.zero,
      this.borderSide = BorderSide.none})
      : super(repaint: animation);
  final BorderRadius borderRadius;
  final BorderSide borderSide;
  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final RRect rRect = borderRadius.toRRect(rect);

    final Path path = Path()..addRRect(rRect);
    final Paint paint = Paint()
      ..color = borderSide.color
      ..strokeWidth = borderSide.width
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
    if (!animation.isDismissed || !animation.isCompleted) {
      ///绘制进度
      canvas.save();

      final PathMetrics pms = path.computeMetrics();
      paint.color = Colors.red;
      paint.style = PaintingStyle.stroke;

      for (PathMetric pm in pms) {
        final Path p = pm.extractPath(0, pm.length * animation.value);
        canvas.drawPath(p, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _Border extends OutlinedBorder {
  const _Border({
    BorderSide side = BorderSide.none,
    this.borderRadius = BorderRadius.zero,
    required this.animationValue,
  }) : super(side: side);

  final BorderRadiusGeometry borderRadius;
  final double animationValue;

  @override
  _Border copyWith(
      {BorderSide? side, BorderRadius? borderRadius, double? animationValue}) {
    return _Border(
      side: side ?? this.side,
      borderRadius: borderRadius ?? this.borderRadius,
      animationValue: animationValue ?? this.animationValue,
    );
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getPath(rect, textDirection: textDirection, inner: true);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return getPath(rect, textDirection: textDirection);
  }

  Path getPath(Rect rect, {TextDirection? textDirection, bool inner = false}) {
    Path path;
    if (inner) {
      path = Path()
        ..addRRect(borderRadius
            .resolve(textDirection)
            .toRRect(rect)
            .deflate(side.width));
    } else {
      path = Path()
        ..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
    }

    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final double width = side.width;
    if (width == 0.0) {
      canvas.drawRRect(
          borderRadius.resolve(textDirection).toRRect(rect), side.toPaint());
    } else {
      final RRect outer = borderRadius.resolve(textDirection).toRRect(rect);
      final RRect inner = outer.deflate(width);
      final Paint paint = Paint()..color = side.color;
      canvas.drawDRRect(outer, inner, paint);
      final Path path = Path()..addRRect(outer);
      final PathMetrics pathMetrics = path.computeMetrics();
      paint.color = Colors.blue;
      paint.style = PaintingStyle.stroke;
      print('animation value =========$animationValue');
      for (PathMetric pathMetric in pathMetrics) {
        canvas.drawPath(
            pathMetric.extractPath(0, pathMetric.length * animationValue),
            paint);
      }
    }
  }

  @override
  ShapeBorder scale(double t) {
    return _Border(
      side: side.scale(t),
      borderRadius: borderRadius * t,
      animationValue: animationValue,
    );
  }
}
