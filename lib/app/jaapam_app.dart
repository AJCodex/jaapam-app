import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_providers.dart';
import '../features/auth/sign_in_page.dart';
import '../features/onboarding/profile_setup_page.dart';
import '../features/shell/root_shell.dart';
import '../features/target/personal_target_page.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import 'locale_controller.dart';

final _routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _RouterRefresh(ref),
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      if (auth.isLoading) return null;
      final user = auth.valueOrNull;
      final loc = state.matchedLocation;
      final atSignIn = loc == '/sign-in';
      final atOnboarding = loc == '/onboarding';

      if (user == null) {
        return atSignIn ? null : '/sign-in';
      }

      final profileAsync = ref.read(userProfileProvider);
      if (profileAsync.isLoading) return null;
      final profile = profileAsync.valueOrNull;
      final needsOnboarding = profile == null || !profile.isComplete;

      if (needsOnboarding) {
        return atOnboarding ? null : '/onboarding';
      }

      if (atSignIn || atOnboarding) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const RootShell()),
      GoRoute(path: '/target', builder: (_, _) => const PersonalTargetPage()),
      GoRoute(path: '/sign-in', builder: (_, _) => const SignInPage()),
      GoRoute(
        path: '/onboarding',
        builder: (_, _) => const ProfileSetupPage(),
      ),
    ],
  );
});

/// Bridges Riverpod auth/profile streams to GoRouter's refreshListenable.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(authStateProvider, (_, _) => notifyListeners());
    ref.listen(userProfileProvider, (_, _) => notifyListeners());
  }
}

class JaapamApp extends ConsumerWidget {
  const JaapamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final router = ref.watch(_routerProvider);
    return MaterialApp.router(
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
