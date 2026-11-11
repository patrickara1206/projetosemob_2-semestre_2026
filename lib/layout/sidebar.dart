import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import 'sidebar_waves.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final String path;
  const _NavItem(this.label, this.icon, this.path);
}

const _items = [
  _NavItem('Visão Geral', Icons.dashboard_outlined, '/'),
  _NavItem('Operação', Icons.directions_bus_outlined, '/operacao'),
  _NavItem('Passageiros', Icons.groups_outlined, '/passageiros'),
  _NavItem('Financeiro', Icons.payments_outlined, '/financeiro'),
  _NavItem('Importar dados', Icons.upload_file_outlined, '/importacao'),
];

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final current = GoRouterState.of(context).uri.path;

    return Container(
      color: AppColors.sidebar,
      child: Stack(
        children: [
          const Positioned.fill(child: SidebarWaves()),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  for (final item in _items)
                    _SidebarTile(item: item, selected: item.path == current),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  const _SidebarTile({required this.item, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Scaffold.maybeOf(context)?.closeDrawer();
            context.go(item.path);
          },
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(item.icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
