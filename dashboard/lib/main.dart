import 'package:dashboard/bloc/auth-bloc.dart';
import 'package:dashboard/bloc/candidats-bloc.dart';
import 'package:dashboard/bloc/menu-bloc.dart';
import 'package:dashboard/bloc/sms-bloc.dart';
import 'package:dashboard/router/app_router.dart';
import 'package:dashboard/utils/coolors-by-dii.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _authBloc = AuthBloc();
  late final _router = createRouter(_authBloc);

  @override
  void initState() {
    super.initState();
    _authBloc.checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authBloc),
        ChangeNotifierProvider(create: (_) => MenuAdminBloc()),
        ChangeNotifierProvider(create: (_) => CandidatsBloc()),
        ChangeNotifierProvider(create: (_) => SmsBloc()),
        // ✅ Aucun provider à ajouter pour HomeConfig et Gallery :
        // ces pages gèrent leur état localement (StatefulWidget)
        // et appellent ApiService() directement
      ],
      child: MaterialApp.router(
        title: 'Admin Yaatal Mbinde',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: vert),
          useMaterial3: true,
          scaffoldBackgroundColor: bgAdmin,
        ),
        routerConfig: _router,
      ),
    );
  }
}
