import 'package:flutter/material.dart' show debugPrint;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tatvan_kepenk/utils/file_utils.dart';
import 'package:uuid/uuid.dart';

/// Enhanced version of ImageUploadHelper with better error handling
class ImprovedImageUpload {
  final SupabaseClient client;
  final String bucketName;
  final Uuid _uuid = const Uuid();
  final ImagePicker _picker = ImagePicker();

  ImprovedImageUpload({required this.client, this.bucketName = 'galery'});

  /// Uploads an image file to Supabase storage with improved error handling and retries
  Future<String> uploadImage(dynamic imageFile) async {
    debugPrint('Uploading image of type: ${imageFile.runtimeType}');

    try {
      // Import platform-specific file utilities
      final bytes = await readFileAsBytes(imageFile);

      // Generate unique file name with extension
      final fileExt = getFileExtension(imageFile);
      final fileName = '${_uuid.v4()}.$fileExt';
      final filePath = fileName; // Store directly in bucket root

      debugPrint(
        'Uploading image with extension: $fileExt and filename: $fileName to bucket: $bucketName',
      );

      // Check if file is too large (limit to 5MB)
      if (bytes.length > 5 * 1024 * 1024) {
        throw Exception('Dosya boyutu çok büyük (maksimum 5MB)');
      }

      // Attempt upload with retry
      int retryCount = 0;
      const maxRetries = 2;
      Exception? lastError;

      while (retryCount <= maxRetries) {
        try {
          await client.storage
              .from(bucketName)
              .uploadBinary(
                filePath,
                bytes,
                fileOptions: const FileOptions(
                  cacheControl: '3600',
                  upsert: true,
                ),
              );

          final imageUrl = client.storage
              .from(bucketName)
              .getPublicUrl(filePath);
          debugPrint('Image uploaded successfully. URL: $imageUrl');
          return imageUrl;
        } catch (e) {
          lastError = Exception('$e');
          retryCount++;
          debugPrint('Upload attempt $retryCount failed: $e');

          if (retryCount <= maxRetries) {
            // Wait briefly before retrying
            await Future.delayed(Duration(seconds: 1));
          }
        }
      }

      // If we got here, all retries failed
      throw lastError ?? Exception('Tüm yükleme denemeleri başarısız oldu');
    } catch (e) {
      debugPrint('Error uploading image to Supabase: $e');
      debugPrint('Error stack trace: ${StackTrace.current}');
      throw Exception('Resim yükleme başarısız oldu: $e');
    }
  }

  /// Handles the image pick and upload process from start to finish with better error handling
  Future<String?> pickAndUploadImage() async {
    try {
      // Pick image with quality options
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (pickedImage == null) {
        debugPrint('Image picking cancelled');
        return null;
      }

      // Upload to Supabase
      return await uploadImage(pickedImage);
    } catch (e) {
      debugPrint('Error picking or uploading image: $e');
      throw Exception('Resim seçme veya yükleme işlemi başarısız oldu: $e');
    }
  }

  /// Delete an image from Supabase storage using its URL
  Future<bool> deleteImageFromUrl(String imageUrl) async {
    try {
      // Extract the path from the URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // For the new structure, the filename is the last segment
      if (pathSegments.isEmpty) {
        debugPrint('Invalid image URL format: $imageUrl');
        return false;
      }

      final storagePath = pathSegments.isNotEmpty ? pathSegments.last : '';

      await client.storage.from(bucketName).remove([storagePath]);
      debugPrint('Image successfully deleted from storage: $storagePath');
      return true;
    } catch (e) {
      debugPrint('Error deleting image from storage: $e');
      return false;
    }
  }
}
