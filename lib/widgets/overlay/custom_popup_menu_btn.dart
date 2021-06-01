import 'dart:ui';

import 'package:flutter/material.dart';

///默认条目高度
const double defaultMenuItemHeight = 42.0;

///控制器
class PopupMenuController with ChangeNotifier {
  ///初始化条目高度、默认选中的item，是否显示弹窗
  PopupMenuController(
      {this.menuItemHeight = defaultMenuItemHeight,
      this.selectedIndex = 0,
      bool showMenu = false})
      : _showNotifier = ValueNotifier<bool>(showMenu);

  ///条目高度
  final double menuItemHeight;

  ///控制是否显示条目
  final ValueNotifier<bool> _showNotifier;

  ///默认显示的item
  int selectedIndex = 0;

  ///弹窗布局
  late OverlayEntry _overlayEntry;

  ///menu所在位置
  // Offset _menuPosition = Offset.zero;
  late RelativeRect _menuPosition;

  set _position(RelativeRect position) {
    _menuPosition = position;
    refreshMenu();
  }

  ///是否显示
  bool get isShow => _showNotifier.value;

  ///显示menu
  void showMenu(BuildContext context) {
    Overlay.of(context)?.insert(_overlayEntry);
    _showNotifier.value = true;
  }

  ///隐藏menu
  void hideMenu() {
    _removeMenu();
    _showNotifier.value = false;
  }

  ///移除menu
  void _removeMenu() {
    _overlayEntry.remove();
  }

  ///刷新menu内容
  void refreshMenu() {
    notifyListeners();
  }
}

///菜单显示的位置
enum PopupMenuLocation {
  ///按钮下方
  bottom,

  ///按钮上方
  top,
}

///构建菜单条目的回调
typedef OnMenuItemBuilder<T> = Widget Function(
    BuildContext context, T value, int index);

///构建菜单按钮的回调
typedef OnMenuBtnChildBuilder<T> = Widget Function(
    BuildContext context, T value, bool showMenu);

///条目之间的分割线
typedef OnMenuSeparatedBuilder<T> = Widget Function(
    BuildContext context, T value, int index);

///菜单按钮
class PopupMenuBtn<T> extends StatefulWidget {
  ///设置菜单按钮的各种参数
  const PopupMenuBtn({
    Key? key,
    required this.list,
    this.onSelected,
    required this.builder,
    required this.childBuilder,
    this.separatedBuilder,
    this.menuLocation = PopupMenuLocation.bottom,
    this.controller,
    this.enableBlur = true,
    this.backgroundClipper,
    this.backgroundColor = Colors.grey,
    this.backgroundConstraints,
    this.backgroundDecoration,
    this.fullScreenWidth = true,
  }) : super(key: key);

  ///菜单列表数据
  final List<T> list;

  ///选中的条目
  final ValueChanged<int>? onSelected;

  ///条目样式
  final OnMenuItemBuilder<T> builder;

  ///分割线样式
  final OnMenuSeparatedBuilder<T>? separatedBuilder;

  ///按钮样式
  final OnMenuBtnChildBuilder<T> childBuilder;

  ///控制器
  final PopupMenuController? controller;

  ///显示位置
  final PopupMenuLocation menuLocation;

  ///菜单下方/上方空白区域是否有模糊效果
  final bool enableBlur;

  ///不满全屏时菜单的边框样式
  final CustomClipper<Path>? backgroundClipper;

  ///背景颜色
  final Color backgroundColor;

  ///宽高约束
  final BoxConstraints? backgroundConstraints;

  ///设置圆角等样式
  final BoxDecoration? backgroundDecoration;

  ///是否铺满屏幕宽度
  final bool fullScreenWidth;

  @override
  _PopupMenuBtnState<T> createState() => _PopupMenuBtnState<T>();
}

