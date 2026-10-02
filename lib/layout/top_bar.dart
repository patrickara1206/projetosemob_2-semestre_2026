import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/formatters.dart';
import '../core/state.dart';
import '../core/theme.dart';

class TopBar extends StatelessWidget {
  final bool compact;
  const TopBar({super.key, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (compact)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          const Text(
            'Dashboard\nOperacional',
            style: TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                height: 1.1),
          ),
          const Spacer(),
          const _PeriodTabs(),
          if (!compact) ...[
            const SizedBox(width: 16),
            const _StatusChip(),
            const SizedBox(width: 16),
            const Icon(Icons.calendar_today_outlined, size: 20),
            const SizedBox(width: 8),
            Text(fmtDateTime(DateTime.now()),
                style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 16),
            IconButton(icon: const Icon(Icons.refresh), onPressed: () {
              // Força recarregar: reemite o período atual
              periodoNotifier.notifyListeners();
            }),
            IconButton(
                icon: const Icon(Icons.notifications_none), onPressed: () {}),
            IconButton(
                icon: const Icon(Icons.settings_outlined), onPressed: () {}),
            const SizedBox(width: 8),
            const CircleAvatar(radius: 18, child: Icon(Icons.person)),
          ],
        ],
      ),
    );
  }
}

class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Periodo>(
      valueListenable: periodoNotifier,
      builder: (context, atual, _) {
        return Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final p in Periodo.values)
                  InkWell(
                    onTap: () => periodoNotifier.value = p,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: p == atual
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        p.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              p == atual ? FontWeight.bold : FontWeight.w400,
                          color: p == atual ? AppColors.primary : Colors.black87,
                        ),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip();

  @override
  Widget build(BuildContext context) {
    // TODO: ligar ao statusModelo vindo do backend
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: AppColors.green),
          SizedBox(width: 6),
          Text('Processamento do\nModelo: OK',
              style: TextStyle(fontSize: 10, color: AppColors.green)),
        ],
      ),
    );
  }
}