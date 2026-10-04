import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final String path;
  const _NavItem(this.label, this.icon, this.path);
}

/// Para adicionar uma nova tela ao menu: inclua aqui e crie a rota no main.dart.
const _items = [
  _NavItem('Visão Geral', Icons.dashboard_outlined, '/'),
  _NavItem('Operação', Icons.directions_bus_outlined, '/operacao'),
  _NavItem('Passageiros', Icons.groups_outlined, '/passageiros'),
  _NavItem('Financeiro', Icons.payments_outlined, '/financeiro'),
  _NavItem('Machine Learning', Icons.psychology_outlined, '/machine-learning'),
  _NavItem('Importar dados',Icons.upload_file_outlined,'/importacao',),
];

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final current = GoRouterState.of(context).uri.path;

    return Container(
      color: AppColors.sidebar,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.sidebarLogo,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.directions_bus,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SEMOB-SCS',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text('Gestão de Mobilidade',
                          style: TextStyle(
                              color: Color(0xFFB8C4E0), fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            for (final item in _items)
              _SidebarTile(item: item, selected: item.path == current),
          ],
        ),
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
                Text(item.label,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}