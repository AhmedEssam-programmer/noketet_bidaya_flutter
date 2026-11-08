import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/word_game_levels.dart';
import '../screens/auth/login_screen.dart';
import '../screens/games/word_game_admin_screen.dart';
import '../screens/games/word_game_play_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/learning/lesson_screen.dart';
import '../screens/learning/level_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/shopping/cart_screen.dart';
import '../screens/shopping/shopping_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/shopping/chat_page.dart';
import '../state/user_controller.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: SplashScreen.routePath,
    routes: [
      GoRoute(
        path: SplashScreen.routePath,
        name: SplashScreen.routeName,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SplashScreen()),
      ),
      GoRoute(
        path: WelcomeScreen.routePath,
        name: WelcomeScreen.routeName,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: WelcomeScreen()),
      ),
      GoRoute(
        path: HomeScreen.routePath,
        name: HomeScreen.routeName,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: HomeScreen()),
      ),
      GoRoute(
        path: LoginScreen.routePath,
        name: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RegisterScreen.routePath,
        name: RegisterScreen.routeName,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: LevelScreen.routePath,
        name: LevelScreen.routeName,
        builder: (context, state) => const LevelScreen(),
      ),
      GoRoute(
        path: LessonScreen.routePath,
        name: LessonScreen.routeName,
        builder: (context, state) {
          final level = state.pathParameters['level'] ?? 'sounds';
          final lessonId = state.pathParameters['lessonId'] ?? '0';
          return LessonScreen(level: level, lessonId: lessonId);
        },
      ),
      GoRoute(
        path: '/games',
        name: 'WordGames',
        redirect: (context, state) {
          final user = ref.read(userControllerProvider);
          final level = firstPlayableWordGameLevel(
            languageCode: user.settings.language.name,
            completedLevelIds: user.progress.wordGameCompleted,
          );
          return WordGamePlayScreen.path(levelId: level.id);
        },
      ),
      GoRoute(
        path: WordGameAdminScreen.routePath,
        name: WordGameAdminScreen.routeName,
        builder: (context, state) => const WordGameAdminScreen(),
      ),
      GoRoute(
        path: WordGamePlayScreen.routePath,
        name: WordGamePlayScreen.routeName,
        builder: (context, state) {
          final levelId = state.pathParameters['levelId'] ?? '';
          return WordGamePlayScreen(levelId: levelId);
        },
      ),
      GoRoute(
        path: ShoppingScreen.routePath,
        name: ShoppingScreen.routeName,
        builder: (context, state) => const ShoppingScreen(),
      ),
      GoRoute(
        path: CartScreen.routePath,
        name: CartScreen.routeName,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: SettingsScreen.routePath,
        name: SettingsScreen.routeName,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: ChatPage.routePath,
        name: ChatPage.routeName,
        builder: (context, state) => const ChatPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text(state.error?.toString() ?? 'Navigation error')),
    ),
  );
});
