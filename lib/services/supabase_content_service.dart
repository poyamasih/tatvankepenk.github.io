// filepath: c:\flutter procekts\tatvan_kepenk\lib\services\supabase_content_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tatvan_kepenk/services/supabase_service.dart';
import 'package:tatvan_kepenk/models/drawer_settings.dart';

class SupabaseContentService {
  final SupabaseService _supabaseService;
  final SharedPreferences _prefs;

  // Cache keys for local storage
  static const String _homeTitleKey = 'home_title';
  static const String _homeDescKey = 'home_description';
  static const String _kepenkTitleKey = 'kepenk_title';
  static const String _kepenkDescKey = 'kepenk_description';
  static const String _galleryItemsKey = 'gallery_items';
  static const String _kapilarTitleKey = 'kapilar_title';
  static const String _kapilarDescKey = 'kapilar_description';
  static const String _aboutPrefix = 'about';
  static const String _contactInfoKey = 'contact_info';
  static const String _contactFormsKey = 'contact_forms';

  SupabaseContentService(this._supabaseService, this._prefs);
  // Helper method to sync local and remote data with parallel tasks for better performance
  Future<void> syncAllData() async {
    try {
      // اجرای همزمان چندین عملیات همگام‌سازی برای سرعت بیشتر
      await Future.wait([
        _syncHomeContent().catchError((e) {
          debugPrint('Home content sync error: $e');
          return;
        }),
        _syncKepenkContent().catchError((e) {
          debugPrint('Kepenk content sync error: $e');
          return;
        }),
        _syncKapilarContent().catchError((e) {
          debugPrint('Kapilar content sync error: $e');
          return;
        }),
        _syncAboutContent().catchError((e) {
          debugPrint('About content sync error: $e');
          return;
        }),
        _syncContactInfo().catchError((e) {
          debugPrint('Contact info sync error: $e');
          return;
        }),
        _syncGalleryItems().catchError((e) {
          debugPrint('Gallery items sync error: $e');
          return;
        }),
        _syncContactForms().catchError((e) {
          debugPrint('Contact forms sync error: $e');
          return;
        }),
      ], eagerError: false);
    } catch (e) {
      debugPrint('Data synchronization error: $e');
      // استفاده از داده‌های محلی در صورت خطا
    }
  }

  // Home Content Methods
  Future<void> _syncHomeContent() async {
    try {
      final remoteData = await _supabaseService.getHomeContent();
      if (remoteData != null) {
        await _prefs.setString(_homeTitleKey, remoteData['title'] ?? '');
        await _prefs.setString(_homeDescKey, remoteData['description'] ?? '');
      }
    } catch (e) {
      debugPrint('Error syncing home content: $e');
    }
  }

  String getHomeTitle() => _prefs.getString(_homeTitleKey) ?? '';

  Future<void> saveHomeTitle(String title) async {
    await _prefs.setString(_homeTitleKey, title);
    await _supabaseService.saveHomeContent(
      title: title,
      description: getHomeDescription(),
    );
  }

  String getHomeDescription() => _prefs.getString(_homeDescKey) ?? '';

  Future<void> saveHomeDescription(String desc) async {
    await _prefs.setString(_homeDescKey, desc);
    await _supabaseService.saveHomeContent(
      title: getHomeTitle(),
      description: desc,
    );
  }

  // Kepenk Sistemleri Methods
  Future<void> _syncKepenkContent() async {
    try {
      final remoteData = await _supabaseService.getKepenkContent();
      if (remoteData != null) {
        await _prefs.setString(_kepenkTitleKey, remoteData['title'] ?? '');
        await _prefs.setString(_kepenkDescKey, remoteData['description'] ?? '');
      }
    } catch (e) {
      debugPrint('Error syncing kepenk content: $e');
    }
  }

  String getKepenkTitle() => _prefs.getString(_kepenkTitleKey) ?? '';

  Future<void> saveKepenkTitle(String title) async {
    await _prefs.setString(_kepenkTitleKey, title);
    await _supabaseService.saveKepenkContent(
      title: title,
      description: getKepenkDescription(),
    );
  }

  String getKepenkDescription() => _prefs.getString(_kepenkDescKey) ?? '';

  Future<void> saveKepenkDescription(String desc) async {
    await _prefs.setString(_kepenkDescKey, desc);
    await _supabaseService.saveKepenkContent(
      title: getKepenkTitle(),
      description: desc,
    );
  }

