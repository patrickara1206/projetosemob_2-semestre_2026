import 'package:flutter/material.dart';
import '../core/state.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../widgets/data_widgets.dart';

class ViagensPage extends StatefulWidget {
  const ViagensPage({super.key});
  @override
  State<ViagensPage> createState()=>_ViagensPageState();
}
class _ViagensPageState extends State<ViagensPage> {
  int offset=0;
  late Future<Map<String,dynamic>> future;
  Future<Map<String,dynamic>> fetch()=>ApiService.get('/trips',extra:{'offset':'$offset','limit':'50'});
  void reload(){offset=0;setState(()=>future=fetch());}
  void page(int n){offset=n;setState(()=>future=fetch());}
  @override
  void initState(){super.initState();future=fetch();periodoNotifier.addListener(reload);}
  @override
  void dispose(){periodoNotifier.removeListener(reload);super.dispose();}
  @override
  Widget build(BuildContext context)=>FutureBuilder<Map<String,dynamic>>(future:future,builder:(context,s){
    if(s.connectionState!=ConnectionState.done){return const Center(child:CircularProgressIndicator());}
    if(s.hasError){return Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Text('${s.error}'),FilledButton(onPressed:reload,child:const Text('Tentar novamente'))]));}
    final data=s.data!,rows=List<Map<String,dynamic>>.from(data['items']);final total=data['total'] as int;
    return SingleChildScrollView(padding:const EdgeInsets.all(24),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const PageHeading(title:'Consulta de Viagens',subtitle:'Registros originais com preferência pelo relatório mensal quando há sobreposição.'),
      const DataNotice(),
      Panel(title:'$total registros no período',child:SingleChildScrollView(scrollDirection:Axis.horizontal,child:DataTable(columns:const [
        DataColumn(label:Text('Data')),DataColumn(label:Text('Linha')),DataColumn(label:Text('Veículo')),DataColumn(label:Text('Tipo')),
        DataColumn(label:Text('Início')),DataColumn(label:Text('Fim')),DataColumn(label:Text('Km produtivos'))],rows:[for(final r in rows) DataRow(cells:[
          DataCell(Text('${r['date']}')),DataCell(Text('${r['line']??'--'}')),DataCell(Text('${r['vehicle']??'--'}')),DataCell(Text('${r['kind']}')),
          DataCell(Text('${r['start']??'--'}')),DataCell(Text('${r['end']??'--'}')),DataCell(Text('${r['km_productive']??'--'}'))])]))),
      const SizedBox(height:16),Wrap(crossAxisAlignment:WrapCrossAlignment.center,spacing:16,children:[
        OutlinedButton(onPressed:offset>0?()=>page(offset-50):null,child:const Text('Anterior')),
        Text(total==0?'Sem viagens':'${offset+1}–${offset+rows.length} de $total',style:const TextStyle(color:AppColors.muted)),
        OutlinedButton(onPressed:offset+50<total?()=>page(offset+50):null,child:const Text('Próxima'))]),
    ]));
  });
}
