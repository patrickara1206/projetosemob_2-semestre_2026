import 'package:flutter/material.dart';

import '../models/ml_overview.dart';

class AiLogsPanel extends StatelessWidget {
  final List<LogIa> logs;
  const AiLogsPanel({super.key, required this.logs});

  static const _bg = Color(0xFF0B2557);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final isMobile = box.maxWidth < 600;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'LOGS DE IA EM TEMPO REAL',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.circle, size: 8, color: Color(0xFF2196F3)),
                ],
              ),
              SizedBox(height: isMobile ? 12 : 16),
              if (logs.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Sem logs no momento',
                      style: TextStyle(color: Color(0xFF7F8FA9), fontSize: 12),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: logs.length,
                  itemBuilder: (context, index) =>
                      _LogLine(log: logs[index], isMobile: isMobile),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LogLine extends StatelessWidget {
  final LogIa log;
  final bool isMobile;
  const _LogLine({required this.log, required this.isMobile});

  (Color border, Color text) _colors() {
    switch (log.nivel) {
      case 'ok':
        return (Color(0xFF4CAF50), Colors.white);
      case 'warn':
        return (AppColorsLog.orange, AppColorsLog.orange);
      case 'erro':
        return (AppColorsLog.red, AppColorsLog.red);
      case 'debug':
        return (Color(0xFF3B4F7A), Color(0xFF7F8FA9));
      default:
        return (Color(0xFF3B4F7A), Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (border, text) = _colors();

    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: border, width: 2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              log.hora,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: Color(0xFF7F8FA9),
              ),
            ),
            SizedBox(height: 2),
            Text(
              log.mensagem,
              softWrap: true,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: isMobile ? 10.5 : 11,
                color: text,
              ),
            ),
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
