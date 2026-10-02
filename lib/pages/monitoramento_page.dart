import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/data_widgets.dart';

class MonitoramentoPage extends StatelessWidget {
  const MonitoramentoPage({super.key});
  @override
  Widget build(BuildContext context) => DataPage(path:'/monitoramento',builder:(context,data){
    final alerts=List<Map<String,dynamic>>.from(data['alerts']);
    return SingleChildScrollView(padding:const EdgeInsets.all(24),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const PageHeading(title:'Monitoramento e Anomalias',subtitle:'Alertas transparentes para apoiar a análise da operação.'),
      DataNotice(meta:data['meta']),
      Panel(title:'Regras em execução',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        for(final rule in data['rules']) Padding(padding:const EdgeInsets.only(bottom:10),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Icon(Icons.check_circle_outline,size:18,color:AppColors.primary),const SizedBox(width:8),Expanded(child:Text(rule))])),
        const SizedBox(height:8),Text(data['limitation'],style:const TextStyle(fontSize:12,color:AppColors.muted)),
      ])),const SizedBox(height:20),
      Panel(title:'${alerts.length} alertas no período selecionado',child:alerts.isEmpty?const Text('Nenhum alerta detectado pelas regras nesse período.'):
        Column(children:[for(final a in alerts) Card(color:a['severity']=='critical'?AppColors.redSoft:AppColors.orangeSoft,child:ListTile(
          leading:Icon(Icons.warning_amber,color:a['severity']=='critical'?AppColors.red:AppColors.orange),
          title:Text('${a['date']} · ${a['kind']}'),subtitle:Text(a['message']),
          trailing:const Icon(Icons.chevron_right),onTap:()=>showDetails(context,'Detalhes do alerta','${a['message']}\n\nData: ${a['date']}\nSeveridade: ${a['severity']}\n\nConsulte o relatório original na tela Dados e Banco. O alerta não confirma irregularidade.')))])),
    ]));
  });
}
