import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tatvan_kepenk/services/auth_service.dart';
import 'package:tatvan_kepenk/utils/file_adapter.dart';
import 'package:tatvan_kepenk/utils/image_helper.dart';
import 'package:tatvan_kepenk/services/supabase_content_service.dart';
import 'package:tatvan_kepenk/services/supabase_service.dart';
import 'package:tatvan_kepenk/utils/db_schema_fix.dart';
import 'package:tatvan_kepenk/utils/gallery_field_sync.dart';
import 'package:tatvan_kepenk/pages/admin/gallery_management.dart';
import 'dart:async';

class AdminPanelSupabase extends StatefulWidget {
  const AdminPanelSupabase({super.key});

  @override
  State<AdminPanelSupabase> createState() => _AdminPanelSupabaseState();
}

class _AdminPanelSupabaseState extends State<AdminPanelSupabase>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AuthService _authService;
  late SupabaseContentService _contentService;
  late SupabaseService _supabaseService;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isSyncing = false;

  // Session timeout handling
  Timer? _sessionTimer;
  bool _showingTimeoutWarning = false;
  int _inactivitySeconds = 0;
  static const int _sessionTimeoutSeconds = 1800; // 30 minutes
  static const int _warningThresholdSeconds =
      1680; // 28 minutes - show warning 2 minutes before timeout

  // Ana Sayfa controllers
  final _homeTitleController = TextEditingController();
  final _homeDescriptionController = TextEditingController();

  // Kepenk Sistemleri controllers
  final _kepenkTitleController = TextEditingController();
  final _kepenkDescriptionController = TextEditingController();
  List<Map<String, dynamic>> galleryItems = [];

  // Gallery item text controllers - maintain across builds
  final Map<String, Map<String, TextEditingController>> _galleryControllers =
      {};

  // Endüstriyel Kapılar controllers
  final _kapilarTitleController = TextEditingController();
  final _kapilarDescriptionController = TextEditingController();

  // Hakkımızda controllers
  final _about1TitleController = TextEditingController();
  final _about1DescController = TextEditingController();
  final _about2TitleController = TextEditingController();
  final _about2DescController = TextEditingController();
  final _about3TitleController = TextEditingController();
  final _about3DescController = TextEditingController();

  // İletişim controllers
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _workHoursController = TextEditingController();
  List<Map<String, dynamic>> contactForms = [];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeServices();
    _startSessionTracking();
  }

  // Start tracking the session for timeout
  void _startSessionTracking() {
    // Cancel any existing timer
    _sessionTimer?.cancel();

    // Reset inactivity counter
    _inactivitySeconds = 0;

    // Start a new timer that checks every second
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _inactivitySeconds++;

        // Show warning when approaching timeout
        if (_inactivitySeconds >= _warningThresholdSeconds &&
            !_showingTimeoutWarning) {
          _showTimeoutWarning();
        }

        // Auto-logout when session times out
        if (_inactivitySeconds >= _sessionTimeoutSeconds) {
          _handleSessionTimeout();
        }
      });
    });
  }

  // Reset session timer on user activity
  void _resetSessionTimer() {
    _inactivitySeconds = 0;
    _showingTimeoutWarning = false;

    // Also update last activity in AuthService
    _authService.updateActivity();
  }

  // Show warning dialog when approaching session timeout
  void _showTimeoutWarning() {
    _showingTimeoutWarning = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Oturum Zaman Aşımı Uyarısı'),
          content: const Text(
            'Oturumunuz 2 dakika içinde sona erecektir. Devam etmek istiyor musunuz?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetSessionTimer();
              },
              child: const Text('Devam Et'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleSessionTimeout();
              },
              child: const Text('Oturumu Kapat'),
            ),
          ],
        );
      },
    );
  }

  // Handle session timeout by logging out
  void _handleSessionTimeout() {
    _sessionTimer?.cancel();
    _authService.logout();
    Get.offAllNamed('/admin/login');
  }

  Future<void> _initializeServices() async {
    try {
      _authService = Get.find<AuthService>();
      _contentService = Get.find<SupabaseContentService>();
      _supabaseService = Get.find<SupabaseService>();

      if (!_authService.isLoggedIn()) {
        Get.offAllNamed('/admin/login');
        return;
      }

      await _loadContent();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Servisler başlatılırken hata: $e')),
      );
    }
  }

  Future<void> _syncFromSupabase() async {
    setState(() => _isSyncing = true);
    try {
      await _contentService.syncAllData();
      await _loadContent();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supabase\'den içerik senkronize edildi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Senkronizasyon hatası: $e')));
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  Future<void> _loadContent() async {
    setState(() => _isLoading = true);
    try {
      // Load Ana Sayfa content
      _homeTitleController.text = _contentService.getHomeTitle();
      _homeDescriptionController.text = _contentService.getHomeDescription();

      // Load Kepenk Sistemleri content
      _kepenkTitleController.text = _contentService.getKepenkTitle();
      _kepenkDescriptionController.text =
          _contentService.getKepenkDescription();
      galleryItems = _contentService.getGalleryItems();

      // Initialize controllers for gallery items
      _initGalleryControllers();

      // Load Endüstriyel Kapılar content
      _kapilarTitleController.text = _contentService.getKapilarTitle();
      _kapilarDescriptionController.text =
          _contentService.getKapilarDescription();

      // Load Hakkımızda content
      _about1TitleController.text = _contentService.getAboutTitle(1);
      _about1DescController.text = _contentService.getAboutDescription(1);
      _about2TitleController.text = _contentService.getAboutTitle(2);
      _about2DescController.text = _contentService.getAboutDescription(2);
      _about3TitleController.text = _contentService.getAboutTitle(3);
      _about3DescController.text = _contentService.getAboutDescription(3);

      // Load İletişim content
      _addressController.text = _contentService.getContactInfo('address');
      _phoneController.text = _contentService.getContactInfo('phone');
      _emailController.text = _contentService.getContactInfo('email');
      _workHoursController.text = _contentService.getContactInfo('workHours');
      contactForms = _contentService.getContactForms();
    } catch (e) {
      print('Error loading content: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İçerik yüklenirken bir hata oluştu')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Initialize text controllers for gallery items
  void _initGalleryControllers() {
    // Clear old controllers first
    for (final controllers in _galleryControllers.values) {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    }
    _galleryControllers.clear();

    // Create new controllers
    for (final item in galleryItems) {
      final itemId =
          item['id']?.toString() ??
          'temp_${DateTime.now().millisecondsSinceEpoch}';

      if (!_galleryControllers.containsKey(itemId)) {
        _galleryControllers[itemId] = {
          'title': TextEditingController(text: item['title']?.toString() ?? ''),
          'description': TextEditingController(
            text: item['description']?.toString() ?? '',
          ),
          'location': TextEditingController(
            text: item['location']?.toString() ?? '',
          ),
        };

        // Add listeners to update the data model when text changes
        _galleryControllers[itemId]!['title']!.addListener(() {
          final index = galleryItems.indexWhere(
            (element) =>
                element['id']?.toString() == itemId ||
                (!element.containsKey('id') && itemId.startsWith('temp_')),
          );

          if (index != -1) {
            galleryItems[index]['title'] =
                _galleryControllers[itemId]!['title']!.text;
          }
        });

        _galleryControllers[itemId]!['description']!.addListener(() {
          final index = galleryItems.indexWhere(
            (element) =>
                element['id']?.toString() == itemId ||
                (!element.containsKey('id') && itemId.startsWith('temp_')),
          );

          if (index != -1) {
            galleryItems[index]['description'] =
                _galleryControllers[itemId]!['description']!.text;
          }
        });

        _galleryControllers[itemId]!['location']!.addListener(() {
          final index = galleryItems.indexWhere(
            (element) =>
                element['id']?.toString() == itemId ||
                (!element.containsKey('id') && itemId.startsWith('temp_')),
          );

          if (index != -1) {
            galleryItems[index]['location'] =
                _galleryControllers[itemId]!['location']!.text;
          }
        });
      }
    }
  }

  // Helper to get the appropriate controller for a gallery item field
  TextEditingController _getControllerForItem(
    Map<String, dynamic> item,
    String field,
  ) {
    final itemId =
        item['id']?.toString() ??
        'temp_${DateTime.now().millisecondsSinceEpoch}';

    // If we don't have controllers for this item yet, create them
    if (!_galleryControllers.containsKey(itemId)) {
      _galleryControllers[itemId] = {
        'title': TextEditingController(text: item['title']?.toString() ?? ''),
        'description': TextEditingController(
          text: item['description']?.toString() ?? '',
        ),
        'location': TextEditingController(
          text: item['location']?.toString() ?? '',
        ),
      };

      // Set up listeners for each controller
      final index = galleryItems.indexWhere(
        (element) => element['id']?.toString() == itemId,
      );
      if (index != -1) {
        _galleryControllers[itemId]!['title']!.addListener(() {
          galleryItems[index]['title'] =
              _galleryControllers[itemId]!['title']!.text;
        });

        _galleryControllers[itemId]!['description']!.addListener(() {
          galleryItems[index]['description'] =
              _galleryControllers[itemId]!['description']!.text;
        });

        _galleryControllers[itemId]!['location']!.addListener(() {
          galleryItems[index]['location'] =
              _galleryControllers[itemId]!['location']!.text;
        });
      }
    }

    return _galleryControllers[itemId]![field]!;
  }

  Future<void> _addImage() async {
    bool imageAdded = false;
    try {
      // First, try to fix the database schema if needed
      try {
        // Create stored procedures if they don't exist
        await DbSchemaFix.createStoredProcedures();

        // Fix schema issues
        final schemaResult = await DbSchemaFix.fixGalleryItemsSchema(
          context: context,
          showProgress: true,
        );

        if (!schemaResult['success']) {
          // If schema fix failed, show an error but continue anyway
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Veritabanı şeması düzeltilemedi: ${schemaResult['message']}',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (schemaError) {
        debugPrint('Schema fix error: $schemaError');
        // Continue anyway - we'll see if the operation works
      }

      // Show a progress indicator during image upload
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
                Text('Resim yükleniyor...'),
              ],
            ),
          );
        },
      );
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // Upload to Supabase Storage - pass XFile directly
        final imageUrl = await _supabaseService.uploadImage(image);

        // Create new gallery item with both field names for compatibility
        final newItem = {
          'image': image.path, // Local path for displaying in the admin panel
          'image_url': imageUrl, // Supabase storage URL
          'image_path': imageUrl, // Adding image_path for compatibility
          'title': '',
          'description': '',
          'date': DateTime.now().toIso8601String(),
          'location': '',
        };

        setState(() {
          galleryItems.add(newItem);
        });

        // Save the updated gallery items
        await _contentService.saveGalleryItems(galleryItems);
        imageAdded = true;
      }
    } catch (e) {
      print('Error adding image: $e');
      imageAdded = false;
    } finally {
      // Close the loading dialog
      Navigator.of(context).pop();

      // Show success or error message
      if (imageAdded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resim başarıyla eklendi'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Resim eklenirken bir hata oluştu veya işlem iptal edildi',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      // Save Ana Sayfa content
      await _contentService.saveHomeTitle(_homeTitleController.text);
      await _contentService.saveHomeDescription(
        _homeDescriptionController.text,
      );

      // Save Kepenk Sistemleri content
      await _contentService.saveKepenkTitle(_kepenkTitleController.text);
      await _contentService.saveKepenkDescription(
        _kepenkDescriptionController.text,
      );
      await _contentService.saveGalleryItems(galleryItems);

      // Save Endüstriyel Kapılar content
      await _contentService.saveKapilarTitle(_kapilarTitleController.text);
      await _contentService.saveKapilarDescription(
        _kapilarDescriptionController.text,
      );

      // Save Hakkımızda content
      await _contentService.saveAboutContent(
        '1',
        _about1TitleController.text,
        _about1DescController.text,
      );
      await _contentService.saveAboutContent(
        '2',
        _about2TitleController.text,
        _about2DescController.text,
      );
      await _contentService.saveAboutContent(
        '3',
        _about3TitleController.text,
        _about3DescController.text,
      );

      // Save İletişim content
      await _contentService.saveContactInfo({
        'address': _addressController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'workHours': _workHoursController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Değişiklikler Supabase\'e kaydedildi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Değişiklikleri kaydederken hata: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    Get.offAllNamed('/');
  }

  Future<void> _repairGallery() async {
    try {
      final result = await GalleryFieldSync.syncImageFields(
        context: context,
        showProgress: true,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Veri tabanı alanları senkronize edildi.\n'
            'Güncellenen: ${result['updated']}, '
            'Başarısız: ${result['failed']}',
          ),
          backgroundColor: result['failed'] > 0 ? Colors.orange : Colors.green,
        ),
      );

      // Refresh the gallery items
      await _loadContent();
    } catch (e) {
      print('Error repairing gallery: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Galeri tamiri başarısız: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openGalleryManagement() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const GalleryManagementPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _resetSessionTimer(),
      onPointerMove: (_) => _resetSessionTimer(),
      onPointerUp: (_) => _resetSessionTimer(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Yönetim Paneli (Supabase)'),
          backgroundColor: Colors.black.withOpacity(0.5),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Ana Sayfa'),
              Tab(text: 'Kepenk Sistemleri'),
              Tab(text: 'Endüstriyel Kapılar'),
              Tab(text: 'Hakkımızda'),
              Tab(text: 'İletişim'),
            ],
          ),
          actions: [
            _isSyncing
                ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
                : IconButton(
                  onPressed: _syncFromSupabase,
                  icon: const Icon(Icons.sync),
                  tooltip: 'Supabase\'den senkronize et',
                ),
            TextButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Çıkış', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAnaSayfaTab(),
            _buildKepenkSistemleriTab(),
            _buildKapilarTab(),
            _buildHakkimizdaTab(),
            _buildIletisimTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _saveChanges,
          child:
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.save),
        ),
      ),
    );
  }

  Widget _buildAnaSayfaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ana Sayfa İçeriği',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _homeTitleController,
            decoration: const InputDecoration(
              labelText: 'Başlık',
              border: OutlineInputBorder(),
            ),
            maxLength: 100,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _homeDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Açıklama',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            maxLength: 500,
          ),
        ],
      ),
    );
  }

  Widget _buildKepenkSistemleriTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kepenk Sistemleri',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _kepenkTitleController,
            decoration: const InputDecoration(
              labelText: 'Başlık',
              border: OutlineInputBorder(),
            ),
            maxLength: 100,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _kepenkDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Açıklama',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            maxLength: 500,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Galeri',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _repairGallery,
                    icon: const Icon(Icons.build_circle),
                    label: const Text('Galeri Tamiri'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _openGalleryManagement,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeri Yönetimi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _addImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Resim Ekle'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Display gallery items with error handling
          galleryItems.isEmpty
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Galeri boş. Resim eklemek için "Resim Ekle" butonunu kullanın.',
                  ),
                ),
              )
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: galleryItems.length,
                itemBuilder: (context, index) {
                  final item = galleryItems[index];
                  // No need to check if item is null in null-safe Dart, but ensure fields are accessed safely                  // Determine image source (local file or remote URL)
                  final String localImagePath = item['image']?.toString() ?? '';
                  final bool fileExists =
                      localImagePath.isNotEmpty &&
                      !localImagePath.startsWith('http') &&
                      FileAdapter.exists(localImagePath);

                  bool isLocal = localImagePath.isNotEmpty && fileExists;

                  // Get the correct image URL - check both fields for compatibility
                  final imageUrl =
                      item['image_url']?.toString() ??
                      item['image_path']?.toString() ??
                      '';

                  Widget imageWidget;

                  if (isLocal) {
                    // For newly added images that haven't been uploaded yet
                    imageWidget = Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: ImageHelper.buildImage(
                        localImagePath,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(8),
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading local image: $error');
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    );
                  } else if (imageUrl.isNotEmpty) {
                    // For images already in Supabase
                    try {
                      imageWidget = Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[100],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image from URL: $error');
                              return Container(
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Resim yüklenemedi',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    } catch (e) {
                      debugPrint('Error creating network image widget: $e');
                      imageWidget = Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                          color: Colors.grey[200],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(height: 4),
                            Text(
                              'Görüntü hatası',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    // No image available
                    imageWidget = Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    );
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              imageWidget,
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        // Create a controller that persists during build cycles
                                        final controller =
                                            TextEditingController(
                                              text:
                                                  item['title']?.toString() ??
                                                  '',
                                            );

                                        // Update the value from the model
                                        controller.text =
                                            item['title']?.toString() ?? '';

                                        return TextField(
                                          decoration: const InputDecoration(
                                            labelText: 'Başlık',
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              galleryItems[index]['title'] =
                                                  value;
                                            });
                                          },
                                          controller: controller,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    Builder(
                                      builder: (context) {
                                        // Create a controller that persists during build cycles
                                        final controller =
                                            TextEditingController(
                                              text:
                                                  item['location']
                                                      ?.toString() ??
                                                  '',
                                            );

                                        // Update the value from the model
                                        controller.text =
                                            item['location']?.toString() ?? '';

                                        return TextField(
                                          decoration: const InputDecoration(
                                            labelText: 'Konum',
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              galleryItems[index]['location'] =
                                                  value;
                                            });
                                          },
                                          controller: controller,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Builder(
                            builder: (context) {
                              // Create a controller that persists during build cycles
                              final controller = TextEditingController(
                                text: item['description']?.toString() ?? '',
                              );

                              // Update the value from the model
                              controller.text =
                                  item['description']?.toString() ?? '';

                              return TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Açıklama',
                                  border: OutlineInputBorder(),
                                  hintText:
                                      'Bu resim hakkında kısa bir açıklama yazın',
                                ),
                                maxLines: 3,
                                onChanged: (value) {
                                  setState(() {
                                    galleryItems[index]['description'] = value;
                                  });
                                },
                                controller: controller,
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Tarih: ${item['date'] != null ? DateTime.parse(item['date'].toString()).toString().substring(0, 16) : 'N/A'}',
                                    ),
                                    const SizedBox(width: 16),
                                    // Add a preview button
                                    if (imageUrl.isNotEmpty)
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    AppBar(
                                                      title: Text(
                                                        item['title']
                                                                ?.toString() ??
                                                            'Resim Önizleme',
                                                      ),
                                                      leading: IconButton(
                                                        icon: const Icon(
                                                          Icons.close,
                                                        ),
                                                        onPressed:
                                                            () =>
                                                                Navigator.of(
                                                                  context,
                                                                ).pop(),
                                                      ),
                                                      actions: [
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.open_in_new,
                                                          ),
                                                          tooltip:
                                                              'Yeni sekmede aç',
                                                          onPressed: () {
                                                            Navigator.of(
                                                              context,
                                                            ).pop();
                                                            // Open in a new tab or window (could be implemented with url_launcher)
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                  'Bu özellik henüz mevcut değil',
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            16.0,
                                                          ),
                                                      child: Image.network(
                                                        imageUrl,
                                                        fit: BoxFit.contain,
                                                        loadingBuilder: (
                                                          context,
                                                          child,
                                                          loadingProgress,
                                                        ) {
                                                          if (loadingProgress ==
                                                              null)
                                                            return child;
                                                          return Center(
                                                            child: CircularProgressIndicator(
                                                              value:
                                                                  loadingProgress
                                                                              .expectedTotalBytes !=
                                                                          null
                                                                      ? loadingProgress
                                                                              .cumulativeBytesLoaded /
                                                                          loadingProgress
                                                                              .expectedTotalBytes!
                                                                      : null,
                                                            ),
                                                          );
                                                        },
                                                        errorBuilder: (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .broken_image,
                                                                size: 64,
                                                              ),
                                                              Text(
                                                                'Resim yüklenemedi: $error',
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            16.0,
                                                          ),
                                                      child: Text(
                                                        item['description']
                                                                ?.toString() ??
                                                            'Açıklama mevcut değil',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        icon: const Icon(Icons.preview),
                                        label: const Text('Önizle'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        try {
                                          setState(() => _isLoading = true);

                                          // Update the item
                                          if (item['id'] != null) {
                                            // Make sure we have the latest values from the text fields
                                            final title =
                                                item['title']?.toString() ?? '';
                                            final description =
                                                item['description']
                                                    ?.toString() ??
                                                '';
                                            final location =
                                                item['location']?.toString() ??
                                                '';

                                            print(
                                              'Saving gallery item ${item['id']} with title: $title, description: $description, location: $location',
                                            );

                                            // Call the update method with the current values
                                            await _supabaseService
                                                .updateGalleryItem(
                                                  id: item['id'].toString(),
                                                  title: title,
                                                  description: description,
                                                  location: location,
                                                );

                                            // Force-update the gallery items list to ensure it has the latest values
                                            galleryItems[index]['title'] =
                                                title;
                                            galleryItems[index]['description'] =
                                                description;
                                            galleryItems[index]['location'] =
                                                location; // Also update local content storage
                                            await _contentService
                                                .saveGalleryItems(galleryItems);

                                            // Verify the data was correctly saved
                                            final isValid =
                                                await _supabaseService
                                                    .validateGalleryItemData(
                                                      id: item['id'].toString(),
                                                      title: title,
                                                      description: description,
                                                      location: location,
                                                    );

                                            if (!isValid) {
                                              print(
                                                'WARNING: Gallery item validation failed. Forcing a resync.',
                                              );
                                              // Re-sync from database to ensure everything is up to date
                                              await _contentService
                                                  .syncAllData();
                                            }

                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Değişiklikler kaydedildi',
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                          } else {
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Bu öğe henüz veritabanına kaydedilmedi. Lütfen önce tüm değişiklikleri kaydedin.',
                                                  ),
                                                  backgroundColor:
                                                      Colors.orange,
                                                ),
                                              );
                                            }
                                          }
                                        } catch (e) {
                                          print(
                                            'Error updating gallery item: $e',
                                          );
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Değişiklikler kaydedilirken hata oluştu: $e',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        } finally {
                                          if (mounted) {
                                            setState(() => _isLoading = false);
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.save),
                                      label: const Text('Kaydet'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: () async {
                                        // Show confirmation dialog
                                        final shouldDelete = await showDialog<
                                          bool
                                        >(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: const Text('Resmi Sil'),
                                                content: const Text(
                                                  'Bu resmi silmek istediğinize emin misiniz?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.of(
                                                          context,
                                                        ).pop(false),
                                                    child: const Text('İptal'),
                                                  ),
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.of(
                                                          context,
                                                        ).pop(true),
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.red,
                                                    ),
                                                    child: const Text('Sil'),
                                                  ),
                                                ],
                                              ),
                                        );

                                        if (shouldDelete == true) {
                                          try {
                                            setState(() => _isLoading = true);

                                            // If this item has an id, delete it from Supabase
                                            if (item['id'] != null) {
                                              // Get the image URL from either field
                                              final imageUrl =
                                                  item['image_url'] ??
                                                  item['image_path'];

                                              // Delete both the image and the database record
                                              if (imageUrl != null) {
                                                await _supabaseService
                                                    .deleteGalleryItem(
                                                      item['id'].toString(),
                                                      imageUrl.toString(),
                                                    );
                                              } else {
                                                // If no image URL, just delete the record
                                                await _supabaseService
                                                    .deleteGalleryItem(
                                                      item['id'].toString(),
                                                    );
                                              }
                                            }

                                            setState(() {
                                              galleryItems.removeAt(index);
                                            });

                                            // Update local storage
                                            await _contentService
                                                .saveGalleryItems(galleryItems);

                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Resim başarıyla silindi',
                                                  ),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            print(
                                              'Error deleting gallery item: $e',
                                            );
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Resim silinirken hata oluştu: $e',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          } finally {
                                            if (mounted) {
                                              setState(
                                                () => _isLoading = false,
                                              );
                                            }
                                          }
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      label: const Text(
                                        'Sil',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }

  Widget _buildKapilarTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Endüstriyel Kapılar',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _kapilarTitleController,
            decoration: const InputDecoration(
              labelText: 'Başlık',
              border: OutlineInputBorder(),
            ),
            maxLength: 100,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _kapilarDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Açıklama',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            maxLength: 500,
          ),
        ],
      ),
    );
  }

  Widget _buildHakkimizdaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hakkımızda',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildAboutSection(
            '1. Bölüm',
            _about1TitleController,
            _about1DescController,
          ),
          const SizedBox(height: 32),
          _buildAboutSection(
            '2. Bölüm',
            _about2TitleController,
            _about2DescController,
          ),
          const SizedBox(height: 32),
          _buildAboutSection(
            '3. Bölüm',
            _about3TitleController,
            _about3DescController,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(
    String title,
    TextEditingController titleController,
    TextEditingController descController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Başlık',
            border: OutlineInputBorder(),
          ),
          maxLength: 100,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: descController,
          decoration: const InputDecoration(
            labelText: 'Açıklama',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          maxLength: 300,
        ),
      ],
    );
  }

  Widget _buildIletisimTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'İletişim Bilgileri',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Adres',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Telefon',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'E-posta',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _workHoursController,
            decoration: const InputDecoration(
              labelText: 'Çalışma Saatleri',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'İletişim Formu Mesajları',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: contactForms.length,
            itemBuilder: (context, index) {
              final form = contactForms[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(form['name'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(form['email'] ?? ''),
                      Text(form['phone'] ?? ''),
                      Text(form['message'] ?? ''),
                      form['created_at'] != null
                          ? Text(
                            'Tarih: ${DateTime.parse(form['created_at']).toString().substring(0, 16)}',
                          )
                          : const Text('Tarih: N/A'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      try {
                        if (form['id'] != null) {
                          await _contentService.deleteContactForm(form['id']);
                        }
                        setState(() {
                          contactForms.removeAt(index);
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Silme hatası: $e')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _tabController.dispose();

    // Ana Sayfa controllers
    _homeTitleController.dispose();
    _homeDescriptionController.dispose();

    // Kepenk Sistemleri controllers
    _kepenkTitleController.dispose();
    _kepenkDescriptionController.dispose();

    // Endüstriyel Kapılar controllers
    _kapilarTitleController.dispose();
    _kapilarDescriptionController.dispose();

    // Hakkımızda controllers
    _about1TitleController.dispose();
    _about1DescController.dispose();
    _about2TitleController.dispose();
    _about2DescController.dispose();
    _about3TitleController.dispose();
    _about3DescController.dispose();

    // İletişim controllers
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _workHoursController.dispose();

    // Dispose all gallery item controllers
    for (final controllers in _galleryControllers.values) {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    }

    super.dispose();
  }
}
