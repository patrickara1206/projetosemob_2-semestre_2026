import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/state.dart';
import '../core/theme.dart';
import '../models/passageiros_overview.dart';
import '../services/passageiros_service.dart';
import '../widgets/category_table.dart';
import '../widgets/demand_chart.dart';
import '../widgets/tariff_donut.dart';

class PassageirosPage extends StatefulWidget {
  const PassageirosPage({super.key});

  @override
  State<PassageirosPage> createState() => _PassageirosPageState();
}

class _PassageirosPageState extends State<PassageirosPage> {
  final _service = PassageirosService();
  late Future<PassageirosOverview> _future;

  @override
void initState() {
  super.initState();
  _future = _fetch();
  periodoNotifier.addListener(_reload);
}

  @override
  void dispose() {
    periodoNotifier.removeListener(_reload);
    super.dispose();
  }

  Future<PassageirosOverview> _fetch() {
  return _service.getOverview();
}

  void _reload() {
  setState(() {
    _future = _fetch();
  });
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PassageirosOverview>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _reload,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        return _Content(data: snapshot.data!);
      },
    );
  }
}

String _refAnterior(Periodo periodo) {
  switch (periodo) {
    case Periodo.total:
      return 'todos os dados';

    case Periodo.mes:
      return 'mês anterior';

    case Periodo.quinzena:
      return 'quinzena anterior';
  }
}

class _Content extends StatelessWidget {
  final PassageirosOverview data;

  const _Content({required this.data});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, box) {
        final largura = box.maxWidth;
        final padding = largura < 700 ? 16.0 : 24.0;
        const gap = 16.0;
        final colunas = largura >= 1000 ? 4 : (largura >= 500 ? 2 : 1);
        final larguraCartao =
            (largura - padding * 2 - gap * (colunas - 1)) / colunas;

        final cards = <Widget>[
          _Kpi(
            title: 'TOTAL DE PASSAGEIROS',
            icon: Icons.people_outline,
            value: fmtCompact(data.totalPassageiros),
            footer: _variacao(
              context,
              data.totalVariacao,
              _refAnterior(periodoNotifier.value),
            ),
          ),
          _Kpi(
            title: '% PAGANTES',
            icon: Icons.payments_outlined,
            value: data.pctPagantes == null
                ? '--'
                : '${fmtDec(data.pctPagantes)}%',
            footer: _nota(
              context,
              '${fmtCompact(data.qtdPagantes)} passagens registradas',
            ),
          ),
          _Kpi(
            title: '% GRATUIDADES',
            icon: Icons.confirmation_number_outlined,
            value: data.pctGratuidades == null
                ? '--'
                : '${fmtDec(data.pctGratuidades)}%',
            footer: _nota(
              context,
              '${fmtCompact(data.qtdGratuidades)} acessos livres',
            ),
          ),
          _Kpi(
            title: 'PICO DE DEMANDA',
            icon: Icons.schedule,
            value: data.picoFaixa ?? '--',
            footer: _nota(
              context,
              'Média de ${fmtCompact(data.picoMediaHora)} p/ hora',
            ),
          ),
        ];

        final chart = DemandChart(serie: data.serie);
        final donut = TariffDonut(pctPagantes: data.pctPagantes);

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Demanda e Perfil de Passageiros',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: cores.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Monitoramento de fluxo diário e distribuição de '
                'categorias tarifárias.',
                style: TextStyle(
                  fontSize: 12,
                  color: cores.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Exportar Relatório'),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final card in cards)
                    SizedBox(width: larguraCartao, child: card),
                ],
              ),
              const SizedBox(height: 20),
              if (largura >= 1000)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: SizedBox(height: 440, child: chart),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 3,
                      child: SizedBox(height: 440, child: donut),
                    ),
                  ],
                )
              else ...[
                SizedBox(height: 400, child: chart),
                const SizedBox(height: 16),
                SizedBox(height: 400, child: donut),
              ],
              const SizedBox(height: 20),
              CategoryTable(
                categorias: data.categorias,
                onVerRelatorio: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _nota(BuildContext context, String texto) {
  return Text(
    texto,
    style: TextStyle(
      fontSize: 11,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}

Widget _variacao(
  BuildContext context,
  double? valor,
  String referencia,
) {
  if (valor == null) return _nota(context, '--');

  final escuro = Theme.of(context).brightness == Brightness.dark;
  final positivo = valor >= 0;

  final cor = positivo
      ? (escuro ? const Color(0xFF86EFAC) : AppColors.green)
      : (escuro ? const Color(0xFFFCA5A5) : AppColors.red);

  return Row(
    children: [
      Icon(
        positivo ? Icons.trending_up : Icons.trending_down,
        size: 14,
        color: cor,
      ),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          '${fmtPercent(valor)} vs $referencia',
          style: TextStyle(fontSize: 11, color: cor),
        ),
      ),
    ],
  );
}

class _Kpi extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final Widget footer;

  const _Kpi({
    required this.title,
    required this.icon,
    required this.value,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cores.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(icon, size: 20, color: cores.primary),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: cores.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 8),
          footer,
        ],
      ),
    );
  }
}