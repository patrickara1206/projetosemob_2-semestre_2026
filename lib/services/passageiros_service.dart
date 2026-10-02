import '../models/passageiros_overview.dart';
import 'api_service.dart';

class PassageirosService {
  Future<PassageirosOverview> getOverview({required String periodo}) async => PassageirosOverview.fromJson(await ApiService.get('/passageiros/overview'));
}

