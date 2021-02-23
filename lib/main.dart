import 'package:flutter/material.dart';
import 'package:widgets/router/router_parser.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final PageRouterInfoParser _pageRouterInfoParser = PageRouterInfoParser();
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        routeInformationParser: _pageRouterInfoParser, routerDelegate: null);
  }
}
