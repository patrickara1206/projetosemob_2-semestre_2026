import '../models/ml_overview.dart';
import 'api_service.dart';
class MlService {
 Future<MlOverview> getOverview({required String periodo}) async {
 final data = await ApiService.get('/monitoramento');
 return MlOverview(anomalias24h: (data['alerts'] as List).length);
 }
}
