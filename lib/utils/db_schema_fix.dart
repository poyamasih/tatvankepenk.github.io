import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tatvan_kepenk/services/supabase_service.dart';

/// Utility class to fix database schema issues
class DbSchemaFix {
  /// Check the gallery_items table schema and add missing columns if needed
  static Future<Map<String, dynamic>> fixGalleryItemsSchema({
    BuildContext? context,
    bool showProgress = true,
  }) async {
    if (showProgress && context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Veritabanı şeması düzeltiliyor...'),
              ],
            ),
          );
        },
      );
    }

    try {
      final supabaseService = Get.find<SupabaseService>();
      final client = supabaseService.client;

      // First check if image_url column exists
      final hasImageUrlColumn = await _checkColumnExists(
        client,
        'gallery_items',
        'image_url',
      );

      // Then check if image_path column exists
      final hasImagePathColumn = await _checkColumnExists(
        client,
        'gallery_items',
        'image_path',
      );

      debugPrint(
        'Schema check - image_url exists: $hasImageUrlColumn, '
        'image_path exists: $hasImagePathColumn',
      );

      // If both columns exist, no need to fix
      if (hasImageUrlColumn && hasImagePathColumn) {
        if (context != null && showProgress && context.mounted) {
          Navigator.of(context).pop();
        }
        return {
          'success': true,
          'message': 'Veritabanı şeması güncel.',
          'image_url_added': false,
          'image_path_added': false,
        };
      } // Add missing columns
      if (!hasImageUrlColumn) {
        await client.rpc(
          'add_column_if_not_exists',
          params: {
            'p_table_name': 'gallery_items',
            'p_column_name': 'image_url',
            'p_column_type': 'TEXT',
          },
        );
        debugPrint('Added image_url column to gallery_items table');
      }

      if (!hasImagePathColumn) {
        await client.rpc(
          'add_column_if_not_exists',
          params: {
            'p_table_name': 'gallery_items',
            'p_column_name': 'image_path',
            'p_column_type': 'TEXT',
          },
        );
        debugPrint('Added image_path column to gallery_items table');
      }

      // Double-check that columns were added
      final finalCheck = await Future.wait([
        _checkColumnExists(client, 'gallery_items', 'image_url'),
        _checkColumnExists(client, 'gallery_items', 'image_path'),
      ]);

      if (context != null && showProgress && context.mounted) {
        Navigator.of(context).pop();
      }

      return {
        'success': finalCheck[0] && finalCheck[1],
        'message': 'Veritabanı şeması güncellendi.',
        'image_url_added': !hasImageUrlColumn && finalCheck[0],
        'image_path_added': !hasImagePathColumn && finalCheck[1],
      };
    } catch (e) {
      debugPrint('Error fixing database schema: $e');
      if (context != null && showProgress && context.mounted) {
        Navigator.of(context).pop();
      }
      return {'success': false, 'message': 'Hata: $e', 'error': e.toString()};
    }
  }

  /// Check if a column exists in a table
  static Future<bool> _checkColumnExists(
    SupabaseClient client,
    String tableName,
    String columnName,
  ) async {
    try {
      final result = await client.rpc(
        'check_column_exists',
        params: {'table_name': tableName, 'column_name': columnName},
      );
      return result as bool;
    } catch (e) {
      debugPrint('Error checking column existence: $e');
      return false;
    }
  }

  /// Run this before app startup to create required stored procedures
  static Future<bool> createStoredProcedures() async {
    try {
      final supabaseService = Get.find<SupabaseService>();
      final client = supabaseService.client;

      // Create stored procedure for checking if a column exists
      await client.rpc('create_check_column_exists_function');

      // Create stored procedure for adding a column if it doesn't exist
      await client.rpc('create_add_column_function');

      return true;
    } catch (e) {
      debugPrint('Error creating stored procedures: $e');
      return false;
    }
  }
}
