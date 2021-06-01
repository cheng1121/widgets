import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:widgets/splash/custom_scroll_view_demo.dart';
import 'package:widgets/widgets/count_down_button.dart';
import 'package:widgets/widgets/overlay/custom_popup_menu_btn.dart';
import 'package:widgets/widgets/refresh/example/example.dart';
import 'package:widgets/widgets/refresh/example/tab_bar_example.dart';

final List<Route<Object?>> routes = <Route<Object?>>[];

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  final List<String> _tabs = <String>[
    '一',
    '二',
    '三',
    '四',
    '五',
    '六',
    '七',
  ];
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: _tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('页面一'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: () {
                final Route<Object?> route =
                    MaterialPageRoute<Object?>(builder: (BuildContext context) {
                  return Splash1();
                });
                routes.add(route);
                Navigator.push<Object?>(context, route);
              },
              child: const Text('跳转到页面二'),
            ),
            OutlinedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute<Object?>(
                      builder: (BuildContext context) {
                    return const CustomScrollViewDemo();
                  }));
                },
                child: const Text('custom scroll view demo')),
            OutlinedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute<Object?>(
                      builder: (BuildContext context) {
                    return LoadMoreExample();
                  }));
                },
                child: const Text('load more demo')),
            OutlinedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute<Object?>(
                      builder: (BuildContext context) {
                    return const TabBarExample();
                  }));
                },
                child: const Text('tab bar load more demo')),
            OutlinedButton(
                onPressed: () {
                  Navigator.maybePop(context);
                },
                child: const Text('maybe pop')),
            const CountDownButton(
              duration: Duration(seconds: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _Demo extends StatefulWidget {
  const _Demo({Key? key, this.index = 0}) : super(key: key);
  final int index;

  @override
  __DemoState createState() => __DemoState();
}

class __DemoState extends State<_Demo> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    print('tab bar view init ${widget.index}');
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: InkWell(
        splashColor: Colors.green,
        focusColor: Colors.blue,
        onTap: () {
          print('========');
        },
        child: Text('view index = ${widget.index}'),
      ),
    );
  }
}

class Splash1 extends StatefulWidget {
  @override
  _Splash1State createState() => _Splash1State();
}

class _Splash1State extends State<Splash1> {
  @override
  Widget build(BuildContext context) {
    final Widget child = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        OutlinedButton(
          onPressed: () {
            final Route<Object?> route =
                MaterialPageRoute<Object?>(builder: (BuildContext context) {
              return Splash2();
            });
            routes.add(route);
            Navigator.push<Object?>(context, route);
          },
          child: const Text('跳转到页面三'),
        ),
        PopupMenuBtn<String>(
            list: <String>['1', '2', '3', '4'],
            builder: (
              BuildContext context,
              String value,
              int index,
            ) {
              return Center(
                child: Text(value),
              );
            },
            childBuilder: (BuildContext context, String value, bool isShow) {
              return Container(
                height: 40,
                alignment: Alignment.center,
                color: Colors.red,
                child: Text(
                  isShow ? '显示' : '隐藏',
                ),
              );
            }),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('页面二'),
      ),
      body: Center(
        child: child,
      ),
    );
  }
}

class Splash2 extends StatefulWidget {
  @override
  _Splash2State createState() => _Splash2State();
}

class _Splash2State extends State<Splash2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('页面三'),
      ),
      body: Center(
        child: OutlinedButton(
          onPressed: () {
            final Route<Object?> route =
                MaterialPageRoute<Object?>(builder: (BuildContext context) {
              return Splash3();
            });
            routes.add(route);
            Navigator.push<Object?>(context, route);
          },
          child: const Text('跳转页面四'),
        ),
      ),
    );
  }
}

class Splash3 extends StatefulWidget {
  @override
  _Splash3State createState() => _Splash3State();
}

class _Splash3State extends State<Splash3> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('页面四'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: () {
                  final Route<Object?> route = MaterialPageRoute<Object?>(
                      builder: (BuildContext context) {
                    return Splash4();
                  });
                  routes.add(route);
                  Navigator.push<Object?>(context, route);
                },
                child: const Text('跳转页面五'),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.maybePop(context);
                },
                child: const Text('may be pop'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Splash4 extends StatefulWidget {
  @override
  _Splash4State createState() => _Splash4State();
}

class _Splash4State extends State<Splash4> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('页面五'),
      ),
      body: Center(
        child: OutlinedButton(
          onPressed: () {
            final Route<Object?> route =
                MaterialPageRoute<Object?>(builder: (BuildContext context) {
              return Splash5();
            });
            routes.add(route);

            Navigator.replaceRouteBelow(context,
                anchorRoute: routes[2], newRoute: route);
          },
          child: const Text('替换页面三为页面六'),
        ),
      ),
    );
  }
}

class Splash5 extends StatefulWidget {
  @override
  _Splash5State createState() => _Splash5State();
}

class _Splash5State extends State<Splash5> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('页面六'),
      ),
      body: const Center(
        child: Text('页面六'),
      ),
    );
  }
}

