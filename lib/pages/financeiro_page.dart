import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/formatters.dart';
import '../core/theme.dart';
import '../widgets/data_widgets.dart';
import '../widgets/kpi_card.dart';

class FinanceiroPage extends StatelessWidget {
  const FinanceiroPage({super.key});
  @override
  Widget build(BuildContext context) => DataPage(path:'/financeiro/overview',builder:(context,data){
    final rows=List<Map<String,dynamic>>.from(data['serie']);
    return LayoutBuilder(builder:(context,box){
      const gap=16.0;
      final cols=box.maxWidth>=1100?4:box.maxWidth>=650?2:1;
      final width=(box.maxWidth-48-gap*(cols-1))/cols;
      return SingleChildScrollView(padding:const EdgeInsets.all(24),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const PageHeading(title:'Informações Financeiras',subtitle:'Vendas de créditos, utilização e crédito circulante dos relatórios.'),
        DataNotice(meta:data['meta']),
        Wrap(spacing:gap,runSpacing:gap,children:[
          SizedBox(width:width,child:KpiCard(title:'Total de vendas',icon:Icons.payments_outlined,value:money(data['total_vendas']),variation:(data['variacao_vendas'] as num?)?.toDouble())),
          SizedBox(width:width,child:KpiCard(title:'Total de utilização',icon:Icons.confirmation_number_outlined,value:money(data['total_utilizacao']))),
          SizedBox(width:width,child:KpiCard(title:'Crédito circulante reportado',icon:Icons.account_balance_wallet_outlined,value:money(data['credito_circulante']))),
          SizedBox(width:width,child:KpiCard(title:'Vendas menos utilização',icon:Icons.compare_arrows,value:money(data['diferenca']))),
        ]),const SizedBox(height:20),
        Panel(title:'Evolução diária de vendas e utilização',child:SizedBox(height:300,child:rows.isEmpty?const Center(child:Text('Sem informações financeiras no período.')):LineChart(LineChartData(
          minY:0,gridData:const FlGridData(drawVerticalLine:false),borderData:FlBorderData(show:false),
          titlesData:FlTitlesData(topTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),rightTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),
            bottomTitles:AxisTitles(sideTitles:SideTitles(showTitles:true,interval:rows.length>7?(rows.length/6).ceilToDouble():1,
              getTitlesWidget:(v,m){final i=v.toInt();return i>=0&&i<rows.length?Text(rows[i]['date'].toString().substring(8),style:const TextStyle(fontSize:10)):const SizedBox();})),
            leftTitles:const AxisTitles(sideTitles:SideTitles(showTitles:true,reservedSize:55))),
          lineBarsData:[for(final metric in ['sales','usage']) LineChartBarData(spots:[for(var i=0;i<rows.length;i++) FlSpot(i.toDouble(),(rows[i][metric] as num).toDouble())],
            color:metric=='sales'?AppColors.primary:AppColors.cyan,barWidth:3,dotData:const FlDotData(show:false))],
        )))),const SizedBox(height:12),
        const Text('Azul: vendas · Ciano: utilização',style:TextStyle(color:AppColors.muted)),const SizedBox(height:20),
        Panel(title:'Detalhamento diário',child:SingleChildScrollView(scrollDirection:Axis.horizontal,child:DataTable(columns:const [
          DataColumn(label:Text('Data')),DataColumn(label:Text('Vendas')),DataColumn(label:Text('Utilização')),DataColumn(label:Text('Crédito circulante'))],
          rows:[for(final r in rows) DataRow(cells:[DataCell(Text(r['date'])),DataCell(Text(money(r['sales']))),DataCell(Text(money(r['usage']))),DataCell(Text(money(r['circulating'])))])]))),
        const SizedBox(height:16),Text(data['nota'] as String,style:const TextStyle(fontSize:12,color:AppColors.muted)),
      ]));
    });
  });
}

String money(dynamic v) {
  if(v==null) {return '--';}
  final value=v as num;
  final cents=(value.abs()*100).round();
  return 'R\$ ${value<0?'-':''}${fmtInt(cents~/100)},${(cents%100).toString().padLeft(2,'0')}';
}
