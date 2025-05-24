import 'package:flutter/material.dart';
import 'package:tatvan_kepenk/services/supabase_service.dart';
import 'package:tatvan_kepenk/utils/improved_image_upload.dart';

/// Extension methods for the SupabaseService to handle gallery functionality
extension GalleryServiceExtension on SupabaseService {
  /// Save a new gallery item
  Future<void> saveGalleryItem({
    required String title,
    required String description,
    required String location,
    required String imageUrl,
    String? date,
  }) async {
    try {
      // Try with multiple approaches to handle different database schemas
      try {
        await client.from('gallery_items').insert({
          'title': title,
          'description': description,
          'location': location,
          'image_url': imageUrl,
          'image_path': imageUrl, // For compatibility
          'date': date ?? DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        return;
      } catch (firstError) {
        debugPrint('First attempt to save gallery item failed: $firstError');
      }

      // If the first attempt failed, try with only image_path
      try {
        await client.from('gallery_items').insert({
          'title': title,
          'description': description,
          'location': location,
          'image_path': imageUrl,
          'date': date ?? DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        return;
      } catch (secondError) {
        debugPrint('Second attempt to save gallery item failed: $secondError');
      }

      // Final attempt with only image_url
      await client.from('gallery_items').insert({
        'title': title,
        'description': description,
        'location': location,
        'image_url': imageUrl,
        'date': date ?? DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error saving gallery item: $e');
      throw Exception('Failed to save gallery item: $e');
    }
  }

  /// Update an existing gallery item
  Future<void> updateGalleryItem({
    required String id,
    String? title,
    String? description,
    String? location,
    String? imageUrl,
    String? date,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (location != null) updateData['location'] = location;
      if (date != null) updateData['date'] = date;

      if (imageUrl != null) {
        updateData['image_url'] = imageUrl;
        updateData['image_path'] = imageUrl;
      }

      if (updateData.isNotEmpty) {
        updateData['updated_at'] = DateTime.now().toIso8601String();

        await client.from('gallery_items').update(updateData).eq('id', id);
      }
    } catch (e) {
      debugPrint('Error updating gallery item: $e');
      throw Exception('Failed to update gallery item: $e');
    }
  }

  /// Delete a gallery item and its associated image
  Future<void> deleteGalleryItem(String id, String imageUrl) async {
    final imageHelper = ImprovedImageUpload(client: client);

    try {
      // Try to delete the image file first
      bool imageDeleted = false;

      if (imageUrl.isNotEmpty) {
        imageDeleted = await imageHelper.deleteImageFromUrl(imageUrl);
      }

      // Delete the database record
      await client.from('gallery_items').delete().eq('id', id);

      debugPrint('Gallery item deleted. Image deleted: $imageDeleted');
    } catch (e) {
      debugPrint('Error deleting gallery item: $e');
      throw Exception('Failed to delete gallery item: $e');
    }
  }

  /// Helper method to upload an image using the ImprovedImageUpload
  Future<String> uploadImageToGallery(dynamic imageFile) async {
    final imageHelper = ImprovedImageUpload(client: client);
    return await imageHelper.uploadImage(imageFile);
  }
}
