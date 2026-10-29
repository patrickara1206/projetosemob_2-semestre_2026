import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'sidebar.dart';
import 'top_bar.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final compact = box.maxWidth < 900;

        return Scaffold(
          drawer: compact
              ? const Drawer(
                  backgroundColor: AppColors.sidebar,
                  child: SafeArea(child: Sidebar()),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!compact)
                  const SizedBox(
                    width: 240,
                    child: Sidebar(),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      TopBar(compact: compact),
                      Expanded(
                        child: child,
                      ),
                      _Footer(compact: compact),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Footer extends StatelessWidget {
  final bool compact;
  const _Footer({required this.compact});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '© ${DateTime.now().year} SEMOB-SCS - Inteligência em Transportes.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
            const SizedBox(height: 4),
            const Text(
              'Suporte Técnico',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Text(
              '© ${DateTime.now().year} SEMOB-SCS - Inteligência em Transportes. '
              'Todos os direitos reservados.',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
          const Text(
            'Suporte Técnico',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}