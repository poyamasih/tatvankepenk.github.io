import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tatvan_kepenk/services/supabase_service.dart';
import 'package:tatvan_kepenk/services/supabase_config.dart';
import 'package:tatvan_kepenk/widgets/animated_background.dart';

class SupabaseTestPage extends StatefulWidget {
  const SupabaseTestPage({super.key});

  @override
  State<SupabaseTestPage> createState() => _SupabaseTestPageState();
}

class _SupabaseTestPageState extends State<SupabaseTestPage> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;
  String _resultMessage = '';
  List<Map<String, dynamic>> _testData = [];

  @override
  void initState() {
    super.initState();
    _checkSupabaseConfig();
  }

  Future<void> _checkSupabaseConfig() async {
    if (!SupabaseConfig.isConfigured()) {
      setState(() {
        _resultMessage =
            'خطا: لطفاً تنظیمات Supabase را در فایل supabase_config.dart وارد کنید';
      });
      return;
    }

    try {
      await _supabaseService.initialize();
      setState(() {
        _resultMessage = 'Supabase با موفقیت مقداردهی اولیه شد.';
      });
    } catch (e) {
      setState(() {
        _resultMessage = 'خطا در مقداردهی اولیه Supabase: $e';
      });
    }
  }

  Future<void> _testHomeContent() async {
    setState(() {
      _isLoading = true;
      _resultMessage = 'در حال تست محتوای صفحه اصلی...';
    });

    try {
      final data = await _supabaseService.getHomeContent();
      setState(() {
        _testData = data != null ? [data] : [];
        _resultMessage = 'محتوای صفحه اصلی با موفقیت دریافت شد.';
      });
    } catch (e) {
      setState(() {
        _resultMessage = 'خطا در دریافت محتوای صفحه اصلی: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testKepenkContent() async {
    setState(() {
      _isLoading = true;
      _resultMessage = 'در حال تست محتوای کپنک سیستملری...';
    });

    try {
      final data = await _supabaseService.getKepenkContent();
      setState(() {
        _testData = data != null ? [data] : [];
        _resultMessage = 'محتوای کپنک سیستملری با موفقیت دریافت شد.';
      });
    } catch (e) {
      setState(() {
        _resultMessage = 'خطا در دریافت محتوای کپنک سیستملری: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGalleryItems() async {
    setState(() {
      _isLoading = true;
      _resultMessage = 'در حال تست آیتم‌های گالری...';
    });

    try {
      final data = await _supabaseService.getGalleryItems();
      setState(() {
        _testData = data;
        _resultMessage = '${data.length} آیتم گالری با موفقیت دریافت شد.';
      });
    } catch (e) {
      setState(() {
        _resultMessage = 'خطا در دریافت آیتم‌های گالری: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testCreateHomeContent() async {
    setState(() {
      _isLoading = true;
      _resultMessage = 'در حال تست ایجاد محتوای صفحه اصلی...';
    });

    try {
      final data = {
        'title': 'عنوان تست ${DateTime.now().millisecondsSinceEpoch}',
        'description':
            'این یک متن تست برای صفحه اصلی است که در تاریخ ${DateTime.now()} ایجاد شده است.',
      };

      final result = await _supabaseService.createHomeContent(data);
      setState(() {
        _testData = [result];
        _resultMessage = 'محتوای صفحه اصلی با موفقیت ایجاد شد.';
      });
    } catch (e) {
      setState(() {
        _resultMessage = 'خطا در ایجاد محتوای صفحه اصلی: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTestButton(String title, Function() onPressed) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: Colors.white.withOpacity(0.2),
      ),
      child: Text(title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تست Supabase'),
        backgroundColor: Colors.black.withOpacity(0.5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: AnimatedBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // نمایش وضعیت
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color:
                          _resultMessage.contains('خطا')
                              ? Colors.red.withOpacity(0.2)
                              : _resultMessage.contains('موفقیت')
                              ? Colors.green.withOpacity(0.2)
                              : Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            _resultMessage.contains('خطا')
                                ? Colors.red.withOpacity(0.5)
                                : _resultMessage.contains('موفقیت')
                                ? Colors.green.withOpacity(0.5)
                                : Colors.blue.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'وضعیت:',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _resultMessage,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_isLoading) ...[
                          const SizedBox(height: 15),
                          const CircularProgressIndicator(),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // دکمه‌های تست
                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildTestButton(
                        'تست محتوای صفحه اصلی',
                        _testHomeContent,
                      ),
                      _buildTestButton(
                        'تست محتوای کپنک سیستملری',
                        _testKepenkContent,
                      ),
                      _buildTestButton('تست آیتم‌های گالری', _testGalleryItems),
                      _buildTestButton(
                        'تست ایجاد محتوای جدید',
                        _testCreateHomeContent,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // نمایش نتایج تست
                  if (_testData.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'نتایج تست (${_testData.length} مورد):',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 15),
                          ..._testData.map(
                            (item) => Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...item.entries.map(
                                    (e) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 3,
                                      ),
                                      child: Text(
                                        '${e.key}: ${e.value}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
