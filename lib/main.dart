import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:widgets/router/page_router_delegate.dart';
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
  final PageRouterDelegate _delegate = PageRouterDelegate();

  @override
  Widget build(BuildContext context) {
    ///kernel
    return MaterialApp.router(
        routeInformationParser: _pageRouterInfoParser,
        routerDelegate: _delegate);
  }
}

