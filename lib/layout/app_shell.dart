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

        final content = Column(
          children: [
            TopBar(compact: compact),
            Expanded(child: child),
            const _Footer(),
          ],
        );

        return Scaffold(
          drawer: compact
              ? const Drawer(
                  backgroundColor: AppColors.sidebar,
                  child: Sidebar(),
                )
              : null,
          body: compact
              ? content
              : Row(
                  children: [
                    const SizedBox(width: 220, child: Sidebar()),
                    Expanded(child: content),
                  ],
                ),
        );
      },
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
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
