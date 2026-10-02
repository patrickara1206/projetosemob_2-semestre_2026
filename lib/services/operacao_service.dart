import '../models/operacao_overview.dart';
import 'api_service.dart';

class OperacaoService {
  Future<OperacaoOverview> getOverview({required String periodo}) async => OperacaoOverview.fromJson(await ApiService.get('/operacao/overview'));
}

