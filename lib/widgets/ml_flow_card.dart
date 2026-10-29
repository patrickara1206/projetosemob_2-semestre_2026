import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Fluxo de dados & inferência. Deve receber altura definida pelo pai.
class MlFlowCard extends StatelessWidget {
  const MlFlowCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final isMobile = box.maxWidth < 500;

        return Container(
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          decoration: cardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'FLUXO DE DADOS & INFERÊNCIA',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.fullscreen,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: math.max(
                          0.0,
                          box.maxWidth - (isMobile ? 28 : 40),
                        ),
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Node(
                                label: 'Dados\nOperação',
                                icon: Icons.storage_outlined,
                                fill: Color(0xFFEEF0FA),
                                border: Theme.of(context).colorScheme.onSurface,
                                iconColor: Theme.of(
                                  context,
                                ).colorScheme.onSurface,
                              ),
                              _Link(),
                              _Node(
                                label: 'Tratamento',
                                icon: Icons.filter_alt_outlined,
                                fill: Color(0xFFEEF0FA),
                                border: Theme.of(context).colorScheme.onSurface,
                                iconColor: Theme.of(
                                  context,
                                ).colorScheme.onSurface,
                              ),
                              _Link(),
                              _Node(
                                label: 'Modelo ML',
                                icon: Icons.psychology_outlined,
                                fill: Theme.of(context).colorScheme.onSurface,
                                border: Theme.of(context).colorScheme.onSurface,
                                iconColor: Colors.white,
                                diamond: true,
                                bold: true,
                              ),
                              _Link(),
                              _Node(
                                label: 'Detecção',
                                icon: Icons.search,
                                fill: AppColors.orangeSoft,
                                border: AppColors.orange,
                                iconColor: AppColors.orange,
                              ),
                              _Link(),
                              _Node(
                                label: 'Score / Painel',
                                icon: Icons.speed,
                                fill: AppColors.primary,
                                border: AppColors.primary,
                                iconColor: Colors.white,
                                bold: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Node extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color fill;
  final Color border;
  final Color iconColor;
  final bool diamond;
  final bool bold;

  const _Node({
    required this.label,
    required this.icon,
    required this.fill,
    required this.border,
    required this.iconColor,
    this.diamond = false,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget shape;
    if (diamond) {
      shape = SizedBox(
        width: 64,
        height: 64,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Icon(icon, color: iconColor, size: 22),
          ],
        ),
      );
    } else {
      shape = Center(
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(color: border, width: 1.5),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      );
    }

    return SizedBox(
      width: 76,
      child: Column(
        children: [
          SizedBox(height: 64, child: shape),
          SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: bold
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 64,
      child: Center(child: Container(height: 1.5, color: AppColors.border)),
    );
  }
}
