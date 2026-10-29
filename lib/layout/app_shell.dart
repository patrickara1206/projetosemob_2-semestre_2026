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
              ? Drawer(
                  backgroundColor: AppColors.sidebar,
                  child: SafeArea(child: Sidebar()),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!compact) SizedBox(width: 240, child: Sidebar()),
                Expanded(
                  child: Column(
                    children: [
                      TopBar(compact: compact),
                      Expanded(child: child),
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '© ${DateTime.now().year} SEMOB-SCS - Inteligência em Transportes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Suporte Técnico',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 24),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: Text(
              '© ${DateTime.now().year} SEMOB-SCS - Inteligência em Transportes. '
              'Todos os direitos reservados.',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            'Suporte Técnico',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
