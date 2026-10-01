import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme.dart';
import 'layout/app_shell.dart';
import 'pages/operacao_page.dart';
import 'pages/overview_page.dart';
import 'pages/passageiros_page.dart';
import 'pages/placeholder_page.dart';

void main() => runApp(const SemobApp());

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        _route('/', const OverviewPage()),
        _route('/operacao', const OperacaoPage()),
        _route('/passageiros', const PassageirosPage()),
        _route('/financeiro', const PlaceholderPage(title: 'Financeiro')),
        _route('/machine-learning',
            const PlaceholderPage(title: 'Machine Learning')),
      ],
    ),
  ],
);

GoRoute _route(String path, Widget page) => GoRoute(
      path: path,
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: page),
    );

class SemobApp extends StatelessWidget {
  const SemobApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SEMOB-SCS',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: _router,
    );
  }
}