class TabBarView extends StatefulWidget {
  /// Creates a page view with one child per tab.
  ///
  /// The length of [children] must be the same as the [controller]'s length.
  const TabBarView({
    Key? key,
    required this.children,
    this.controller,
    this.physics,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert(children != null),
        assert(dragStartBehavior != null),
        super(key: key);

  /// This widget's selection and animation state.
  ///
  /// If [TabController] is not provided, then the value of [DefaultTabController.of]
  /// will be used.
  final TabController? controller;

  /// One widget per tab.
  ///
  /// Its length must match the length of the [TabBar.tabs]
  /// list, as well as the [controller]'s [TabController.length].
  final List<Widget> children;

  /// How the page view should respond to user input.
  ///
  /// For example, determines how the page view continues to animate after the
  /// user stops dragging the page view.
  ///
  /// The physics are modified to snap to page boundaries using
  /// [PageScrollPhysics] prior to being used.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics? physics;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  @override
  _TabBarViewState createState() => _TabBarViewState();
}

class _TabBarViewState extends State<TabBarView> {
  TabController? _controller;
  late PageController _pageController;
  late List<Widget> _children;
  late List<Widget> _childrenWithKey;
  int? _currentIndex;
  int _warpUnderwayCount = 0;

  // If the TabBarView is rebuilt with a new tab controller, the caller should
  // dispose the old one. In that case the old controller's animation will be
  // null and should not be accessed.
  bool get _controllerIsValid => _controller?.animation != null;

  void _updateTabController() {
    final TabController? newController =
        widget.controller ?? DefaultTabController.of(context);
    assert(() {
      if (newController == null) {
        throw FlutterError('No TabController for ${widget.runtimeType}.\n'
            'When creating a ${widget.runtimeType}, you must either provide an explicit '
            'TabController using the "controller" property, or you must ensure that there '
            'is a DefaultTabController above the ${widget.runtimeType}.\n'
            'In this case, there was neither an explicit controller nor a default controller.');
      }
      return true;
    }());

    if (newController == _controller) return;

    if (_controllerIsValid)
      _controller!.animation!.removeListener(_handleTabControllerAnimationTick);
    _controller = newController;
    if (_controller != null)
      _controller!.animation!.addListener(_handleTabControllerAnimationTick);
  }

  @override
  void initState() {
    super.initState();
    _updateChildren();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTabController();
    _currentIndex = _controller?.index;
    _pageController = PageController(initialPage: _currentIndex ?? 0);
  }

  @override
  void didUpdateWidget(TabBarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) _updateTabController();
    if (widget.children != oldWidget.children && _warpUnderwayCount == 0)
      _updateChildren();
  }

  @override
  void dispose() {
    if (_controllerIsValid)
      _controller!.animation!.removeListener(_handleTabControllerAnimationTick);
    _controller = null;
    // We don't own the _controller Animation, so it's not disposed here.
    super.dispose();
  }

  void _updateChildren() {
    _children = widget.children;
    _childrenWithKey = KeyedSubtree.ensureUniqueKeysForList(widget.children);
  }

  void _handleTabControllerAnimationTick() {
    if (_warpUnderwayCount > 0 || !_controller!.indexIsChanging)
      return; // This widget is driving the controller's animation.

    if (_controller!.index != _currentIndex) {
      _currentIndex = _controller!.index;
      _warpToCurrentIndex();
    }
  }

  Future<void> _warpToCurrentIndex() async {
    if (!mounted) return Future<void>.value();

    if (_pageController.page == _currentIndex!.toDouble())
      return Future<void>.value();

    final int previousIndex = _controller!.previousIndex;
    if ((_currentIndex! - previousIndex).abs() == 1) {
      _warpUnderwayCount += 1;
      await _pageController.animateToPage(_currentIndex!,
          duration: kTabScrollDuration, curve: Curves.ease);
      _warpUnderwayCount -= 1;
      return Future<void>.value();
    }

    assert((_currentIndex! - previousIndex).abs() > 1);
    final int initialPage = _currentIndex! > previousIndex
        ? _currentIndex! - 1
        : _currentIndex! + 1;
    final List<Widget> originalChildren = _childrenWithKey;
    setState(() {
      _warpUnderwayCount += 1;

      _childrenWithKey = List<Widget>.from(_childrenWithKey, growable: false);
      final Widget temp = _childrenWithKey[initialPage];
      _childrenWithKey[initialPage] = _childrenWithKey[previousIndex];
      _childrenWithKey[previousIndex] = temp;
    });
    _pageController.jumpToPage(_currentIndex!);

    // await _pageController.animateToPage(_currentIndex!,
    //     duration: kTabScrollDuration, curve: Curves.ease);
    if (!mounted) return Future<void>.value();
    setState(() {
      _warpUnderwayCount -= 1;
      if (widget.children != _children) {
        _updateChildren();
      } else {
        _childrenWithKey = originalChildren;
      }
    });
  }

  // Called when the PageView scrolls
  bool _handleScrollNotification(ScrollNotification notification) {
    if (_warpUnderwayCount > 0) return false;

    if (notification.depth != 0) return false;

    _warpUnderwayCount += 1;
    if (notification is ScrollUpdateNotification &&
        !_controller!.indexIsChanging) {
      if ((_pageController.page! - _controller!.index).abs() > 1.0) {
        _controller!.index = _pageController.page!.floor();
        _currentIndex = _controller!.index;
      }
      _controller!.offset =
          (_pageController.page! - _controller!.index).clamp(-1.0, 1.0);
    } else if (notification is ScrollEndNotification) {
      _controller!.index = _pageController.page!.round();
      _currentIndex = _controller!.index;
      if (!_controller!.indexIsChanging)
        _controller!.offset =
            (_pageController.page! - _controller!.index).clamp(-1.0, 1.0);
    }
    _warpUnderwayCount -= 1;

    return false;
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      if (_controller!.length != widget.children.length) {
        throw FlutterError(
            "Controller's length property (${_controller!.length}) does not match the "
            "number of tabs (${widget.children.length}) present in TabBar's tabs property.");
      }
      return true;
    }());
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: PageView(
        dragStartBehavior: widget.dragStartBehavior,
        controller: _pageController,
        physics: widget.physics == null
            ? const PageScrollPhysics().applyTo(const ClampingScrollPhysics())
            : const PageScrollPhysics().applyTo(widget.physics),
        children: _childrenWithKey,
      ),
    );
  }
}
