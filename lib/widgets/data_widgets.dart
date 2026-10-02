import 'package:flutter/material.dart';
import '../core/state.dart';
import '../core/theme.dart';
import '../services/api_service.dart';

class DataPage extends StatefulWidget {
  final String path;
  final Widget Function(BuildContext, Map<String,dynamic>) builder;
  const DataPage({super.key,required this.path,required this.builder});
  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  late Future<Map<String,dynamic>> future;
  void reload() => setState(() { future=ApiService.get(widget.path); });
  @override
  void initState() {super.initState();future=ApiService.get(widget.path);periodoNotifier.addListener(reload);}
  @override
  void dispose() {periodoNotifier.removeListener(reload);super.dispose();}
  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String,dynamic>>(
    future:future,builder:(context,snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {return const Center(child:CircularProgressIndicator());}
      if (snapshot.hasError) {return Center(child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[
        const Icon(Icons.cloud_off,size:40,color:AppColors.muted),const SizedBox(height:12),Text('${snapshot.error}',textAlign:TextAlign.center),
        const SizedBox(height:12),FilledButton(onPressed:reload,child:const Text('Tentar novamente'))])));}
      return widget.builder(context,snapshot.data!);
    });
}

class DataNotice extends StatelessWidget {
  final Map<String,dynamic>? meta;
  const DataNotice({super.key,this.meta});
  @override
  Widget build(BuildContext context) {
    final m=meta;
    return Container(width:double.infinity,margin:const EdgeInsets.only(bottom:16),padding:const EdgeInsets.all(14),
      decoration:BoxDecoration(color:const Color(0xFFEAF2FC),borderRadius:BorderRadius.circular(8)),
      child:Text(m==null ? 'Fonte: relatórios Smart Report · Dados históricos de julho a setembro de 2026.' :
        'Fonte: Smart Report · ${m['inicio']} a ${m['fim']} · ${m['dias_com_dados']} de ${m['dias_esperados']} dias com dados.'
        '${m['linha']!=null ? ' Linha ${m['linha']}: passageiros e financeiro não são discriminados por linha.' : ''}',
        style:const TextStyle(fontSize:12,color:AppColors.navy)));
  }
}

class PageHeading extends StatelessWidget {
  final String title, subtitle;
  const PageHeading({super.key,required this.title,required this.subtitle});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Wrap(alignment:WrapAlignment.spaceBetween,crossAxisAlignment:WrapCrossAlignment.center,spacing:16,runSpacing:8,children:[
      Text(title,style:const TextStyle(fontSize:26,fontWeight:FontWeight.w800,color:AppColors.navy)),const ExportButton()]),
    const SizedBox(height:6),Text(subtitle,style:const TextStyle(color:AppColors.muted,fontSize:12)),const SizedBox(height:20)]);
}

class ExportButton extends StatelessWidget {
  const ExportButton({super.key});
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(onPressed:() async {
    try {await ApiService.export();} catch(e) {if(context.mounted) {ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$e')));}}
  },icon:const Icon(Icons.download,size:16),label:const Text('Exportar CSV'));
}

class Panel extends StatelessWidget {
  final String title;
  final Widget child;
  const Panel({super.key,required this.title,required this.child});
  @override
  Widget build(BuildContext context) => Container(width:double.infinity,padding:const EdgeInsets.all(20),decoration:cardDecoration(),
    child:Material(color:Colors.transparent,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w700,color:AppColors.navy,fontSize:15)),
      const SizedBox(height:16),child])));
}

Future<void> showDetails(BuildContext context,String title,String message) => showDialog<void>(context:context,builder:(context)=>AlertDialog(
  title:Text(title),content:SingleChildScrollView(child:SelectableText(message)),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Fechar'))]));
