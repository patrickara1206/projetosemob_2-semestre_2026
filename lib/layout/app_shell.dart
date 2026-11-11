import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'sidebar.dart';
import 'sidebar_waves.dart';
import 'top_bar.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _navigationKey = GlobalKey<ScaffoldState>();

  void _toggleMenu() {
    final navigation = _navigationKey.currentState;
    if (navigation == null) return;
    if (navigation.isDrawerOpen) {
      navigation.closeDrawer();
    } else {
      navigation.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final compact = box.maxWidth < 900;
        return Material(
          color: AppColors.sidebar,
          child: SafeArea(
            child: Column(
              children: [
                _SiteHeader(onMenu: _toggleMenu, narrow: box.maxWidth < 600),
                Expanded(
                  child: Scaffold(
                    key: _navigationKey,
                    drawerEnableOpenDragGesture: false,
                    drawer: const Drawer(
                      backgroundColor: AppColors.sidebar,
                      child: Sidebar(),
                    ),
                    body: Column(
                      children: [
                        TopBar(compact: compact),
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Positioned.fill(
                                child: SidebarWaves(
                                  horizontal: true,
                                  lightBackground:
                                      Theme.of(context).brightness ==
                                      Brightness.light,
                                ),
                              ),
                              widget.child,
                            ],
                          ),
                        ),
                        _Footer(compact: compact),
                      ],
                    ),
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

class _SiteHeader extends StatelessWidget {
  final VoidCallback onMenu;
  final bool narrow;
  const _SiteHeader({required this.onMenu, required this.narrow});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: AppColors.sidebar,
      child: Stack(
        children: [
          Positioned.fill(
            left: narrow ? 190 : 260,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.transparent, Colors.white],
                stops: [0, 0.18],
              ).createShader(bounds),
              child: const SidebarWaves(horizontal: true),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: narrow ? 12 : 24),
            child: Row(
              children: [
                RepaintBoundary(
                  child: Image.asset(
                    'assets/images/brasao_sao_caetano.png',
                    width: narrow ? 40 : 48,
                    height: 48,
                    fit: BoxFit.contain,
                    semanticLabel: 'Brasão de São Caetano do Sul',
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SEMOB-SCS',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: narrow ? 14 : 18,
                        ),
                      ),
                      if (!narrow)
                        const Text(
                          'Gestão de Mobilidade',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFFB8C4E0),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onMenu,
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  icon: const Icon(Icons.menu),
                  label: const Text('MENU'),
                ),
              ],
            ),
          ),
        ],
      ),
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
