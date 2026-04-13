import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/auth_notifier.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: EduAccessApp()));
}

class EduAccessApp extends ConsumerWidget {
  const EduAccessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kick off the auth check on first build
    ref.watch(authNotifierProvider);

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'EduAccess',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
