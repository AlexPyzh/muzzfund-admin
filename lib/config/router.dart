import 'package:go_router/go_router.dart';
import 'package:muzzfund_admin/providers/auth_provider.dart';
import 'package:muzzfund_admin/screens/login_screen.dart';
import 'package:muzzfund_admin/screens/dashboard_shell.dart';
import 'package:muzzfund_admin/screens/statistics_screen.dart';
import 'package:muzzfund_admin/screens/users_screen.dart';
import 'package:muzzfund_admin/screens/tracks_screen.dart';
import 'package:muzzfund_admin/screens/comments_screen.dart';
import 'package:muzzfund_admin/screens/user_detail_screen.dart';
import 'package:muzzfund_admin/screens/track_detail_screen.dart';

class AppRouter {
  static GoRouter router(AdminAuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login';

        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }

        if (isLoggedIn && isLoggingIn) {
          return '/statistics';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => DashboardShell(child: child),
          routes: [
            GoRoute(
              path: '/statistics',
              builder: (context, state) => const StatisticsScreen(),
            ),
            GoRoute(
              path: '/users',
              builder: (context, state) => const UsersScreen(),
            ),
            GoRoute(
              path: '/users/:id',
              builder: (context, state) {
                final userId = int.parse(state.pathParameters['id']!);
                return UserDetailScreen(userId: userId);
              },
            ),
            GoRoute(
              path: '/tracks',
              builder: (context, state) => const TracksScreen(),
            ),
            GoRoute(
              path: '/tracks/:id',
              builder: (context, state) {
                final trackId = int.parse(state.pathParameters['id']!);
                return TrackDetailScreen(trackId: trackId);
              },
            ),
            GoRoute(
              path: '/comments',
              builder: (context, state) => const CommentsScreen(),
            ),
          ],
        ),
      ],
    );
  }
}
