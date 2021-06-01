import 'package:flutter/material.dart';
import 'package:widgets/splash/splash.dart';

GlobalKey<NavigatorState> globalKey = GlobalKey<NavigatorState>();

class AppNavigator extends StatefulWidget {
  @override
  _AppNavigatorState createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalKey,
      home: Splash(),
    );
  }
}

