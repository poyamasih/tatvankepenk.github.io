import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tatvan_kepenk/services/supabase_service.dart';
import 'package:tatvan_kepenk/services/supabase_content_service.dart';
import 'package:tatvan_kepenk/widgets/animated_background.dart';

class SupabaseContentView extends StatefulWidget {
  const SupabaseContentView({super.key});

  @override
  State<SupabaseContentView> createState() => _SupabaseContentViewState();
}

class _SupabaseContentViewState extends State<SupabaseContentView> {
  late final SupabaseService _supabaseService;
  late final SupabaseContentService _supabaseContentService;
  bool _isLoading = true;
  bool _isSyncing = false;
  Map<String, dynamic>? _homeContent;
  Map<String, dynamic>? _kepenkContent;
  Map<String, dynamic>? _kapilarContent;
  List<Map<String, dynamic>> _aboutSections = [];
  Map<String, dynamic>? _contactInfo;
  List<Map<String, dynamic>> _galleryItems = [];
  String _errorMessage = '';
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      _supabaseService = Get.find<SupabaseService>();
      _supabaseContentService = Get.find<SupabaseContentService>();
      _loadAllContent();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'خطا در راه‌اندازی سرویس‌ها: $e';
      });
      debugPrint('Error initializing services: $e');
    }
  }

  Future<void> _loadAllContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load Home Content
      try {
        _homeContent = await _supabaseService.getHomeContent();
      } catch (e) {
        debugPrint('Error loading home content: $e');
        _errorMessage += 'خطا در بارگذاری محتوای صفحه اصلی\n';
      }

      // Load Kepenk Content
      try {
        _kepenkContent = await _supabaseService.getKepenkContent();
      } catch (e) {
        debugPrint('Error loading kepenk content: $e');
        _errorMessage += 'خطا در بارگذاری محتوای کپنک سیستملری\n';
      }

      // Load Kapilar Content
      try {
        _kapilarContent = await _supabaseService.getKapilarContent();
      } catch (e) {
        debugPrint('Error loading kapilar content: $e');
        _errorMessage += 'خطا در بارگذاری محتوای درهای صنعتی\n';
      }

      // Load Gallery Items
      try {
        _galleryItems = await _supabaseService.getGalleryItems();
      } catch (e) {
        debugPrint('Error loading gallery items: $e');
        _errorMessage += 'خطا در بارگذاری تصاویر گالری\n';
        _galleryItems = [];
      }

      // Load About Sections
      try {
        _aboutSections = await _supabaseService.getAboutSections();
      } catch (e) {
        debugPrint('Error loading about sections: $e');
        _errorMessage += 'خطا در بارگذاری بخش‌های درباره ما\n';
        _aboutSections = [];
      }

      // Load Contact Info
      try {
        _contactInfo = await _supabaseService.getContactInfo();
      } catch (e) {
        debugPrint('Error loading contact info: $e');
        _errorMessage += 'خطا در بارگذاری اطلاعات تماس\n';
      }

      if (_errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('برخی از داده‌ها با خطا مواجه شدند: $_errorMessage'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      debugPrint('Critical error loading content from Supabase: $e');
      _errorMessage = 'خطا در اتصال به Supabase: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _syncContent() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      // Use the syncAllData method to sync all content at once
      await _supabaseContentService.syncAllData();

      // Reload all content after sync
      _loadAllContent();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('همگام‌سازی با موفقیت انجام شد')),
      );
    } catch (e) {
      debugPrint('Error syncing content to Supabase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در همگام‌سازی با Supabase: $e')),
      );
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نمایش محتوا از Supabase'),
        backgroundColor: Colors.black.withOpacity(0.5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: AnimatedBackground(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error message display
                      if (_errorMessage.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'خطا در بارگذاری',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _loadAllContent,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('تلاش مجدد'),
                              ),
                            ],
                          ),
                        ),
                      // Home Content Section
                      _buildSectionCard(
                        'محتوای صفحه اصلی',
                        _homeContent != null
                            ? [
                              _buildContentRow('عنوان', _homeContent!['title']),
                              _buildContentRow(
                                'توضیحات',
                                _homeContent!['description'],
                              ),
                            ]
                            : [_buildContentRow('وضعیت', 'داده‌ای یافت نشد')],
                      ),

                      const SizedBox(height: 20),

                      // Kepenk Content Section
                      _buildSectionCard(
                        'محتوای کپنک سیستملری',
                        _kepenkContent != null
                            ? [
                              _buildContentRow(
                                'عنوان',
                                _kepenkContent!['title'],
                              ),
                              _buildContentRow(
                                'توضیحات',
                                _kepenkContent!['description'],
                              ),
                            ]
                            : [_buildContentRow('وضعیت', 'داده‌ای یافت نشد')],
                      ),

                      const SizedBox(height: 20),

                      // Kapilar Content Section
                      _buildSectionCard(
                        'محتوای درهای صنعتی',
                        _kapilarContent != null
                            ? [
                              _buildContentRow(
                                'عنوان',
                                _kapilarContent!['title'],
                              ),
                              _buildContentRow(
                                'توضیحات',
                                _kapilarContent!['description'],
                              ),
                            ]
                            : [_buildContentRow('وضعیت', 'داده‌ای یافت نشد')],
                      ),

                      const SizedBox(height: 20),

                      // Gallery Items
                      _buildSectionCard(
                        'گالری تصاویر (${_galleryItems.length} مورد)',
                        _galleryItems.isNotEmpty
                            ? _galleryItems
                                .map((item) => _buildGalleryItem(item))
                                .toList()
                            : [
                              _buildContentRow(
                                'وضعیت',
                                'تصویری در گالری یافت نشد',
                              ),
                            ],
                      ),

                      const SizedBox(height: 20),

                      // About Sections
                      _buildSectionCard(
                        'بخش‌های درباره ما',
                        _aboutSections.isNotEmpty
                            ? _aboutSections.map((section) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'بخش ${section['section_number']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  _buildContentRow('عنوان', section['title']),
                                  _buildContentRow(
                                    'توضیحات',
                                    section['description'],
                                  ),
                                  const Divider(color: Colors.white30),
                                ],
                              );
                            }).toList()
                            : [
                              _buildContentRow(
                                'وضعیت',
                                'اطلاعات بخش درباره ما یافت نشد',
                              ),
                            ],
                      ),

                      const SizedBox(height: 20),

                      // Contact Info
                      _buildSectionCard(
                        'اطلاعات تماس',
                        _contactInfo != null
                            ? [
                              _buildContentRow(
                                'آدرس',
                                _contactInfo!['address'],
                              ),
                              _buildContentRow('تلفن', _contactInfo!['phone']),
                              _buildContentRow('ایمیل', _contactInfo!['email']),
                              _buildContentRow(
                                'ساعات کاری',
                                _contactInfo!['work_hours'],
                              ),
                            ]
                            : [
                              _buildContentRow(
                                'وضعیت',
                                'اطلاعات تماس یافت نشد',
                              ),
                            ],
                      ),
                    ],
                  ),
                ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _loadAllContent,
            tooltip: 'بارگذاری مجدد',
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _isSyncing ? null : _syncContent,
            tooltip: 'همگام‌سازی با Supabase',
            child:
                _isSyncing
                    ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.5,
                    )
                    : const Icon(Icons.sync),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> content) {
    return Card(
      color: Colors.black.withOpacity(0.3),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.white30),
            const SizedBox(height: 10),
            ...content,
          ],
        ),
      ),
    );
  }

  Widget _buildContentRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'نامشخص',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryItem(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              item['image_url'] != null || item['image_path'] != null
                  ? Image.network(
                    (item['image_url'] ?? item['image_path']).toString(),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[800],
                        alignment: Alignment.center,
                        child: const Text(
                          'خطا در بارگذاری تصویر',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  )
                  : Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[800],
                    alignment: Alignment.center,
                    child: const Text(
                      'بدون تصویر',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
        ),
        const SizedBox(height: 10),
        _buildContentRow('عنوان', item['title'] ?? 'بدون عنوان'),
        _buildContentRow('توضیحات', item['description'] ?? 'بدون توضیحات'),
        if (item['location'] != null)
          _buildContentRow('مکان', item['location']),
        const Divider(color: Colors.white30),
        const SizedBox(height: 10),
      ],
    );
  }
}
