import 'package:dashbord/bloc/auth-bloc.dart';
import 'package:dashbord/bloc/menu-bloc.dart';
import 'package:dashbord/bloc/sms-bloc.dart';
import 'package:dashbord/screen/admin/pages/admin-screen.dart';
import 'package:dashbord/screen/auth-screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) async {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();

        if (sharedPreferences.getString("token") != "" &&
            sharedPreferences.containsKey("token")) {
          if (sharedPreferences.getString("role") == "admin" &&
              sharedPreferences.containsKey("role")) {
            return "/admin";
          } else if (sharedPreferences.getString("role") == "super" &&
              sharedPreferences.containsKey("role")) {
            return "/super";
          }
        } else {
          return '/';
        }
      },
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/admin',
      redirect: (context, state) async {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();

        if (sharedPreferences.getString("token") != "" &&
            sharedPreferences.containsKey("token")) {
          return "/admin";
        } else {
          return '/';
        }
      },
      builder: (context, state) => const AdministrateurAscreen(),
    ),
  ],
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  setUrlStrategy(PathUrlStrategy());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthBloc()),
        ChangeNotifierProvider(create: (_) => MenuAdminBloc()),
        ChangeNotifierProvider(create: (_) => SmsBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'yaatalmbinde',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
