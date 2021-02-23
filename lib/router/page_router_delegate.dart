import 'package:flutter/material.dart';

///路由状态管理
class PageRouterDelegate extends RouterDelegate<RouteSettings>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteSettings> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      
    );
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => throw UnimplementedError();

  @override
  Future<void> setNewRoutePath(RouteSettings configuration) {
    throw UnimplementedError();
  }
}
