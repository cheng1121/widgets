import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///路由信息解析
class PageRouterInfoParser extends RouteInformationParser<RouteSettings> {
  @override
  Future<RouteSettings> parseRouteInformation(
      RouteInformation routeInformation) {
    final Uri uri = Uri.tryParse(routeInformation.location);
    String name = routeInformation.location;
    if (uri.queryParameters.isNotEmpty) {
      name = routeInformation.location
          .substring(0, routeInformation.location.indexOf('?'));
    }
    return SynchronousFuture<RouteSettings>(
      RouteSettings(
        name: name,
        arguments: uri.queryParameters,
      ),
    );
  }

  @override
  RouteInformation restoreRouteInformation(RouteSettings configuration) {
    return super.restoreRouteInformation(configuration);
  }
}
