import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/auth_state.dart';
import 'core/theme.dart';

import 'layout/app_shell.dart';

import 'pages/login_page.dart';
import 'pages/machine_learning_page.dart';
import 'pages/operacao_page.dart';
import 'pages/overview_page.dart';
import 'pages/passageiros_page.dart';
import 'pages/placeholder_page.dart';
import 'pages/importacao_page.dart';


void main() {
  runApp(
    const SemobApp(),
  );
}


final _router = GoRouter(
  initialLocation: '/login',

  refreshListenable:
      authNotifier,

  redirect: (
    context,
    state,
  ) {
    final logado =
        authNotifier.value;

    final naTelaLogin =
        state.matchedLocation
            == '/login';

    if (
      !logado
      && !naTelaLogin
    ) {
      return '/login';
    }

    if (
      logado
      && naTelaLogin
    ) {
      return '/';
    }

    return null;
  },

  routes: [
    GoRoute(
      path: '/login',
      builder: (
        context,
        state,
      ) {
        return const LoginPage();
      },
    ),

    ShellRoute(
      builder: (
        context,
        state,
        child,
      ) {
        return AppShell(
          child: child,
        );
      },

      routes: [
        _route(
          '/',
          const OverviewPage(),
        ),

        _route(
          '/operacao',
          const OperacaoPage(),
        ),

        _route(
          '/passageiros',
          const PassageirosPage(),
        ),

        _route(
          '/financeiro',
          const PlaceholderPage(
            title: 'Financeiro',
          ),
        ),

        _route(
          '/machine-learning',
          const MachineLearningPage(),
        ),

        _route(
          '/importacao',
          const ImportacaoPage(),
        ),
      ],
    ),
  ],
);


GoRoute _route(
  String path,
  Widget page,
) {
  return GoRoute(
    path: path,

    pageBuilder: (
      context,
      state,
    ) {
      return NoTransitionPage(
        key: state.pageKey,
        child: page,
      );
    },
  );
}


class SemobApp
    extends StatelessWidget {
  const SemobApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp.router(
      title: 'SEMOB-SCS',

      debugShowCheckedModeBanner:
          false,

      theme: buildTheme(),

      routerConfig:
          _router,
    );
  }
}