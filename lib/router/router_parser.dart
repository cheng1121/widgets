import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///系统路由信息解析
class PageRouterInfoParser extends RouteInformationParser<RouteSettings> {
  @override
  Future<RouteSettings> parseRouteInformation(
      RouteInformation routeInformation) {
    final String? location = routeInformation.location;
    final Uri? uri;
    String name;
    final RouteSettings routeSettings;
    if (location != null) {
      name = location;
      uri = Uri.tryParse(location);
      print('page router info parser =======$uri');
      if (uri != null && uri.queryParameters.isNotEmpty) {
        name = location.substring(0, routeInformation.location?.indexOf('?'));
      }
      routeSettings = RouteSettings(
        name: name,
        arguments: uri?.queryParameters,
      );
    } else {
      routeSettings = const RouteSettings();
    }

    return SynchronousFuture<RouteSettings>(
      routeSettings,
    );
  }

  @override
  RouteInformation? restoreRouteInformation(RouteSettings configuration) {
    return super.restoreRouteInformation(configuration);
  }
}
