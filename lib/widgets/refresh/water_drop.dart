import 'package:flutter/material.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';

///刷新的动画效果
class WaterDropRefreshHeader extends StatelessWidget {
  ///构造
  const WaterDropRefreshHeader({
    Key? key,
    this.info,
    this.isSliver = true,
    this.maxDragExtend = 80.0,
    this.startOpacityExtend = 20.0,
  }) : super(key: key);

  ///拖动状态信息
  final PullToRefreshScrollNotificationInfo? info;

  /// isSliver
  final bool isSliver;

  ///最大下滑距离
  final double maxDragExtend;

  ///滑动指定距离后显示水滴
  final double startOpacityExtend;

  @override
  Widget build(BuildContext context) {
    final double offset = info?.dragOffset ?? 0.0;
    Widget child;
    if (info?.mode == RefreshIndicatorMode.drag ||
        info?.mode == RefreshIndicatorMode.armed ||
        info?.mode == RefreshIndicatorMode.snap) {
      child = WaterDrop(
        offset: offset,
        mode: info?.mode ?? RefreshIndicatorMode.done,
      );
      child = Opacity(
        opacity: offset >= startOpacityExtend
            ? ((offset - startOpacityExtend) /
                (maxDragExtend - startOpacityExtend))
            : 0.0,
        child: child,
      );
    } else if (info?.mode == RefreshIndicatorMode.refresh) {
      child = CupertinoActivityIndicator(
        animating: info?.mode == RefreshIndicatorMode.refresh,
      );
    } else {
      child = Container();
    }

    if (isSliver) {
      child = SliverToBoxAdapter(
        child: Container(
          height: offset,
          child: child,
        ),
      );
    } else {
      child = Container(
        height: offset,
        // padding: EdgeInsets.all(10.0),
        child: child,
      );
    }
    return child;
  }
}

///水滴
class WaterDrop extends StatefulWidget {
  ///常量构造
  const WaterDrop({
    Key? key,
    required this.offset,
    required this.mode,
    this.showTailAfterDistance = 44.0,
  }) : super(key: key);

  ///偏移量
  final double offset;

  ///刷新状态
  final RefreshIndicatorMode mode;

  ///指定距离后显示尾巴
  final double showTailAfterDistance;

  @override
  _WaterDropState createState() => _WaterDropState();
}

class _WaterDropState extends State<WaterDrop> with TickerProviderStateMixin {
  AnimationController? _controller;
  late AnimationController _dismissCtl;

  double get offset => widget.offset;

  @override
  void initState() {
    super.initState();
    _dismissCtl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400), value: 1.0);
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.0,
      upperBound: 50.0,
      duration: const Duration(milliseconds: 400),
    );
    _controller?.animateTo(0.0);
  }

  @override
  void didUpdateWidget(covariant WaterDrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    final double realOffset = offset - widget.showTailAfterDistance;
    if (_controller != null && !_controller!.isAnimating) {
      _controller?.value = realOffset;
      print('animation controller  value = ${_controller?.value}');
      if (widget.mode == RefreshIndicatorMode.snap) {
        _dismissCtl.animateTo(0.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = CustomPaint(
      child: Container(
        height: 60.0,
      ),
      painter: _WaterDropPainter(
        color: Colors.grey,
        listener: _controller!,
      ),
    );

    ///添加水滴上的刷新icon
    final Widget refresh = Container(
      height: 60.0,
      alignment: Scrollable.of(context)!.axisDirection == AxisDirection.up
          ? Alignment.bottomCenter
          : Alignment.topCenter,
      margin: Scrollable.of(context)!.axisDirection == AxisDirection.up
          ? const EdgeInsets.only(bottom: 12.0)
          : const EdgeInsets.only(top: 12.0),
      child: const Icon(
        Icons.sync,
        color: Colors.white,
        size: 18,
      ),
    );
    child = Stack(
      children: <Widget>[child, refresh],
    );

    child = FadeTransition(
      opacity: _dismissCtl,
      child: child,
    );

    return child;
  }

  @override
  void dispose() {
    _dismissCtl.dispose();
    _controller?.dispose();
    super.dispose();
  }
}

class _WaterDropPainter extends CustomPainter {
  _WaterDropPainter({required this.color, required this.listener})
      : super(repaint: listener);

  final Color color;
  final Animation<double> listener;

  double get value => listener.value;
  final Paint painter = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    const double originH = 20.0;
    final double middleW = size.width / 2;

    const double circleSize = 12.0;

    const double scaleRatio = 0.1;

    final double offset = value;

    painter.color = color;
    canvas.drawCircle(Offset(middleW, originH), circleSize, painter);
    final Path path = Path();
    path.moveTo(middleW - circleSize, originH);

    //draw left
    path.cubicTo(
        middleW - circleSize,
        originH,
        middleW - circleSize + value * scaleRatio,
        originH + offset / 5,
        middleW - circleSize + value * scaleRatio * 2,
        originH + offset);
    path.lineTo(
        middleW + circleSize - value * scaleRatio * 2, originH + offset);
    //draw right
    path.cubicTo(
        middleW + circleSize - value * scaleRatio * 2,
        originH + offset,
        middleW + circleSize - value * scaleRatio,
        originH + offset / 5,
        middleW + circleSize,
        originH);
    //draw upper circle
    path.moveTo(middleW - circleSize, originH);
    path.arcToPoint(Offset(middleW + circleSize, originH),
        radius: const Radius.circular(circleSize));

    //draw lower circle
    path.moveTo(
        middleW + circleSize - value * scaleRatio * 2, originH + offset);
    path.arcToPoint(
        Offset(middleW - circleSize + value * scaleRatio * 2, originH + offset),
        radius: Radius.circular(value * scaleRatio));
    path.close();
    canvas.drawPath(path, painter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
