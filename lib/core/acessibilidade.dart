import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configurações de acessibilidade visual do app.
class AcessibilidadeConfig {
  final double escalaFonte; // 1.0 a 1.5
  final bool altoContraste;

  const AcessibilidadeConfig({
    this.escalaFonte = 1.0,
    this.altoContraste = false,
  });

  AcessibilidadeConfig copyWith({
    double? escalaFonte,
    bool? altoContraste,
  }) =>
      AcessibilidadeConfig(
        escalaFonte: escalaFonte ?? this.escalaFonte,
        altoContraste: altoContraste ?? this.altoContraste,
      );

  bool get padrao => escalaFonte == 1.0 && !altoContraste;
}

/// Estado global. Qualquer tela pode ler ou alterar este valor.
final ValueNotifier<AcessibilidadeConfig> acessibilidadeNotifier =
    ValueNotifier(const AcessibilidadeConfig());

const double _escalaMin = 1.0;
const double _escalaMax = 1.5;
const double _escalaPasso = 0.1;

const String _kEscala = 'acessibilidade_escala_fonte';
const String _kContraste = 'acessibilidade_alto_contraste';

/// Lê a configuração salva e passa a salvar a cada mudança.
/// Chame uma vez no main(), antes do runApp.
Future<void> carregarAcessibilidade() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    acessibilidadeNotifier.value = AcessibilidadeConfig(
      escalaFonte:
          (prefs.getDouble(_kEscala) ?? 1.0).clamp(_escalaMin, _escalaMax),
      altoContraste: prefs.getBool(_kContraste) ?? false,
    );

    acessibilidadeNotifier.addListener(() async {
      try {
        final cfg = acessibilidadeNotifier.value;
        await prefs.setDouble(_kEscala, cfg.escalaFonte);
        await prefs.setBool(_kContraste, cfg.altoContraste);
      } catch (_) {
        // Se não conseguir salvar, o app segue funcionando normalmente.
      }
    });
  } catch (_) {
    // Se não conseguir ler, usa a configuração padrão.
  }
}

// Matriz de contraste aumentado (fator 1.6).
const List<double> _matrizContraste = [
  1.6, 0, 0, 0, -76.8, //
  0, 1.6, 0, 0, -76.8,
  0, 0, 1.6, 0, -76.8,
  0, 0, 0, 1, 0,
];

/// Envolve o app inteiro: aplica fonte/contraste e mostra o botão flutuante.
/// Use no `builder` do MaterialApp.router.
class AcessibilidadeLayer extends StatelessWidget {
  final Widget? child;
  const AcessibilidadeLayer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AcessibilidadeConfig>(
      valueListenable: acessibilidadeNotifier,
      builder: (context, cfg, _) {
        final mq = MediaQuery.of(context);

        Widget app = MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(cfg.escalaFonte)),
          child: child ?? const SizedBox.shrink(),
        );

        if (cfg.altoContraste) {
          app = ColorFiltered(
            colorFilter: const ColorFilter.matrix(_matrizContraste),
            child: app,
          );
        }

        return Stack(
          children: [
            Positioned.fill(child: app),
            // Fora do filtro, para o botão ficar sempre legível.
            const Positioned(
              left: 16,
              bottom: 16,
              child: _PainelAcessibilidade(),
            ),
          ],
        );
      },
    );
  }
}

class _PainelAcessibilidade extends StatefulWidget {
  const _PainelAcessibilidade();

  @override
  State<_PainelAcessibilidade> createState() => _PainelAcessibilidadeState();
}

class _PainelAcessibilidadeState extends State<_PainelAcessibilidade> {
  bool _aberto = false;

  void _mudarFonte(double delta) {
    final atual = acessibilidadeNotifier.value;
    final nova = (atual.escalaFonte + delta).clamp(_escalaMin, _escalaMax);
    acessibilidadeNotifier.value = atual.copyWith(
      escalaFonte: double.parse(nova.toStringAsFixed(1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF0B2557);

    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_aberto)
            ValueListenableBuilder<AcessibilidadeConfig>(
              valueListenable: acessibilidadeNotifier,
              builder: (context, cfg, _) {
                return Container(
                  width: 260,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Acessibilidade',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: azul,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tamanho da fonte',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Semantics(
                            button: true,
                            label: 'Diminuir fonte',
                            child: OutlinedButton(
                              onPressed: cfg.escalaFonte > _escalaMin
                                  ? () => _mudarFonte(-_escalaPasso)
                                  : null,
                              child: const Text('A−'),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${(cfg.escalaFonte * 100).round()}%',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: azul,
                              ),
                            ),
                          ),
                          Semantics(
                            button: true,
                            label: 'Aumentar fonte',
                            child: OutlinedButton(
                              onPressed: cfg.escalaFonte < _escalaMax
                                  ? () => _mudarFonte(_escalaPasso)
                                  : null,
                              child: const Text('A+'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Alto contraste',
                            style: TextStyle(fontSize: 12)),
                        value: cfg.altoContraste,
                        onChanged: (v) => acessibilidadeNotifier.value =
                            cfg.copyWith(altoContraste: v),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: cfg.padrao
                              ? null
                              : () => acessibilidadeNotifier.value =
                                  const AcessibilidadeConfig(),
                          child: const Text('Restaurar padrão',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          Semantics(
            button: true,
            label: 'Abrir opções de acessibilidade',
            child: FloatingActionButton.small(
              heroTag: 'acessibilidade_fab',
              backgroundColor: azul,
              foregroundColor: Colors.white,
              onPressed: () => setState(() => _aberto = !_aberto),
              child: Icon(_aberto ? Icons.close : Icons.accessibility_new),
            ),
          ),
        ],
      ),
    );
  }
}