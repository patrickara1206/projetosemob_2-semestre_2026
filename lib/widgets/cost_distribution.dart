import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/financeiro_overview.dart';

/// Distribuição de Custos. Deve receber altura definida pelo pai.
class CostDistributionCard extends StatelessWidget {
  final List<CustoItem> itens;
  final double? total;
  const CostDistributionCard({super.key, required this.itens, this.total});

  static const _cores = [
    Color(0xFF0D1B5E),
    Color(0xFF0B5FB0),
    Color(0xFF00BCD4),
    Color(0xFFB3C7F0),
  ];

  String _milhoes(double v) => 'R\$ ${fmtDec(v / 1000000, digits: 2)}M';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Distribuição de Custos',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy)),
          const SizedBox(height: 2),
          const Text('Composição paramétrica Geptam',
              style: TextStyle(fontSize: 11, color: AppColors.muted)),
          const SizedBox(height: 20),
          Expanded(
            child: itens.isEmpty
                ? const Center(
                    child: Text('Sem dados para o período selecionado',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted)))
                : ListView(
                    physics: const ClampingScrollPhysics(),
                    children: [
                      for (var i = 0; i < itens.length; i++)
                        _Linha(
                          item: itens[i],
                          cor: _cores[i % _cores.length],
                          valorTxt: _milhoes(itens[i].valor),
                        ),
                    ],
                  ),
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text('Custo Total Operacional',
                    style: TextStyle(fontSize: 11, color: AppColors.muted)),
              ),
              Text(total == null ? 'R\$ --' : _milhoes(total!),
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  final CustoItem item;
  final Color cor;
  final String valorTxt;
  const _Linha(
      {required this.item, required this.cor, required this.valorTxt});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(item.nome,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.text)),
              ),
              Text('${fmtDec(item.percentual, digits: 0)}% ($valorTxt)',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (item.percentual / 100).clamp(0.0, 1.0),
              minHeight: 6,
              color: cor,
              backgroundColor: const Color(0xFFF1F3F6),
            ),
          ),
        ],
      ),
    );
  }
}