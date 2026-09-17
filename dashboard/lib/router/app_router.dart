import 'package:dashboard/bloc/auth-bloc.dart';
import 'package:dashboard/screen/admin/pages/admin-screen.dart';
import 'package:dashboard/screen/auth-screen.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/',

    // ← CLÉ DU FIX : GoRouter rebuilde son redirect à chaque notifyListeners()
    refreshListenable: authBloc,

    redirect: (context, state) {
      final isAuth = authBloc.isAuthenticated;
      final onLogin = state.matchedLocation == '/';

      if (isAuth && onLogin) return '/admin'; // connecté → dashboard
      if (!isAuth && !onLogin) return '/'; // déconnecté → login

      return null; // aucun changement
    },

    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminScreen(),
      ),
    ],
  );
}
