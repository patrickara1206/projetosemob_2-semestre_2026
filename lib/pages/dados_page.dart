import 'dart:convert';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/formatters.dart';
import '../core/state.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../widgets/data_widgets.dart';

class DadosPage extends StatefulWidget {
  const DadosPage({super.key});
  @override
  State<DadosPage> createState()=>_DadosPageState();
}
class _DadosPageState extends State<DadosPage> {
  bool uploading=false;
  Future<void> upload() async {
    final file=await openFile(acceptedTypeGroups:[const XTypeGroup(label:'Relatórios ZIP',extensions:['zip'])]);
    if(file==null || !mounted){return;}
    if(await file.length()>160*1024*1024){if(mounted){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Limite de 160 MB.')));}return;}
    final controller=TextEditingController();
    if(!mounted){controller.dispose();return;}
    final key=await showDialog<String>(context:context,builder:(c)=>AlertDialog(title:const Text('Importar novos relatórios'),
      content:Column(mainAxisSize:MainAxisSize.min,children:[Text('Arquivo: ${file.name}'),const SizedBox(height:12),
        const Text('Informe a chave administrativa configurada no backend. Ela não é a senha do Supabase.'),
        const SizedBox(height:12),TextField(controller:controller,obscureText:true,decoration:const InputDecoration(labelText:'Chave administrativa'))]),
      actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Cancelar')),FilledButton(onPressed:()=>Navigator.pop(c,controller.text),child:const Text('Importar'))]));
    // Dialog transitions may still reference the controller; do not dispose synchronously.
    if(key==null || key.isEmpty || !mounted){return;}
    setState(()=>uploading=true);
    try {
      final request=http.MultipartRequest('POST',ApiService.uri('/imports',filtered:false))..headers['X-Admin-Key']=key;
      request.files.add(http.MultipartFile.fromBytes('file',await file.readAsBytes(),filename:file.name));
      final response=await http.Response.fromStream(await ApiService.client.send(request));
      final body=jsonDecode(utf8.decode(response.bodyBytes));
      if(response.statusCode!=200){throw Exception(body['detail']??'Falha ao importar.');}
      if(!mounted){return;}
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(body['duplicate']==true?'Este ZIP já foi importado. Os dados não foram duplicados.':'Relatórios importados com sucesso.')));
      periodoNotifier.refresh();
    } catch(e){if(mounted){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$e')));}}
    finally{if(mounted){setState(()=>uploading=false);}}
  }
  @override
  Widget build(BuildContext context)=>DataPage(path:'/meta',builder:(context,data){
    final imports=List<Map<String,dynamic>>.from(data['imports']),docs=List<Map<String,dynamic>>.from(data['documents']);
    final cloud=data['storage']=='supabase';
    return SingleChildScrollView(padding:const EdgeInsets.all(24),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const PageHeading(title:'Dados e Banco',subtitle:'Origem dos dados, histórico de importação e configuração do armazenamento.'),
      Panel(title:cloud?'Supabase conectado':'Banco local em uso',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(cloud?'PostgreSQL com tabelas relacionais e documentos JSONB.':'Os dados estão salvos no banco SQLite local. A conexão com o Supabase ainda não foi configurada.'),
        const SizedBox(height:12),Wrap(spacing:12,runSpacing:8,children:[
          Chip(label:Text('${data['days']} dias com relatórios')),Chip(label:Text('${docs.length} tabelas de origem')),
          Chip(label:Text('${fmtInt(data['trips_archived'])} registros de viagens preservados'))]),
        const SizedBox(height:12),Text('Cobertura: ${data['first']} a ${data['last']}. Relatórios mensais têm prioridade sobre quinzenais nos indicadores.',style:const TextStyle(color:AppColors.muted,fontSize:12)),
        const SizedBox(height:16),FilledButton.icon(onPressed:uploading?null:upload,icon:const Icon(Icons.upload_file),label:Text(uploading?'Importando…':'Importar ZIP')),
      ])),const SizedBox(height:20),
      if(!cloud) ...[Panel(title:'Conectar ao Supabase',child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('1. Crie seu projeto no Supabase.\n2. Execute a migração SQL inclusa no projeto.\n3. Configure a conexão privada no backend e importe o ZIP.\n4. Reinicie a API; esta tela mostrará Supabase conectado.'),
        SizedBox(height:12),Text('O guia docs/SUPABASE.md contém os passos. As credenciais ficam apenas no backend.',style:TextStyle(color:AppColors.muted,fontSize:12))])),const SizedBox(height:20)],
      Panel(title:'Histórico de importações',child:Column(children:[for(final r in imports) ListTile(leading:const Icon(Icons.inventory_2_outlined),
        title:Text(r['name']),subtitle:Text('${r['created_at']}\nSHA-256: ${r['sha256']}'),isThreeLine:true,
        trailing:Text('#${r['id']}'))])),const SizedBox(height:20),
      Panel(title:'Relatórios originais preservados',child:Column(children:[for(final d in docs) ListTile(leading:const Icon(Icons.description_outlined),
        title:Text(d['source']),subtitle:Text('Tabela ${d['table_index']}'),trailing:const Icon(Icons.open_in_new),
        onTap:()=>showDialog<void>(context:context,builder:(c)=>ReportViewer(ident:d['id'] as int)))])),
    ]));
  });
}

class ReportViewer extends StatefulWidget {
  final int ident;
  const ReportViewer({super.key,required this.ident});
  @override
  State<ReportViewer> createState()=>_ReportViewerState();
}
class _ReportViewerState extends State<ReportViewer> {
  int offset=0;
  late Future<Map<String,dynamic>> future;
  Future<Map<String,dynamic>> fetch()=>ApiService.get('/documents/${widget.ident}',filtered:false,extra:{'offset':'$offset','limit':'50'});
  void page(int n){setState((){offset=n;future=fetch();});}
  @override
  void initState(){super.initState();future=fetch();}
  @override
  Widget build(BuildContext context)=>AlertDialog(title:const Text('Relatório de origem'),content:SizedBox(width:1100,height:500,
    child:FutureBuilder<Map<String,dynamic>>(future:future,builder:(context,s){
      if(s.connectionState!=ConnectionState.done){return const Center(child:CircularProgressIndicator());}
      if(s.hasError){return Text('${s.error}');}
      final data=s.data!,columns=List<String>.from(data['columns']),rows=List<Map<String,dynamic>>.from(data['rows']);
      return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(data['source']),const SizedBox(height:12),
        Expanded(child:SingleChildScrollView(child:SingleChildScrollView(scrollDirection:Axis.horizontal,child:DataTable(
          columns:[for(final col in columns) DataColumn(label:Text(col))],rows:[for(final r in rows) DataRow(cells:[for(final col in columns) DataCell(Text('${r[col]??'--'}'))])])))),
        Wrap(spacing:12,crossAxisAlignment:WrapCrossAlignment.center,children:[Text('${offset+1}–${offset+rows.length} de ${data['total']}'),
          TextButton(onPressed:offset>0?()=>page(offset-50):null,child:const Text('Anterior')),
          TextButton(onPressed:offset+50<(data['total'] as int)?()=>page(offset+50):null,child:const Text('Próxima'))]),
      ]);
    })),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Fechar'))]);
}
