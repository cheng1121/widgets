import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widgets/splash/splash.dart';

import 'app_page.dart';

///路由状态管理
class PageRouterDelegate extends RouterDelegate<RouteSettings>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteSettings> {
  final GlobalKey<NavigatorState> _globalKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    print('================router delegate  build');
    return Navigator(
      key: navigatorKey,
      pages: <Page<void>>[
        AppPage<void>(
            page: Splash(),
            routeName: '/main'),
      ],
      onPopPage: (Route<dynamic> route, dynamic result) {
        return true;
      },
    );
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _globalKey;

  @override
  Future<void> setNewRoutePath(RouteSettings configuration) {
    print(configuration.name);
    return Future<void>.value();
  }
}
