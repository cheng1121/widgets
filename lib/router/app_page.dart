import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum PageAnimStyle {
  ANDROID,
  IOS,
  NO,
  FADE,
  SLIDE,
  SCALE,
  CUSTOM,
}

///navigator2.0 
///页面
///[T] 是pop的返回值
class AppPage<T> extends Page<T> {
  const AppPage({
     LocalKey? localKey,
    required this.page,
    required String routeName,
    Object? arguments,
    this.fullscreenDialog = false,
    this.maintainState = true,
    this.pageAnimStyle = PageAnimStyle.ANDROID,
    this.title,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.customAnim,
    this.opaque = true,
    this.barrierColor,
    this.barrierDismissible = false,
    this.barrierLabel,
  }) : super(key: localKey, name: routeName, arguments: arguments);

  ///页面
  final Widget page;

  ///IOS页面标题
  final String? title;

  ///是否保留页面状态
  final bool maintainState;

  ///是否为dialog
  final bool fullscreenDialog;
  final PageAnimStyle pageAnimStyle;

  ///[pageAnimStyle]参数不等于[PageAnimStyle.ANDROID]和
  ///[PageAnimStyle.IOS]时有效的参数
  final AnimatedWidget? customAnim;
  final Duration transitionDuration;
  final bool opaque;
  final bool barrierDismissible;
  final Color? barrierColor;
  final String? barrierLabel;

  @override
  Route<T> createRoute(BuildContext context) {
    PageRoute<T> route;
    switch (pageAnimStyle) {
      case PageAnimStyle.ANDROID:
        route = MaterialPageRoute<T>(
            settings: this,
            maintainState: maintainState,
            fullscreenDialog: fullscreenDialog,
            builder: (BuildContext context) {
              return page;
            });
        break;
      case PageAnimStyle.IOS:
        route = CupertinoPageRoute<T>(
            settings: this,
            title: title,
            maintainState: maintainState,
            fullscreenDialog: fullscreenDialog,
            builder: (BuildContext context) {
              return page;
            });
        break;
      case PageAnimStyle.NO:
        route = CustomPageRoute<T>(
          builder: (BuildContext context) {
            return page;
          },
          settings: this,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          opaque: opaque,
          barrierDismissible: barrierDismissible,
          barrierColor: barrierColor,
          barrierLabel: barrierLabel,
        );

        break;
      case PageAnimStyle.FADE:
        route = CustomPageRoute<T>.fade(
          builder: (BuildContext context) {
            return page;
          },
          transitionDuration: transitionDuration,
          settings: this,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          opaque: opaque,
          barrierDismissible: barrierDismissible,
          barrierColor: barrierColor,
          barrierLabel: barrierLabel,
        );
        break;
      case PageAnimStyle.SLIDE:
        route = CustomPageRoute<T>.slide(
          builder: (BuildContext context) {
            return page;
          },
          transitionDuration: transitionDuration,
          settings: this,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          opaque: opaque,
          barrierDismissible: barrierDismissible,
          barrierColor: barrierColor,
          barrierLabel: barrierLabel,
        );
        break;
      case PageAnimStyle.SCALE:
        route = CustomPageRoute<T>.scale(
          builder: (BuildContext context) {
            return page;
          },
          transitionDuration: transitionDuration,
          settings: this,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          opaque: opaque,
          barrierDismissible: barrierDismissible,
          barrierColor: barrierColor,
          barrierLabel: barrierLabel,
        );
        break;
      case PageAnimStyle.CUSTOM:
        assert(customAnim != null);
        route = CustomPageRoute<T>.custom(
          builder: (_) => page,
          customAnim: customAnim,
          transitionDuration: transitionDuration,
          settings: this,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          opaque: opaque,
          barrierDismissible: barrierDismissible,
          barrierColor: barrierColor,
          barrierLabel: barrierLabel,
        );
        break;
    }

    return route;
  }
}

///author: cheng
///date: 2020/8/12
///time: 1:01 PM
///desc: 自定义路由动画
class CustomPageRoute<T> extends PageRoute<T> {
  CustomPageRoute({
    required this.builder,
    this.style = PageAnimStyle.NO,
    this.transitionDuration = const Duration(milliseconds: 0),
    this.opaque = true,
    this.barrierDismissible = false,
    this.barrierColor,
    this.barrierLabel,
    this.maintainState = true,
    this.customAnim,
    RouteSettings? settings,
    bool fullscreenDialog = false,
  }) : super(settings: settings, fullscreenDialog: fullscreenDialog);

  CustomPageRoute.fade({
    required this.builder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.opaque = true,
    this.barrierDismissible = false,
    this.barrierColor,
    this.barrierLabel,
    this.maintainState = true,
    RouteSettings? settings,
    bool fullscreenDialog = false,
  })  : style = PageAnimStyle.FADE,
        customAnim = null,
        super(settings: settings, fullscreenDialog: fullscreenDialog);

  CustomPageRoute.slide({
    required this.builder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.opaque = true,
    this.barrierDismissible = false,
    this.barrierColor,
    this.barrierLabel,
    this.maintainState = true,
    RouteSettings? settings,
    bool fullscreenDialog = false,
  })  : style = PageAnimStyle.SLIDE,
        customAnim = null,
        super(settings: settings, fullscreenDialog: fullscreenDialog);

  CustomPageRoute.scale({
    required this.builder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.opaque = true,
    this.barrierDismissible = false,
    this.barrierColor,
    this.barrierLabel,
    this.maintainState = true,
    RouteSettings? settings,
    bool fullscreenDialog = false,
  })  : style = PageAnimStyle.SCALE,
        customAnim = null,
        super(settings: settings, fullscreenDialog: fullscreenDialog);

  CustomPageRoute.custom({
    required this.builder,
    required this.customAnim,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.opaque = true,
    this.barrierDismissible = false,
    this.barrierColor,
    this.barrierLabel,
    this.maintainState = true,
    RouteSettings? settings,
    bool fullscreenDialog = false,
  })  : style = PageAnimStyle.CUSTOM,
        super(settings: settings, fullscreenDialog: fullscreenDialog);

  final WidgetBuilder builder;
  final PageAnimStyle style;

  final AnimatedWidget? customAnim;

  @override
  final Duration transitionDuration;

  @override
  final bool opaque;

  @override
  final bool barrierDismissible;

  @override
  final Color? barrierColor;

  @override
  final String? barrierLabel;

  @override
  final bool maintainState;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    switch (style) {
      case PageAnimStyle.ANDROID:
      case PageAnimStyle.IOS:
      case PageAnimStyle.NO:
        return child;
      case PageAnimStyle.FADE:
        return _fade(animation, child);
      case PageAnimStyle.SLIDE:
        return _slide(animation, child);
      case PageAnimStyle.SCALE:
        return _scale(animation, child);
      case PageAnimStyle.CUSTOM:
        return customAnim!;
      default:
        return child;
    }
  }

  Widget _scale(Animation<double> animation, Widget child) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.fastOutSlowIn,
      )),
      child: child,
    );
  }

  Widget _slide(Animation<double> animation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: const Offset(0.0, 0.0),
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.fastOutSlowIn,
      )),
      child: child,
    );
  }

  Widget _fade(Animation<double> anim, Widget child) {
    return FadeTransition(
      opacity: anim,
      child: child,
    );
  }
}
