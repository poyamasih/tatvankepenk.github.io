// filepath: c:\flutter procekts\tatvan_kepenk\lib\services\supabase_service.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tatvan_kepenk/services/supabase_config.dart';
import 'package:tatvan_kepenk/utils/file_utils.dart';
import 'package:tatvan_kepenk/utils/improved_image_upload.dart';
import 'package:uuid/uuid.dart';

// Import the extension
export 'gallery_service.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient _client;
  bool _initialized = false;
  final uuid = const Uuid();

  // Singleton pattern
  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  // Getter for the Supabase client
  SupabaseClient get client => _client;

  Future<void> initialize() async {
    if (_initialized) return;

    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );

    _client = Supabase.instance.client;
    _initialized = true;
  }

  // Home Content Methods
  Future<Map<String, dynamic>?> getHomeContent() async {
    final response =
        await _client.from('home_content').select('*').limit(1).maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>> createHomeContent(
    Map<String, dynamic> data,
  ) async {
    // Check if there's already a record
    final existing = await getHomeContent();

    if (existing != null) {
      // Update existing record
      await _client.from('home_content').update(data).eq('id', existing['id']);
      return {...existing, ...data};
    } else {
      // Create new record
      final newData = {...data, 'created_at': DateTime.now().toIso8601String()};
      final response =
          await _client.from('home_content').insert(newData).select().single();
      return response;
    }
  }

  Future<void> saveHomeContent({
    required String title,
    required String description,
  }) async {
    // Check if there's already a record
    final existing = await getHomeContent();

    if (existing != null) {
      await _client
          .from('home_content')
          .update({
            'title': title,
            'description': description,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', existing['id']);
    } else {
      await _client.from('home_content').insert({
        'title': title,
        'description': description,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // Kepenk Content Methods
  Future<Map<String, dynamic>?> getKepenkContent() async {
    final response =
        await _client.from('kepenk_content').select('*').limit(1).maybeSingle();
    return response;
  }

  Future<void> saveKepenkContent({
    required String title,
    required String description,
  }) async {
    final existing = await getKepenkContent();

    if (existing != null) {
      await _client
          .from('kepenk_content')
          .update({
            'title': title,
            'description': description,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', existing['id']);
    } else {
      await _client.from('kepenk_content').insert({
        'title': title,
        'description': description,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // Kapilar Content Methods
  Future<Map<String, dynamic>?> getKapilarContent() async {
    final response =
        await _client
            .from('kapilar_content')
            .select('*')
            .limit(1)
            .maybeSingle();
    return response;
  }

  Future<void> saveKapilarContent({
    required String title,
    required String description,
  }) async {
    final existing = await getKapilarContent();

    if (existing != null) {
      await _client
          .from('kapilar_content')
          .update({
            'title': title,
            'description': description,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', existing['id']);
    } else {
      await _client.from('kapilar_content').insert({
        'title': title,
        'description': description,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // About Content Methods
  Future<Map<String, dynamic>?> getAboutSection(int sectionId) async {
    final response =
        await _client
            .from('about_sections')
            .select('*')
            .eq('section_number', sectionId)
            .maybeSingle();
    return response;
  }

  Future<List<Map<String, dynamic>>> getAboutSections() async {
    final response = await _client
        .from('about_sections')
        .select('*')
        .order('section_number', ascending: true);

    return List<Map<String, dynamic>>.from(response ?? []);
  }

  Future<void> saveAboutContent({
    required int sectionId,
    required String title,
    required String description,
  }) async {
    final existing = await getAboutSection(sectionId);

    if (existing != null) {
      await _client
          .from('about_sections')
          .update({
            'title': title,
            'description': description,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', existing['id']);
    } else {
      await _client.from('about_sections').insert({
        'section_number': sectionId,
        'title': title,
        'description': description,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // Contact Info Methods
  Future<Map<String, dynamic>?> getContactInfo() async {
    final response =
        await _client.from('contact_info').select('*').limit(1).maybeSingle();
    return response;
  }

  Future<void> saveContactInfo({
    required String address,
    required String phone,
    required String email,
    required String workHours,
  }) async {
    final existing = await getContactInfo();

    if (existing != null) {
      await _client
          .from('contact_info')
          .update({
            'address': address,
            'phone': phone,
            'email': email,
            'work_hours': workHours,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', existing['id']);
    } else {
      await _client.from('contact_info').insert({
        'address': address,
        'phone': phone,
        'email': email,
        'work_hours': workHours,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // Gallery Methods
  Future<List<Map<String, dynamic>>> getGalleryItems() async {
    try {
      final response = await _client
          .from('gallery_items')
          .select('*')
          .order('created_at', ascending: false);

      // Convert response to list of maps
      final items = List<Map<String, dynamic>>.from(response ?? []);

      // Handle field consistency for all items
      for (var item in items) {
        // Use the non-null value, preferring image_url
        final imageUrl = item['image_url'];
        final imagePath = item['image_path'];
        final correctValue =
            imageUrl ??
            imagePath ??
            ''; // Default to empty string if both are null

        // Always ensure both fields exist and have the same non-null value
        item['image_url'] = correctValue;
        item['image_path'] = correctValue;

        // Ensure other text fields are not null
        item['title'] = item['title']?.toString() ?? '';
        item['description'] = item['description']?.toString() ?? '';
        item['location'] = item['location']?.toString() ?? '';
      }

      return items;
    } catch (e) {
      debugPrint('Error fetching gallery items from Supabase: $e');
      return [];
    }
  }

  Future<String> uploadImage(dynamic imageFile) async {
    // Create the helper and delegate to it
    final imageHelper = ImprovedImageUpload(client: _client);
    return await imageHelper.uploadImage(imageFile);
  }

  Future<void> saveGalleryItem({
    required String title,
    required String description,
    required String location,
    required String imageUrl,
    String? date,
  }) async {
    try {
      // First try with both image fields
      try {
        await _client.from('gallery_items').insert({
          'title': title,
          'description': description,
          'location': location,
          'image_url': imageUrl,
          'image_path': imageUrl,
          'date': date ?? DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        return; // Success, exit the method
      } catch (firstError) {
        debugPrint('First attempt to save gallery item failed: $firstError');
        // Try alternative approaches
      }

      // If the first attempt failed, try with only image_path
      try {
        await _client.from('gallery_items').insert({
          'title': title,
          'description': description,
          'location': location,
          'image_path': imageUrl,
          'date': date ?? DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        return; // Success, exit the method
      } catch (secondError) {
        debugPrint('Second attempt to save gallery item failed: $secondError');
        // Try the final approach
      }

      // If both previous attempts failed, try with only image_url
      await _client.from('gallery_items').insert({
        'title': title,
        'description': description,
        'location': location,
        'image_url': imageUrl,
        'date': date ?? DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('All attempts to save gallery item failed: $e');
      throw Exception('Failed to save gallery item: $e');
    }
  }

  Future<bool> updateGalleryItem({
    required String id,
    required String title,
    required String description,
    required String location,
    String? imageUrl,
    String? date,
  }) async {
    try {
      // First retrieve the original item to compare later
      Map<String, dynamic>? originalItem;
      try {
        originalItem =
            await _client
                .from('gallery_items')
                .select()
                .eq('id', id)
                .maybeSingle();
        if (originalItem == null) {
          debugPrint(
            'Warning: Gallery item with id $id not found. Cannot update non-existent record.',
          );
          return false;
        }
      } catch (e) {
        debugPrint('Error fetching original gallery item: $e');
        // Continue anyway to try the update
      }

      debugPrint(
        'Updating gallery item $id with title: $title, description: $description, location: $location',
      ); // Get current image values to ensure we don't set them to null
      String currentImagePath = originalItem?['image_path']?.toString() ?? '';
      String currentImageUrl = originalItem?['image_url']?.toString() ?? '';

      final Map<String, dynamic> updateData = {
        'id': id, // Include ID for upsert
        'title': title,
        'description': description,
        'location': location,
        'updated_at': DateTime.now().toIso8601String(),
        'date': date ?? DateTime.now().toIso8601String(),
        // Always include image fields to prevent NOT NULL constraint violation
        'image_path': currentImagePath,
        'image_url': currentImageUrl,
      };

      // If imageUrl is provided, update both image fields
      if (imageUrl != null && imageUrl.isNotEmpty) {
        updateData['image_url'] = imageUrl;
        updateData['image_path'] = imageUrl;
      }

      debugPrint(
        'Sending update to Supabase for gallery item $id with data: $updateData',
      );
      try {
        // First attempt: regular update approach
        final response = await _client
            .from('gallery_items')
            .update(updateData)
            .eq('id', id);

        debugPrint('Update response: $response');

        // Second attempt: Try upsert if update didn't work
        if (response == null || (response is Map && response.isEmpty)) {
          debugPrint('Regular update returned no response, trying upsert...');
          try {
            final upsertResponse = await _client
                .from('gallery_items')
                .upsert(updateData);

            debugPrint('Upsert response: $upsertResponse');
          } catch (upsertError) {
            debugPrint('Upsert attempt failed: $upsertError');
            // Try a simple INSERT with ON CONFLICT DO UPDATE directly using RPC
            try {
              final simpleUpdate = {
                'p_id': id,
                'p_title': title,
                'p_description': description,
                'p_location': location,
                'p_image_url': updateData['image_url'],
                'p_image_path': updateData['image_path'],
                'p_date': updateData['date'],
              };

              debugPrint(
                'Attempting to update via simple_update_gallery_item RPC...',
              );
              await _client.rpc(
                'simple_update_gallery_item',
                params: simpleUpdate,
              );
              return true; // If we get here, update succeeded
            } catch (simpleUpdateError) {
              debugPrint('Simple update RPC failed: $simpleUpdateError');
              throw upsertError; // Re-throw the upsert error
            }
          }
        }
      } catch (updateError) {
        debugPrint('Error during update operation: $updateError');
        // As a last resort, try to use direct SQL through a special RPC
        try {
          // Map the values to match what our stored procedure expects
          final directUpdateParams = {
            'item_id': id,
            'new_title': title,
            'new_description': description,
            'new_location': location,
            'new_image_url': updateData['image_url'],
            'new_image_path': updateData['image_path'],
          };

          debugPrint(
            'Attempting direct update via direct_update_gallery_item RPC...',
          );
          await _client.rpc(
            'direct_update_gallery_item',
            params: directUpdateParams,
          );
          return true; // If we get here, update succeeded
        } catch (rpcError) {
          debugPrint('RPC update attempt failed: $rpcError');
          throw updateError; // Re-throw the original error
        }
      }

      // Wait a short time for Supabase to process the update
      await Future.delayed(const Duration(milliseconds: 1000));

      // Verify update with a fetch
      try {
        debugPrint('Verifying update by fetching gallery item $id');
        final updatedItem =
            await _client
                .from('gallery_items')
                .select('*')
                .eq('id', id)
                .single();

        debugPrint('Raw fetched item after update: $updatedItem');
        debugPrint(
          'Updated gallery item verification: title=${updatedItem['title']}, description=${updatedItem['description']}, location=${updatedItem['location']}',
        );

        // Check if values were actually updated
        if (originalItem != null) {
          // Create comparison fields
          final Map<String, dynamic> comparisonFields = {
            'title': {
              'original': originalItem['title'],
              'updated': updatedItem['title'],
              'expected': title,
            },
            'description': {
              'original': originalItem['description'],
              'updated': updatedItem['description'],
              'expected': description,
            },
            'location': {
              'original': originalItem['location'],
              'updated': updatedItem['location'],
              'expected': location,
            },
          };

          // Check for image URL updates if provided
          if (imageUrl != null && imageUrl.isNotEmpty) {
            comparisonFields['image_url'] = {
              'original': originalItem['image_url'],
              'updated': updatedItem['image_url'],
              'expected': imageUrl,
            };
            comparisonFields['image_path'] = {
              'original': originalItem['image_path'],
              'updated': updatedItem['image_path'],
              'expected': imageUrl,
            };
          }

          // Log each field comparison
          debugPrint('Field comparison results:');
          bool hasChanges = false;
          comparisonFields.forEach((field, values) {
            final bool fieldChanged = values['original'] != values['updated'];
            final bool expectedMatch = values['updated'] == values['expected'];
            debugPrint(
              '  $field: changed=$fieldChanged, matches expected=$expectedMatch',
            );
            debugPrint('    - original: ${values['original']}');
            debugPrint('    - updated: ${values['updated']}');
            debugPrint('    - expected: ${values['expected']}');

            if (fieldChanged) hasChanges = true;
          });

          if (!hasChanges) {
            debugPrint(
              'Warning: Gallery item appears unchanged after update operation. This may indicate an issue with RLS policies.',
            );

            // Try one more approach - direct SQL update via RPC function
            try {
              debugPrint('Attempting force update via RPC...');
              await _client.rpc(
                'admin_update_gallery_item',
                params: {
                  'p_id': id,
                  'p_title': title,
                  'p_description': description,
                  'p_location': location,
                  'p_image_url': imageUrl,
                  'p_image_path': imageUrl,
                  'p_date': date ?? DateTime.now().toIso8601String(),
                },
              );

              // Check if RPC worked
              await Future.delayed(const Duration(milliseconds: 500));
              final afterRpcItem =
                  await _client
                      .from('gallery_items')
                      .select('*')
                      .eq('id', id)
                      .single();

              if (afterRpcItem['title'] == title &&
                  afterRpcItem['description'] == description &&
                  afterRpcItem['location'] == location) {
                debugPrint('RPC update successful!');
                return true;
              } else {
                debugPrint('RPC update failed - values still unchanged');
              }
            } catch (rpcError) {
              debugPrint('RPC update failed: $rpcError');
            }

            return false;
          } else {
            debugPrint('Gallery item successfully updated and verified!');
            return true;
          }
        }

        return updatedItem['title'] == title &&
            updatedItem['description'] == description &&
            updatedItem['location'] == location;
      } catch (fetchError) {
        debugPrint('Error verifying gallery item update: $fetchError');
        // If we can't verify, but the update didn't throw an error, assume it worked
        return true;
      }
    } catch (e) {
      debugPrint('Error updating gallery item: $e');
      throw Exception('Failed to update gallery item: $e');
    }
  }

  // Contact Form Methods
  Future<void> submitContactForm({
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    await _client.from('contact_forms').insert({
      'name': name,
      'email': email,
      'phone': phone,
      'message': message,
      'date': DateTime.now().toIso8601String(),
      'read': false,
    });
  }

  // Improved method to extract storage path from URL
  String? _extractStoragePathFromUrl(String url) {
    try {
      // Handle both full URLs and paths
      if (url.startsWith('http')) {
        final uri = Uri.parse(url);
        final pathSegments = uri.pathSegments;
        if (pathSegments.length >= 2) {
          // Usually in format /storage/v1/object/public/bucket-name/file-name
          return pathSegments.last; // Return just the filename
        }
      } else if (url.contains('/')) {
        // If it's already just a path
        return url.split('/').last;
      } else {
        // It's just a filename
        return url;
      }
      return null;
    } catch (e) {
      debugPrint('Error extracting storage path: $e');
      return null;
    }
  }

  // Method to delete just the image from storage
  Future<bool> deleteImageFromStorage(String imageUrl) async {
    try {
      final storagePath = _extractStoragePathFromUrl(imageUrl);
      if (storagePath != null) {
        await _client.storage.from('galery').remove([storagePath]);
        return true;
      }
      debugPrint('Could not extract storage path from URL: $imageUrl');
      return false;
    } catch (e) {
      debugPrint('Error deleting image from storage: $e');
      return false;
    }
  }

  // Enhanced method to delete gallery item with detailed debugging
  Future<bool> deleteGalleryItem(String id, [String? imageUrl]) async {
    bool imageDeleted = false;
    bool recordDeleted = false;

    try {
      // Step 1: Try to delete the image if URL is provided
      if (imageUrl != null && imageUrl.isNotEmpty) {
        imageDeleted = await deleteImageFromStorage(imageUrl);
        debugPrint(
          'Image delete status: ${imageDeleted ? "SUCCESS" : "FAILED"}',
        );
      } // Step 2: Try to delete the database record with detailed error handling and retry mechanism
      try {
        // Before deleting, check if the record exists
        final checkResponse =
            await _client
                .from('gallery_items')
                .select('id')
                .eq('id', id)
                .maybeSingle();

        if (checkResponse == null) {
          debugPrint(
            'WARNING: Record with ID $id not found in gallery_items table',
          );
          // The record doesn't exist, so we can consider this a "success" since the caller wanted it gone
          return true;
        }

        // First attempt - normal delete
        try {
          await _client.from('gallery_items').delete().eq('id', id);
        } catch (firstAttemptError) {
          debugPrint('First delete attempt failed: $firstAttemptError');
          // Continue to check if it worked despite the error
        }

        // Check if first delete was successful
        var afterFirstCheck =
            await _client
                .from('gallery_items')
                .select('id')
                .eq('id', id)
                .maybeSingle();

        if (afterFirstCheck == null) {
          // First attempt worked
          debugPrint('Record delete successful on first attempt');
          return true;
        }

        // Second attempt - with RLS bypass (only works if proper admin rights)
        debugPrint('First delete failed, trying alternative approach...');
        try {
          // Direct database delete operation
          final response = await _client.rpc(
            'delete_gallery_item',
            params: {'item_id': id},
          );
          debugPrint('RPC delete response: $response');
        } catch (secondAttemptError) {
          debugPrint('Second delete attempt failed: $secondAttemptError');
        }

        // Final check if delete was successful
        final afterCheckResponse =
            await _client
                .from('gallery_items')
                .select('id')
                .eq('id', id)
                .maybeSingle();

        recordDeleted = afterCheckResponse == null;
        debugPrint(
          'Final record delete status: ${recordDeleted ? "SUCCESS" : "FAILED"}',
        );

        if (!recordDeleted) {
          debugPrint(
            'CRITICAL: All delete operations appeared to fail - record still exists',
          );
        }

        return recordDeleted;
      } catch (dbError) {
        debugPrint('SEVERE ERROR deleting gallery record: $dbError');
        throw Exception(
          'Failed to delete gallery record (possibly RLS issue): $dbError',
        );
      }
    } catch (e) {
      debugPrint('SEVERE ERROR in deleteGalleryItem: $e');
      // If image was deleted but record deletion failed, we have an inconsistent state
      if (imageDeleted && !recordDeleted) {
        debugPrint(
          'WARNING: Image deleted but record remains in database. Data inconsistency!',
        );
      }
      throw Exception('Failed to delete gallery item: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getContactForms() async {
    final response = await _client
        .from('contact_forms')
        .select('*')
        .order('date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> markContactFormAsRead(String id) async {
    await _client.from('contact_forms').update({'read': true}).eq('id', id);
  }

  Future<void> deleteContactForm(String id) async {
    await _client.from('contact_forms').delete().eq('id', id);
  }

  // Validate if gallery item data is correctly saved
  Future<bool> validateGalleryItemData({
    required String id,
    String? title,
    String? description,
    String? location,
  }) async {
    try {
      final item =
          await _client
              .from('gallery_items')
              .select()
              .eq('id', id)
              .maybeSingle();

      if (item == null) {
        debugPrint('Gallery item $id not found during validation');
        return false;
      }

      bool valid = true;

      if (title != null && item['title']?.toString() != title) {
        debugPrint(
          'Title mismatch - Database: ${item['title']}, Expected: $title',
        );
        valid = false;
      }

      if (description != null &&
          item['description']?.toString() != description) {
        debugPrint(
          'Description mismatch - Database: ${item["description"]}, Expected: $description',
        );
        valid = false;
      }

      if (location != null && item['location']?.toString() != location) {
        debugPrint(
          'Location mismatch - Database: ${item["location"]}, Expected: $location',
        );
        valid = false;
      }

      debugPrint('Gallery item validation result: $valid');
      return valid;
    } catch (e) {
      debugPrint('Error validating gallery item data: $e');
      return false;
    }
  }
}