  // Gallery Methods
  Future<void> _syncGalleryItems() async {
    try {
      final remoteItems = await _supabaseService.getGalleryItems();

      // Ensure all items have consistent field values
      for (var item in remoteItems) {
        // Make sure both image_url and image_path fields exist and are consistent
        if (item['image_url'] == null && item['image_path'] != null) {
          item['image_url'] = item['image_path'];
        } else if (item['image_path'] == null && item['image_url'] != null) {
          item['image_path'] = item['image_url'];
        }

        // Make sure text fields are strings, not null
        item['title'] = item['title']?.toString() ?? '';
        item['description'] = item['description']?.toString() ?? '';
        item['location'] = item['location']?.toString() ?? '';
      }

      // Save the processed items to local storage
      await _prefs.setString(_galleryItemsKey, jsonEncode(remoteItems));
      debugPrint(
        'Gallery items synced successfully: ${remoteItems.length} items',
      );
    } catch (e) {
      debugPrint('Error syncing gallery items: $e');
      rethrow;
    }
  }

  List<Map<String, dynamic>> getGalleryItems() {
    final String? storedItems = _prefs.getString(_galleryItemsKey);
    if (storedItems == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(storedItems));
  }

  Future<void> saveGalleryItems(List<Map<String, dynamic>> items) async {
    try {
      // Normalize text fields first to ensure they're not null
      for (var item in items) {
        item['title'] = item['title']?.toString() ?? '';
        item['description'] = item['description']?.toString() ?? '';
        item['location'] = item['location']?.toString() ?? '';
      }

      // Save items to local storage first
      await _prefs.setString(_galleryItemsKey, jsonEncode(items));

      // Process each item for syncing with Supabase
      for (var item in items) {
        // Check if this is a new item (no database ID)
        if (item['id'] == null) {
          // New item - check if it has a local file path that needs to be uploaded
          final String? imagePath = item['image_path']?.toString();

          if (imagePath != null &&
              imagePath.isNotEmpty &&
              !imagePath.startsWith('http')) {
            // This is a local file path - upload it to Supabase
            try {
              final imageUrl = await _supabaseService.uploadImage(
                File(imagePath),
              );

              // Save the item with the uploaded image URL
              await _supabaseService.saveGalleryItem(
                date: item['date']?.toString() ?? '',
                title: item['title']?.toString() ?? '',
                description: item['description']?.toString() ?? '',
                location: item['location']?.toString() ?? '',
                imageUrl: imageUrl,
              );
            } catch (e) {
              debugPrint('Error uploading new gallery item image: $e');
              // Continue with other items even if this one fails
            }
          }
        } else {
          // Existing item - update it
          try {
            await _supabaseService.updateGalleryItem(
              id: item['id'].toString(),
              title: item['title']?.toString() ?? '',
              description: item['description']?.toString() ?? '',
              location: item['location']?.toString() ?? '',
              imageUrl: null, // Don't update the image URL
            );
            debugPrint(
              'Updated gallery item ${item['id']} with title: ${item['title']}, location: ${item['location']}',
            );
          } catch (e) {
            debugPrint('Error updating gallery item: $e');
            // Continue with other items even if this one fails
          }
        }
      }

      // Re-sync to get the latest data including new IDs from the server
      await _syncGalleryItems();
    } catch (e) {
      debugPrint('Error saving gallery items: $e');
      // Even if there's an error, we still want to re-sync to ensure consistency
      try {
        await _syncGalleryItems();
      } catch (_) {
        // Ignore errors during re-sync
      }
      rethrow; // Propagate the original error
    }
  }

  // Kapilar Methods
  Future<void> _syncKapilarContent() async {
    try {
      final remoteData = await _supabaseService.getKapilarContent();
      if (remoteData != null) {
        await _prefs.setString(_kapilarTitleKey, remoteData['title'] ?? '');
        await _prefs.setString(
          _kapilarDescKey,
          remoteData['description'] ?? '',
        );
      }
    } catch (e) {
      debugPrint('Error syncing kapilar content: $e');
    }
  }

  String getKapilarTitle() => _prefs.getString(_kapilarTitleKey) ?? '';

  Future<void> saveKapilarTitle(String title) async {
    await _prefs.setString(_kapilarTitleKey, title);
    await _supabaseService.saveKapilarContent(
      title: title,
      description: getKapilarDescription(),
    );
  }

