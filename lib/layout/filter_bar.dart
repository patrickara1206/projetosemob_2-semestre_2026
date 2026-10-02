import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/state.dart';
import '../core/theme.dart';
import '../services/api_service.dart';

class FilterBar extends StatefulWidget {
  final bool compact;
  const FilterBar({super.key,required this.compact});
  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  Map<String,dynamic>? meta;
  String? error;
  @override
  void initState() {super.initState();periodoNotifier.addListener(update);load();}
  @override
  void dispose() {periodoNotifier.removeListener(update);super.dispose();}
  void update() {if(mounted) {setState((){});}}
  Future<void> load() async {
    try {
      final data=await ApiService.get('/meta',filtered:false);
      if(!mounted) {return;}
      periodoNotifier.metadata=data;
      final months=List<String>.from(data['months']);
      if(months.isNotEmpty && !months.contains(periodoNotifier.mes)) {periodoNotifier.mes=months.last;}
      setState(() {meta=data;error=null;});
      periodoNotifier.refresh();
    } catch(e) {if(mounted) {setState(()=>error='API desconectada');}}
  }
  String iso(DateTime day) => day.toIso8601String().substring(0,10);
  Future<void> selectDate() async {
    final day=await showDatePicker(context:context,initialDate:DateTime.parse(periodoNotifier.referencia),
      firstDate:DateTime(2020),lastDate:DateTime(2035),helpText:'Data de referência dos relatórios');
    if(day!=null) {periodoNotifier.referencia=iso(day);periodoNotifier.refresh();}
  }
  Future<void> selectPeriod(Periodo p) async {
    if(p==Periodo.personalizado) {
      final range=await showDateRangePicker(context:context,firstDate:DateTime(2020),lastDate:DateTime(2035),
        initialDateRange:DateTimeRange(start:DateTime.parse(periodoNotifier.inicio??'2026-08-01'),end:DateTime.parse(periodoNotifier.fim??'2026-08-31')),
        helpText:'Intervalo dos relatórios');
      if(range==null) {return;}
      periodoNotifier.inicio=iso(range.start);periodoNotifier.fim=iso(range.end);
    }
    periodoNotifier.value=p;periodoNotifier.refresh();
  }
  @override
  Widget build(BuildContext context) {
    final months=List<String>.from(meta?['months']??['2026-08']);
    final lines=List<Map<String,dynamic>>.from(meta?['lines']??[]);
    return Container(color:Colors.white,padding:const EdgeInsets.all(12),child:Column(children:[
      Row(children:[if(widget.compact) Builder(builder:(c)=>IconButton(onPressed:()=>Scaffold.of(c).openDrawer(),icon:const Icon(Icons.menu))),
        const Expanded(child:Text('Dashboard Operacional',style:TextStyle(color:AppColors.navy,fontSize:18,fontWeight:FontWeight.w800))),
        if(!widget.compact) Text(error??(meta?['storage']=='supabase'?'Supabase conectado':'Dados locais'),style:const TextStyle(fontSize:12,color:AppColors.muted)),
        IconButton(tooltip:'Alertas do período',onPressed:()=>context.go('/machine-learning'),icon:const Icon(Icons.notifications_none)),
        IconButton(tooltip:'Dados e configuração do banco',onPressed:()=>context.go('/dados'),icon:const Icon(Icons.storage_outlined)),
        IconButton(tooltip:'Atualizar dados',onPressed:load,icon:const Icon(Icons.refresh)),
      ]),
      Wrap(spacing:12,runSpacing:8,crossAxisAlignment:WrapCrossAlignment.center,children:[
        for(final p in Periodo.values) ChoiceChip(label:Text(p.label),selected:periodoNotifier.value==p,onSelected:(_)=>selectPeriod(p)),
        if(periodoNotifier.value==Periodo.mes) SizedBox(width:170,child:DropdownButtonFormField<String>(
          initialValue:months.contains(periodoNotifier.mes)?periodoNotifier.mes:null,isExpanded:true,
          decoration:const InputDecoration(labelText:'Mês dos dados',isDense:true,border:OutlineInputBorder()),
          items:[for(final m in months) DropdownMenuItem(value:m,child:Text('${m.substring(5)}/${m.substring(0,4)}'))],
          onChanged:(m){if(m!=null){periodoNotifier.mes=m;periodoNotifier.refresh();}})),
        if(periodoNotifier.value==Periodo.hoje || periodoNotifier.value==Periodo.semana)
          OutlinedButton.icon(onPressed:selectDate,icon:const Icon(Icons.calendar_today,size:16),label:Text(periodoNotifier.referencia)),
        if(periodoNotifier.value==Periodo.personalizado)
          OutlinedButton(onPressed:()=>selectPeriod(Periodo.personalizado),child:Text('${periodoNotifier.inicio} → ${periodoNotifier.fim}')),
        SizedBox(width:160,child:DropdownButtonFormField<String>(initialValue:periodoNotifier.linha??'',isExpanded:true,
          decoration:const InputDecoration(labelText:'Linha',isDense:true,border:OutlineInputBorder()),
          items:[const DropdownMenuItem(value:'',child:Text('Todas as linhas')),for(final l in lines) DropdownMenuItem(value:l['code'] as String,child:Text(l['name'] as String))],
          onChanged:(v){periodoNotifier.linha=v==''?null:v;periodoNotifier.refresh();})),
      ]),
    ]));
  }
}
