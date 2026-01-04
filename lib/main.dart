import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:muzzfund_admin/providers/auth_provider.dart';
import 'package:muzzfund_admin/providers/users_provider.dart';
import 'package:muzzfund_admin/providers/tracks_provider.dart';
import 'package:muzzfund_admin/providers/statistics_provider.dart';
import 'package:muzzfund_admin/providers/comments_provider.dart';
import 'package:muzzfund_admin/providers/investments_provider.dart';
import 'package:muzzfund_admin/config/router.dart';
import 'package:muzzfund_admin/config/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MuzzFundAdminApp());
}

class MuzzFundAdminApp extends StatelessWidget {
  const MuzzFundAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
        ChangeNotifierProvider(create: (_) => TracksProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
        ChangeNotifierProvider(create: (_) => CommentsProvider()),
        ChangeNotifierProvider(create: (_) => InvestmentsProvider()),
      ],
      child: Builder(
        builder: (context) {
          final authProvider = context.watch<AdminAuthProvider>();
          return MaterialApp.router(
            title: 'MuzzFund Admin',
            debugShowCheckedModeBanner: false,
            theme: AdminTheme.lightTheme,
            darkTheme: AdminTheme.darkTheme,
            themeMode: ThemeMode.dark,
            routerConfig: AppRouter.router(authProvider),
          );
        },
      ),
    );
  }
}
