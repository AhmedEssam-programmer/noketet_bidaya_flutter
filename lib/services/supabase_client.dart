import 'package:supabase_flutter/supabase_flutter.dart';

class AppSupabase {
  static const url = 'https://vuhpnvmygbtajbaqdnxo.supabase.co';
  static const anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ1aHBudm15Z2J0YWpiYXFkbnhvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwODA0OTgsImV4cCI6MjA5MTY1NjQ5OH0.pEJzbP7VW4UtO7rR_pJE529Mli5Q9oMWRJp5uoTUy8Q';

  static SupabaseClient get client => Supabase.instance.client;
}

