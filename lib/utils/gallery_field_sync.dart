import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tatvan_kepenk/services/supabase_service.dart';

/// Utility class to help synchronize gallery image fields in Supabase
class GalleryFieldSync {
  /// Synchronizes image_url and image_path fields in all gallery items
  ///
  /// This ensures consistent behavior regardless of which field is used in the code
  static Future<Map<String, dynamic>> syncImageFields({
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
                Text('Veritabanı alanları senkronize ediliyor...'),
              ],
            ),
          );
        },
      );
    }

    int updatedCount = 0;
    int failedCount = 0;
    List<Map<String, dynamic>> failedItems = [];

    try {
      // Get Supabase service instance
      final supabaseService = Get.find<SupabaseService>();

      // Get all gallery items
      final items = await supabaseService.getGalleryItems();

      // Check each item for inconsistencies
      for (var item in items) {
        final imageUrl = item['image_url'];
        final imagePath = item['image_path'];
        if (item['id'] != null) {
          // If fields are inconsistent or one is missing, update the item
          if (imageUrl != imagePath || imageUrl == null || imagePath == null) {
            try {
              // Choose the non-null value, preferring image_url
              final correctValue = imageUrl ?? imagePath;

              if (correctValue != null) {
                await supabaseService.client
                    .from('gallery_items')
                    .update({
                      'image_url': correctValue,
                      'image_path': correctValue,
                      'updated_at': DateTime.now().toIso8601String(),
                    })
                    .eq('id', item['id']);
                updatedCount++;
                debugPrint(
                  'Updated item ${item['id']} - synchronized image fields',
                );
              }
            } catch (e) {
              debugPrint('Error updating item ${item['id']}: $e');
              failedCount++;
              failedItems.add(item);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error during sync: $e');
      failedCount++;
    } finally {
      if (showProgress && context != null) {
        Navigator.of(context).pop();
      }
    }

    return {
      'total': updatedCount + failedCount,
      'updated': updatedCount,
      'failed': failedCount,
      'failedItems': failedItems,
    };
  }
}
