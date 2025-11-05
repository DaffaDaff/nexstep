import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://zuxzbmiqnvhzwtqndprm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp1eHpibWlxbnZoend0cW5kcHJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIzNzA4ODEsImV4cCI6MjA3Nzk0Njg4MX0.CIBu5ihH-_4l3m8DQHolXDjsymcPb4kesUB5VCF3Mc8',
  );
}

final supabase = Supabase.instance.client;
