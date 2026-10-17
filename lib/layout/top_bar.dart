import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/state.dart';
import '../core/theme.dart';

class TopBar extends StatelessWidget {
  final bool compact;

  const TopBar({
    super.key,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final escuro = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 16,
      ),
      decoration: BoxDecoration(
        color: esquema.surface,
        border: Border(
          bottom: BorderSide(
            color: esquema.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          if (compact)
            Builder(
              builder: (ctx) => IconButton(
                tooltip: 'Abrir menu',
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          Text(
            'Dashboard\nOperacional',
            style: TextStyle(
              color: esquema.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: compact ? 14 : 18,
              height: 1.1,
            ),
          ),
          const Spacer(),
          if (!compact) ...[
            const SizedBox(width: 16),
            const _StatusChip(),
            const SizedBox(width: 16),
            Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: esquema.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              fmtDateTime(DateTime.now()),
              style: TextStyle(
                fontSize: 12,
                color: esquema.onSurface,
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              tooltip: 'Atualizar dados',
              icon: const Icon(Icons.refresh),
              color: esquema.onSurface,
              onPressed: () {
                periodoNotifier.atualizar();
              },
            ),
          ],
          IconButton(
            tooltip: escuro
                ? 'Ativar tema claro'
                : 'Ativar tema escuro',
            icon: Icon(
              escuro
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            color: esquema.onSurface,
            onPressed: alternarTema,
          ),
          if (!compact) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 18,
              child: Icon(Icons.person),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip();

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;

    final fundo = escuro
        ? const Color(0xFF15382A)
        : const Color(0xFFE8F5E9);

    final texto = escuro
        ? const Color(0xFF86EFAC)
        : AppColors.green;

    final borda = escuro
        ? const Color(0xFF166534)
        : const Color(0xFFA5D6A7);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borda),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: texto,
          ),
          const SizedBox(width: 6),
          Text(
            'Processamento do\nModelo: OK',
            style: TextStyle(
              fontSize: 10,
              color: texto,
            ),
          ),
        ],
      ),
    );
  }
}