import 'package:final_project/SplashScreen.dart';
import 'package:final_project/app_routes.dart';
import 'package:final_project/feeds.dart';
import 'package:final_project/profile.dart';
import 'package:final_project/studentform.dart';
import 'package:flutter/material.dart';

import 'login.dart';

void main() => runApp(const App());

String InitialRoute() => AppRoutes.splash;
Route? getRoute(RouteSettings settings) {
  switch (settings.name) {
    // initial route
    case AppRoutes.splash:
      return buildRoute(const SplashScreen(), settings: settings);
    case AppRoutes.login:
      return buildRoute(const Login(), settings: settings);
    case AppRoutes.profile:
      return buildRoute(Profile(), settings: settings);
    case AppRoutes.signup:
      return buildRoute(const StudentForm(), settings: settings);
    case AppRoutes.feed:
      return buildRoute(const Feed(), settings: settings);
    default:
      return null;
  }
}

MaterialPageRoute buildRoute(Widget child, {required RouteSettings settings}) =>
    MaterialPageRoute(
      settings: settings,
      builder: (BuildContext context) => child,
    );

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: InitialRoute(),
      onGenerateRoute: (route) => getRoute(route),

      home: SplashScreen(),
      // home: StudentForm(),
    );
  }
}
