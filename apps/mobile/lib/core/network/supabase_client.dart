import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/services/supabase_service.dart';

class SupabaseNetworkClient {
  static SupabaseClient get client => SupabaseService.client;
  static bool get isInitialized => SupabaseService.hasValidCredentials;
}