  String getKapilarDescription() => _prefs.getString(_kapilarDescKey) ?? '';

  Future<void> saveKapilarDescription(String desc) async {
    await _prefs.setString(_kapilarDescKey, desc);
    await _supabaseService.saveKapilarContent(
      title: getKapilarTitle(),
      description: desc,
    );
  }

  // About Methods
  Future<void> _syncAboutContent() async {
    try {
      for (int i = 1; i <= 3; i++) {
        final remoteData = await _supabaseService.getAboutSection(i);
        if (remoteData != null) {
          await _prefs.setString(
            '${_aboutPrefix}_${i}_title',
            remoteData['title'] ?? '',
          );
          await _prefs.setString(
            '${_aboutPrefix}_${i}_desc',
            remoteData['description'] ?? '',
          );
        }
      }
    } catch (e) {
      debugPrint('Error syncing about content: $e');
    }
  }

  String getAboutTitle(int index) =>
      _prefs.getString('${_aboutPrefix}_${index}_title') ?? '';

  String getAboutDescription(int index) =>
      _prefs.getString('${_aboutPrefix}_${index}_desc') ?? '';

  Future<void> saveAboutContent(
    String section,
    String title,
    String desc,
  ) async {
    final sectionId = int.tryParse(section) ?? 1;
    await _prefs.setString('${_aboutPrefix}_${section}_title', title);
    await _prefs.setString('${_aboutPrefix}_${section}_desc', desc);
    await _supabaseService.saveAboutContent(
      sectionId: sectionId,
      title: title,
      description: desc,
    );
  }

  // Contact Methods
  Future<void> _syncContactInfo() async {
    try {
      final remoteData = await _supabaseService.getContactInfo();
      if (remoteData != null) {
        final contactInfo = {
          'address': remoteData['address'] ?? '',
          'phone': remoteData['phone'] ?? '',
          'email': remoteData['email'] ?? '',
          'workHours': remoteData['work_hours'] ?? '',
        };
        await _prefs.setString(_contactInfoKey, jsonEncode(contactInfo));
      }
    } catch (e) {
      debugPrint('Error syncing contact info: $e');
    }
  }

  String getContactInfo(String key) {
    final String? storedInfo = _prefs.getString(_contactInfoKey);
    if (storedInfo == null) return '';
    final Map<String, dynamic> info = jsonDecode(storedInfo);
    return info[key]?.toString() ?? '';
  }

  Future<void> saveContactInfo(Map<String, String> info) async {
    await _prefs.setString(_contactInfoKey, jsonEncode(info));

    await _supabaseService.saveContactInfo(
      address: info['address'] ?? '',
      phone: info['phone'] ?? '',
      email: info['email'] ?? '',
      workHours: info['workHours'] ?? '',
    );
  }

  // Contact Forms Methods
  Future<void> _syncContactForms() async {
    try {
      final remoteForms = await _supabaseService.getContactForms();
      await _prefs.setString(_contactFormsKey, jsonEncode(remoteForms));
    } catch (e) {
      debugPrint('Error syncing contact forms: $e');
    }
  }

  List<Map<String, dynamic>> getContactForms() {
    final String? storedForms = _prefs.getString(_contactFormsKey);
    if (storedForms == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(storedForms));
  }

  Future<void> saveContactForms(List<Map<String, dynamic>> forms) async {
    await _prefs.setString(_contactFormsKey, jsonEncode(forms));
    // Note: We don't push this to Supabase since contact forms
    // should only be submitted by users, not edited in admin panel
  }

  Future<void> submitContactForm({
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    await _supabaseService.submitContactForm(
      name: name,
      email: email,
      phone: phone,
      message: message,
    );

    await _syncContactForms(); // Refresh local data after submission
  }

  Future<void> deleteContactForm(String id) async {
    await _supabaseService.deleteContactForm(id);
    await _syncContactForms(); // Refresh local data after deletion
  }

  // Method to get drawer settings
  DrawerSettings? getDrawerSettings() {
    try {
      final String? cachedSettings = _prefs.getString('drawer_settings');
      if (cachedSettings != null) {
        return DrawerSettings.fromJson(jsonDecode(cachedSettings));
      }
    } catch (e) {
      debugPrint('Error retrieving drawer settings: $e');
    }
    return null;
  }
}
