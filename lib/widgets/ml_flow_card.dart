import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Fluxo de dados & inferência. Deve receber altura definida pelo pai.
class MlFlowCard extends StatelessWidget {
  const MlFlowCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text('FLUXO DE DADOS & INFERÊNCIA',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151))),
              ),
              Icon(Icons.fullscreen, size: 18, color: AppColors.muted),
            ],
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _Node(
                      label: 'Dados\nOperação',
                      icon: Icons.storage_outlined,
                      fill: Color(0xFFEEF0FA),
                      border: AppColors.navy,
                      iconColor: AppColors.navy,
                    ),
                    _Link(),
                    _Node(
                      label: 'Tratamento',
                      icon: Icons.filter_alt_outlined,
                      fill: Color(0xFFEEF0FA),
                      border: AppColors.navy,
                      iconColor: AppColors.navy,
                    ),
                    _Link(),
                    _Node(
                      label: 'Modelo ML',
                      icon: Icons.psychology_outlined,
                      fill: AppColors.navy,
                      border: AppColors.navy,
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
        ],
      ),
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
      width: 80,
      child: Column(
        children: [
          SizedBox(height: 64, child: shape),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                  color: bold ? AppColors.navy : AppColors.muted)),
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
      width: 24,
      height: 64,
      child: Center(
        child: Container(height: 1.5, color: AppColors.border),
      ),
    );
  }
}