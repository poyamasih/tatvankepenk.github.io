class SupabaseConfig {
  // اطلاعات اتصال به پروژه Supabase
  static const String supabaseUrl = 'https://wqcucptjaxpfdstptrxb.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndxY3VjcHRqYXhwZmRzdHB0cnhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc5MjY3MjUsImV4cCI6MjA2MzUwMjcyNX0.mdFONcgKvurhzT-zh-5e1ZcLUOmiweDW01SI0bXuF3I';

  // برای تست اتصال می‌توانید از این متد استفاده کنید
  static bool isConfigured() {
    return supabaseUrl != 'https://YOUR_PROJECT_ID.supabase.co' &&
        supabaseAnonKey != 'YOUR_ANON_KEY';
  }
}
