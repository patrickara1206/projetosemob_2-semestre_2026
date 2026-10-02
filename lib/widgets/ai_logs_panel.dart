import 'package:flutter/material.dart';

import '../models/ml_overview.dart';

class AiLogsPanel extends StatelessWidget {
  final List<LogIa> logs;
  const AiLogsPanel({super.key, required this.logs});

  static const _bg = Color(0xFF0B2557);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text('LOGS DE IA EM TEMPO REAL',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
              Icon(Icons.circle, size: 9, color: Color(0xFF2196F3)),
            ],
          ),
          const SizedBox(height: 16),
          if (logs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Sem logs no momento',
                    style: TextStyle(color: Color(0xFF7F8FA9), fontSize: 12)),
              ),
            )
          else
            for (final l in logs) _LogLine(log: l),
        ],
      ),
    );
  }
}

class _LogLine extends StatelessWidget {
  final LogIa log;
  const _LogLine({required this.log});

  (Color border, Color text) _colors() {
    switch (log.nivel) {
      case 'ok':
        return (const Color(0xFF4CAF50), Colors.white);
      case 'warn':
        return (AppColorsLog.orange, AppColorsLog.orange);
      case 'erro':
        return (AppColorsLog.red, AppColorsLog.red);
      case 'debug':
        return (const Color(0xFF3B4F7A), const Color(0xFF7F8FA9));
      default:
        return (const Color(0xFF3B4F7A), Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (border, text) = _colors();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: border, width: 2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(log.hora,
                style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: Color(0xFF7F8FA9))),
            const SizedBox(height: 2),
            Text(log.mensagem,
                style: TextStyle(
                    fontFamily: 'monospace', fontSize: 11, color: text)),
          ],
        ),
      ),
    );
  }
}

/// Cores de alerta usadas só neste painel (fundo escuro).
class AppColorsLog {
  static const orange = Color(0xFFFFA726);
  static const red = Color(0xFFEF5350);
}