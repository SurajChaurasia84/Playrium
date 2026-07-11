import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/auth_screen.dart';
import '../services/auth_service.dart';
import '../screens/home_screen.dart';
import '../screens/tasks_screen.dart';
import '../screens/games_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/game_play_screen.dart';
import '../screens/main_layout.dart';
import '../screens/app_info_screen.dart';

// Key for navigator
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _tasksNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'tasks');
final GlobalKey<NavigatorState> _gamesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'games');
final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

// Provider for Router
final routerProvider = Provider<GoRouter>((ref) {
  // We can listen to Firebase Auth changes to trigger router rebuilds/redirects
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/welcome';

      if (!isLoggedIn) {
        return '/welcome';
      }
      if (isLoggedIn && isLoggingIn) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/profile/info',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AppInfoScreen(),
      ),
      
      // Bottom Navigation layout using StatefulShellRoute
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _tasksNavigatorKey,
            routes: [
              GoRoute(
                path: '/tasks',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: TasksScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'quiz',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const QuizScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _gamesNavigatorKey,
            routes: [
              GoRoute(
                path: '/games',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: GamesScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'play/:gameId',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final gameId = state.pathParameters['gameId'] ?? '';
                      return GamePlayScreen(gameId: gameId);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

// Simple Auth state provider for the router redirect
final authStateProvider = StreamProvider<User?>((ref) {
  return AuthService().authStateChanges;
});
