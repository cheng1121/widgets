import 'dart:ui';

import 'package:flutter/material.dart';

const double defaultMenuItemHeight = 42.0;

class PopupMenuController with ChangeNotifier {
  PopupMenuController(
      {this.menuItemHeight = defaultMenuItemHeight,
      this.selectedIndex = 0,
      bool showMenu = false})
      : _showNotifier = ValueNotifier<bool>(showMenu);

  final double menuItemHeight;
  final ValueNotifier<bool> _showNotifier;
  int selectedIndex = 0;
  OverlayEntry _overlayEntry;

  ///menu所在位置
  // Offset _menuPosition = Offset.zero;
  RelativeRect _menuPosition;

  set _position(RelativeRect position) {
    _menuPosition = position;
    refreshMenu();
  }

  bool get isShow => _showNotifier.value && _overlayEntry != null;

  void showMenu(BuildContext context) {
    Overlay.of(context).insert(_overlayEntry);
    _showNotifier.value = true;
  }

  void hideMenu() {
    _removeMenu();
    _showNotifier.value = false;
  }

  void _removeMenu() {
    _overlayEntry?.remove();
  }

  void refreshMenu() {
    notifyListeners();
  }
}

enum PopupMenuLocation {
  bottom,
  top,
}

typedef OnMenuItemBuilder<T> = Widget Function(
    BuildContext context, T value, int index);
typedef OnMenuBtnChildBuilder<T> = Widget Function(
    BuildContext context, T value, bool showMenu);
typedef OnMenuSeparatedBuilder<T> = Widget Function(
    BuildContext context, T value, int index);

class PopupMenuBtn<T> extends StatefulWidget {
  const PopupMenuBtn({
    Key key,
    @required this.list,
    this.onSelected,
    @required this.builder,
    @required this.childBuilder,
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
  final List<T> list;
  final ValueChanged<int> onSelected;
  final OnMenuItemBuilder<T> builder;
  final OnMenuSeparatedBuilder<T> separatedBuilder;
  final OnMenuBtnChildBuilder<T> childBuilder;
  final PopupMenuController controller;
  final PopupMenuLocation menuLocation;
  final bool enableBlur;
  final CustomClipper<Path> backgroundClipper;
  final Color backgroundColor;
  final BoxConstraints backgroundConstraints;
  final BoxDecoration backgroundDecoration;
  final bool fullScreenWidth;

  @override
  _PopupMenuBtnState<T> createState() => _PopupMenuBtnState<T>();
}

class _PopupMenuBtnState<T> extends State<PopupMenuBtn<T>> {
  List<T> get list => widget.list;
  PopupMenuController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;

    ///判断是否为null，如果是null则给其默认值
    _controller ??= PopupMenuController();
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
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    Offset offset;
    if (widget.menuLocation == PopupMenuLocation.top) {
      offset = Offset.zero;
    } else {
      offset = button.size.bottomLeft(Offset.zero);
    }

    ///确定menu显示的位置
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(offset, ancestor: overlay),
        button.localToGlobal(offset, ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    _controller._position = position;
  }

  ///初始化Overlay
  void _initMenu() {
    _controller._overlayEntry = OverlayEntry(builder: (BuildContext context) {
      return _PopupMenuWidget<T>(
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _controller.showMenu(context);
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: _controller._showNotifier,
        builder: (BuildContext context, bool value, Widget child) {
          return widget.childBuilder(
              context, list[_controller.selectedIndex], value);
        },
      ),
    );
  }
}

class _PopupMenuWidget<T> extends StatefulWidget {
  const _PopupMenuWidget({
    Key key,
    @required this.list,
    @required this.controller,
    @required this.itemBuilder,
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
  final VoidCallback onCancel;
  final OnMenuItemBuilder<T> itemBuilder;
  final OnMenuSeparatedBuilder<T> separatedBuilder;
  final PopupMenuController controller;
  final PopupMenuLocation menuLocation;
  final bool enableBlur;
  final CustomClipper<Path> backgroundClipper;
  final Color backgroundColor;
  final BoxConstraints backgroundConstraints;
  final BoxDecoration backgroundDecoration;
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
      if (widget.separatedBuilder != null) {
        children.add(widget.separatedBuilder(context, value, i));
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
      {Key key, @required this.child, this.checked = false, this.onTap})
      : super(key: key);
  final VoidCallback onTap;
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
