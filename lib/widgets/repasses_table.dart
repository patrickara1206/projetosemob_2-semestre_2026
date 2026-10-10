import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/financeiro_overview.dart';

class RepassesTable extends StatelessWidget {
  final List<RepasseLinha> linhas;
  final int pagina;
  final int totalPaginas;
  final TextEditingController buscaCtrl;
  final ValueChanged<String> onBusca;
  final ValueChanged<int> onPagina;

  const RepassesTable({
    super.key,
    required this.linhas,
    required this.pagina,
    required this.totalPaginas,
    required this.buscaCtrl,
    required this.onBusca,
    required this.onPagina,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Repasses por Linha Operacional',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy)),
                      SizedBox(height: 2),
                      Text('Demonstrativo consolidado de liquidação mensal',
                          style:
                              TextStyle(fontSize: 11, color: AppColors.muted)),
                    ],
                  ),
                  SizedBox(
                    width: 260,
                    child: TextField(
                      controller: buscaCtrl,
                      onChanged: onBusca,
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Buscar linha ou operador...',
                        hintStyle: const TextStyle(
                            fontSize: 12, color: AppColors.muted),
                        prefixIcon: const Icon(Icons.search,
                            size: 18, color: AppColors.muted),
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          LayoutBuilder(builder: (context, box) {
            final width = math.max(box.maxWidth, 820.0);
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Column(
                  children: [
                    const _Header(),
                    if (linhas.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Nenhum repasse no período',
                            style: TextStyle(color: AppColors.muted)),
                      )
                    else
                      for (final l in linhas) _DataRow(item: l),
                  ],
                ),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 10,
                children: [
                  Text('Mostrando ${linhas.length} linhas operacionais',
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.muted)),
                  _Paginacao(
                    pagina: pagina,
                    total: totalPaginas,
                    onPagina: onPagina,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _flex = [5, 2, 3, 3, 3, 2];

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    Widget cell(String t, int flex, Alignment a) => Expanded(
          flex: flex,
          child: Align(
            alignment: a,
            child: Text(t,
                style: const TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
        );

    return Container(
      color: const Color(0xFFF1F3F6),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          cell('Linha / Operador', _flex[0], Alignment.centerLeft),
          cell('Passageiros', _flex[1], Alignment.centerRight),
          cell('Custo Operacional', _flex[2], Alignment.centerRight),
          cell('Glosas / Retenções', _flex[3], Alignment.centerRight),
          cell('Valor Líquido', _flex[4], Alignment.centerRight),
          cell('Status', _flex[5], Alignment.center),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final RepasseLinha item;
  const _DataRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final temGlosa = item.glosa > 0;

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: _flex[0],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.linha,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy)),
                if (item.operador.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(item.operador,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.muted)),
                ],
              ],
            ),
          ),
          Expanded(
            flex: _flex[1],
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(fmtInt(item.passageiros),
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.text)),
            ),
          ),
          Expanded(
            flex: _flex[2],
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(fmtMoney(item.custoOperacional),
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.text)),
            ),
          ),
          Expanded(
            flex: _flex[3],
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                  temGlosa
                      ? '- ${fmtMoney(item.glosa)}'
                      : fmtMoney(item.glosa),
                  style: TextStyle(
                      fontSize: 12,
                      color: temGlosa ? AppColors.red : AppColors.muted)),
            ),
          ),
          Expanded(
            flex: _flex[4],
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(fmtMoney(item.valorLiquido),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy)),
            ),
          ),
          Expanded(
            flex: _flex[5],
            child: Align(
              alignment: Alignment.center,
              child: _StatusChip(status: item.status),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color fg;
    late final Color bg;
    switch (status) {
      case 'auditoria':
        label = 'Em Auditoria';
        fg = const Color(0xFFB7791F);
        bg = AppColors.orangeSoft;
        break;
      case 'retencao':
        label = 'Retenção';
        fg = AppColors.red;
        bg = AppColors.redSoft;
        break;
      default:
        label = 'Liquidado';
        fg = AppColors.green;
        bg = AppColors.greenSoft;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

class _Paginacao extends StatelessWidget {
  final int pagina;
  final int total;
  final ValueChanged<int> onPagina;
  const _Paginacao(
      {required this.pagina, required this.total, required this.onPagina});

  @override
  Widget build(BuildContext context) {
    final numeros = List.generate(math.min(total, 7), (i) => i + 1);

    return Wrap(
      spacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _Btn(
          label: 'Anterior',
          enabled: pagina > 1,
          onTap: () => onPagina(pagina - 1),
        ),
        for (final n in numeros)
          _Btn(
            label: '$n',
            active: n == pagina,
            onTap: () => onPagina(n),
          ),
        _Btn(
          label: 'Próximo',
          enabled: pagina < total,
          onTap: () => onPagina(pagina + 1),
        ),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;
  const _Btn({
    required this.label,
    required this.onTap,
    this.active = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.navy : const Color(0xFFF1F3F6),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: active
                    ? Colors.white
                    : (enabled ? AppColors.navy : AppColors.muted))),
      ),
    );
  }
}