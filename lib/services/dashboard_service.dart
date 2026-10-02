import '../models/dashboard_overview.dart';
import 'api_service.dart';

class DashboardService {
  Future<DashboardOverview> getOverview({required String periodo}) async => DashboardOverview.fromJson(await ApiService.get('/dashboard/overview'));
}

