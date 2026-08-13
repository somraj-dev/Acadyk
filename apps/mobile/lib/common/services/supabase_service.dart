import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://ydzrxbqjacctwtxsosem.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlkenJ4YnFqYWNjdHd0eHNvc2VtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI5OTY1NTIsImV4cCI6MjA5ODU3MjU1Mn0.ojhFzpo4uK36ThEdWpYF9Qo94HHBUb0iPg7mwjzboJE';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static bool get hasValidCredentials {
    return supabaseUrl != 'https://placeholder-project-url.supabase.co' &&
        supabaseAnonKey != 'placeholder-anon-key';
  }

  /// Get a public URL for a file in a storage bucket.
  static String getPublicUrl(String bucket, String path) {
    return client.storage.from(bucket).getPublicUrl(path);
  }
}