class _PopupMenuBtnState<T> extends State<PopupMenuBtn<T>> {
  List<T> get list => widget.list;
  late PopupMenuController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? PopupMenuController();
    _initMenu();
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      _calculationLocation();
      if (_controller.isShow) {
        _controller.showMenu(context);
      }
    });
  }

  ///重载时执行此方法
  @override
  void reassemble() {
    super.reassemble();
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      _calculationLocation();
    });
  }

  ///计算menu位置
  void _calculationLocation() {
    final RenderObject? buttonRenderObject = context.findRenderObject();

    final RenderObject? overlayRenderObject =
        Overlay.of(context)?.context.findRenderObject();

    Offset offset;
    if (widget.menuLocation == PopupMenuLocation.top) {
      offset = Offset.zero;
    } else if (buttonRenderObject is RenderBox) {
      offset = buttonRenderObject.size.bottomLeft(Offset.zero);
    } else {
      offset = Offset.zero;
    }
    Rect rect;
    Rect container;
    if (buttonRenderObject is RenderBox && overlayRenderObject is RenderBox) {
      rect = Rect.fromPoints(
        buttonRenderObject.localToGlobal(offset, ancestor: overlayRenderObject),
        buttonRenderObject.localToGlobal(offset, ancestor: overlayRenderObject),
      );
      container = Offset.zero & overlayRenderObject.size;
    } else {
      rect = Rect.zero;
      container = Rect.zero;
    }

    ///确定menu显示的位置
    final RelativeRect position = RelativeRect.fromRect(
      rect,
      container,
    );
    _controller._position = position;
  }

  ///初始化Overlay
  void _initMenu() {
    _controller._overlayEntry = OverlayEntry(builder: (BuildContext context) {
      final Widget child = _PopupMenuWidget<T>(
        list: widget.list,
        controller: _controller,
        menuLocation: widget.menuLocation,
        enableBlur: widget.enableBlur,
        itemBuilder: widget.builder,
        separatedBuilder: widget.separatedBuilder,
        backgroundColor: widget.backgroundColor,
        backgroundClipper: widget.backgroundClipper,
        backgroundConstraints: widget.backgroundConstraints,
        backgroundDecoration: widget.backgroundDecoration,
        onCancel: () {
          _controller.hideMenu();
        },
      );

      return child;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child = InkWell(
      onTap: () {
        _controller.showMenu(context);
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: _controller._showNotifier,
        builder: (BuildContext context, bool value, Widget? child) {
          return widget.childBuilder(
              context, list[_controller.selectedIndex], value);
        },
      ),
    );
    child = WillPopScope(
      child: child,
      onWillPop: () async {
        bool canPop = true;
        if (_controller.isShow) {
          _controller.hideMenu();
          canPop = false;
        }
        return canPop;
      },
    );
    return child;
  }
}

class _PopupMenuWidget<T> extends StatefulWidget {
  const _PopupMenuWidget({
    Key? key,
    required this.list,
    required this.controller,
    required this.itemBuilder,
    this.onCancel,
    this.separatedBuilder,
    this.menuLocation = PopupMenuLocation.bottom,
    this.enableBlur = true,
    this.backgroundColor = Colors.grey,
    this.backgroundClipper,
    this.backgroundDecoration,
    this.backgroundConstraints,
    this.fullScreenWidth = true,
  }) : super(key: key);
  final List<T> list;
  final VoidCallback? onCancel;
  final OnMenuItemBuilder<T> itemBuilder;
  final OnMenuSeparatedBuilder<T>? separatedBuilder;
  final PopupMenuController controller;
  final PopupMenuLocation menuLocation;
  final bool enableBlur;
  final CustomClipper<Path>? backgroundClipper;
  final Color backgroundColor;
  final BoxConstraints? backgroundConstraints;
  final BoxDecoration? backgroundDecoration;
  final bool fullScreenWidth;

  @override
  __PopupMenuWidgetState<T> createState() => __PopupMenuWidgetState<T>();
}

class __PopupMenuWidgetState<T> extends State<_PopupMenuWidget<T>> {
  double _opacity = 1.0;

  PopupMenuController get controller => widget.controller;

  List<T> get list => widget.list;

  @override
  void initState() {
    super.initState();
    controller.addListener(_refresh);
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_refresh);
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    Widget child = Container();
    final List<Widget> children = <Widget>[];

    ///添加条目
    for (int i = 0; i < list.length; i++) {
      final T value = list[i];
      final Widget item = SizedBox(
        height: controller.menuItemHeight,
        child: widget.itemBuilder(context, value, i),
      );
      children.add(item);
      final Widget? separated =
          widget.separatedBuilder?.call(context, value, i);
      if (separated != null) {
        children.add(separated);
      }
    }
    child = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );

    child = SingleChildScrollView(
      child: child,
    );

    ///自定义条目区域的背景，边框等等
    child = ClipPath(
      clipper: widget.backgroundClipper,
      child: Container(
        constraints: widget.backgroundConstraints,
        decoration: widget.backgroundDecoration ??
            BoxDecoration(
              color: widget.backgroundColor,
            ),
        child: child,
      ),
    );

    ///确定位置
    final RelativeRect position = controller._menuPosition;

    Widget blur = Container();

    ///模糊效果
    if (widget.enableBlur) {
      blur = Expanded(
        child: IgnorePointer(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ),
      );
    }
    final List<Widget> blurChildren = <Widget>[];
    double left = position.left;
    if (widget.fullScreenWidth) {
      left = 0.0;
    } else {
      left = position.left;
    }

    ///设置显示位置和模糊效果
    if (widget.menuLocation == PopupMenuLocation.bottom) {
      child = Padding(
        padding: EdgeInsets.only(left: left, top: position.top),
        child: child,
      );
      blurChildren.add(child);
      blurChildren.add(blur);
    } else if (widget.menuLocation == PopupMenuLocation.top) {
      child = Padding(
        padding: EdgeInsets.only(left: left, bottom: position.bottom),
        child: child,
      );
      blurChildren.add(blur);
      blurChildren.add(child);
    }

    child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blurChildren,
    );

    ///退出的渐隐动画
    child = AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(
        milliseconds: 200,
      ),
      child: child,
      onEnd: () {
        widget.onCancel?.call();
      },
    );

    child = Stack(
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            setState(() {
              _opacity = 0.0;
            });
          },
          child: Container(
            height: size.height,
            width: size.width,
          ),
        ),
        child,
      ],
    );

    child = Material(
      color: Colors.transparent,
      child: child,
    );
    return child;
  }
}

class CheckedPopupMenuItem<T> extends StatelessWidget {
  const CheckedPopupMenuItem(
      {Key? key, required this.child, this.checked = false, this.onTap})
      : super(key: key);
  final VoidCallback? onTap;
  final bool checked;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget widget = Container();
    widget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Row(
        children: <Widget>[
          Expanded(
            child: child,
          ),
          if (checked)
            const Icon(
              Icons.check,
              color: Colors.blue,
              size: 20,
            ),
        ],
      ),
    );
    widget = GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: widget,
    );
    return widget;
  }
}
