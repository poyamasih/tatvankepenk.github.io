import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tatvan_kepenk/pages/SplashScreen.dart';
import 'package:tatvan_kepenk/pages/home_page.dart';
import 'package:tatvan_kepenk/pages/admin/admin_login.dart';
import 'package:tatvan_kepenk/pages/admin/admin_panel_supabase.dart';
import 'package:tatvan_kepenk/pages/admin/secure_admin_panel.dart';
import 'package:tatvan_kepenk/pages/admin/supabase_test_page.dart';
import 'package:tatvan_kepenk/pages/supabase_content_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tatvan_kepenk/services/auth_service.dart';
import 'package:tatvan_kepenk/services/content_storage.dart';
import 'package:tatvan_kepenk/services/supabase_service.dart';
import 'package:tatvan_kepenk/services/supabase_content_service.dart';
import 'package:tatvan_kepenk/utils/db_schema_fix.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Initialize services
  final authService = AuthService(prefs);
  final contentStorage = ContentStorage(prefs);

  // Initialize Supabase
  final supabaseService = SupabaseService();
  await supabaseService.initialize();

  // Initialize the Supabase content service
  final supabaseContentService = SupabaseContentService(supabaseService, prefs);
  // Sync data from Supabase to local storage with timeout
  try {
    // Only try once with a strict timeout to avoid freezing app startup
    await supabaseContentService.syncAllData().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint('Initial data sync timed out - will try again in HomePage');
        return;
      },
    );
    debugPrint('Successfully synced data from Supabase');
  } catch (e) {
    debugPrint('Error in initial data sync: $e');
    // Continue with app startup even if sync fails
  }

  // If we couldn't sync, we'll continue with local data
  // Try to create database stored procedures
  try {
    await DbSchemaFix.createStoredProcedures();
    debugPrint('Database stored procedures created or verified');

    // Try to fix schema issues during startup
    final schemaResult = await DbSchemaFix.fixGalleryItemsSchema(
      showProgress: false,
    );
    debugPrint('Schema fix result: ${schemaResult['message']}');
  } catch (e) {
    debugPrint('Error setting up database schema: $e');
    // Continue anyway - we'll try again when needed
  }

  // Make services available globally
  Get.put(prefs);
  Get.put(authService);
  Get.put(contentStorage); // Keep for backward compatibility
  Get.put(supabaseService);
  Get.put(supabaseContentService);

  runApp(MyApp(isLoggedIn: authService.isLoggedIn()));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: isLoggedIn ? '/admin/panel/supabase' : '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/HomePage', page: () => const HomePage()),
        GetPage(
          name: '/admin',
          page: () => const AdminLogin(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/admin/panel',
          page: () => const AdminPanelSupabase(),
          transition: Transition.fadeIn,
          middlewares: [
            AuthMiddleware(),
            // Redirect middleware to always go to the Supabase version instead
            RedirectToSupabaseMiddleware(),
          ],
        ),
        GetPage(
          name: '/admin/panel/supabase',
          page: () => const SecureAdminPanel(),
          transition: Transition.fadeIn,
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/admin/supabase-test',
          page: () => const SupabaseTestPage(),
          transition: Transition.fadeIn,
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/supabase-content',
          page: () => const SupabaseContentView(),
          transition: Transition.fadeIn,
        ),
      ],
    );
  }
}

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // Check both paths to ensure proper authentication
    if (!authService.isLoggedIn() &&
        (route == '/admin/panel' || route == '/admin/panel/supabase')) {
      return const RouteSettings(name: '/admin');
    }
    return null;
  }
}

class RedirectToSupabaseMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Always redirect from /admin/panel to /admin/panel/supabase
    if (route == '/admin/panel') {
      return const RouteSettings(name: '/admin/panel/supabase');
    }
    return null;
  }
}
