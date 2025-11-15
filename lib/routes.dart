import 'package:flutter/material.dart';

import 'pages/main_menu.dart';
import 'pages/login_page.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/':
      default:
        return MaterialPageRoute(builder: (_) => const MainMenu());
    }
  }
}
