import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:tatvan_kepenk/services/auth_service.dart';
import 'package:tatvan_kepenk/services/content_storage.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AuthService _authService;
  late ContentStorage _contentStorage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Ana Sayfa controllers
  final _homeTitleController = TextEditingController();
  final _homeDescriptionController = TextEditingController();

  // Kepenk Sistemleri controllers
  final _kepenkTitleController = TextEditingController();
  final _kepenkDescriptionController = TextEditingController();
  List<Map<String, dynamic>> galleryItems = [];

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
  }

  Future<void> _initializeServices() async {
    final prefs = await SharedPreferences.getInstance();
    _authService = AuthService(prefs);
    _contentStorage = ContentStorage(prefs);

    if (!_authService.isLoggedIn()) {
      Get.offAllNamed('/admin/login');
      return;
    }

    await _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() => _isLoading = true);
    try {
      // Load Ana Sayfa content
      _homeTitleController.text = _contentStorage.getHomeTitle();
      _homeDescriptionController.text = _contentStorage.getHomeDescription();

      // Load Kepenk Sistemleri content
      _kepenkTitleController.text = _contentStorage.getKepenkTitle();
      _kepenkDescriptionController.text =
          _contentStorage.getKepenkDescription();
      galleryItems = _contentStorage.getGalleryItems();

      // Load Endüstriyel Kapılar content
      _kapilarTitleController.text = _contentStorage.getKapilarTitle();
      _kapilarDescriptionController.text =
          _contentStorage.getKapilarDescription();

      // Load Hakkımızda content
      _about1TitleController.text = _contentStorage.getAboutTitle(1);
      _about1DescController.text = _contentStorage.getAboutDescription(1);
      _about2TitleController.text = _contentStorage.getAboutTitle(2);
      _about2DescController.text = _contentStorage.getAboutDescription(2);
      _about3TitleController.text = _contentStorage.getAboutTitle(3);
      _about3DescController.text = _contentStorage.getAboutDescription(3);

      // Load İletişim content
      _addressController.text = _contentStorage.getContactInfo('address');
      _phoneController.text = _contentStorage.getContactInfo('phone');
      _emailController.text = _contentStorage.getContactInfo('email');
      _workHoursController.text = _contentStorage.getContactInfo('workHours');
      contactForms = _contentStorage.getContactForms();
    } catch (e) {
      print('Error loading content: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İçerik yüklenirken bir hata oluştu')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final String fileName =
            DateTime.now().millisecondsSinceEpoch.toString() +
            "_" +
            path.basename(image.path);

        // استفاده از پوشه assets/gallery برای ذخیره تصاویر
        final String newPath = 'assets/gallery/$fileName';

        // ایجاد پوشه اگر وجود نداشته باشد
        final directory = Directory('assets/gallery');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        // کپی تصویر به پوشه گالری
        await File(image.path).copy(newPath);

        setState(() {
          galleryItems.add({
            'image': newPath,
            'title': '',
            'description': '',
            'date': DateTime.now().toIso8601String(),
            'location': '',
          });
        });

        await _contentStorage.saveGalleryItems(galleryItems);
      }
    } catch (e) {
      print('Error adding image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resim eklenirken bir hata oluştu')),
      );
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      // Save Ana Sayfa content
      await _contentStorage.saveHomeTitle(_homeTitleController.text);
      await _contentStorage.saveHomeDescription(
        _homeDescriptionController.text,
      );

      // Save Kepenk Sistemleri content
      await _contentStorage.saveKepenkTitle(_kepenkTitleController.text);
      await _contentStorage.saveKepenkDescription(
        _kepenkDescriptionController.text,
      );
      await _contentStorage.saveGalleryItems(galleryItems);

      // Save Endüstriyel Kapılar content
      await _contentStorage.saveKapilarTitle(_kapilarTitleController.text);
      await _contentStorage.saveKapilarDescription(
        _kapilarDescriptionController.text,
      );

      // Save Hakkımızda content
      await _contentStorage.saveAboutContent(
        '1',
        _about1TitleController.text,
        _about1DescController.text,
      );
      await _contentStorage.saveAboutContent(
        '2',
        _about2TitleController.text,
        _about2DescController.text,
      );
      await _contentStorage.saveAboutContent(
        '3',
        _about3TitleController.text,
        _about3DescController.text,
      );

      // Save İletişim content
      await _contentStorage.saveContactInfo({
        'address': _addressController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'workHours': _workHoursController.text,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Değişiklikler kaydedildi')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bir hata oluştu')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    Get.offAllNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yönetim Paneli'),
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
          TextButton.icon(
            onPressed: () => Get.toNamed('/supabase-content'),
            icon: const Icon(Icons.visibility, color: Colors.white),
            label: const Text(
              'نمایش محتوا',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton.icon(
            onPressed: () => Get.toNamed('/admin/panel/supabase'),
            icon: const Icon(Icons.cloud, color: Colors.white),
            label: const Text(
              'Supabase',
              style: TextStyle(color: Colors.white),
            ),
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
              ElevatedButton.icon(
                onPressed: _addImage,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Resim Ekle'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: galleryItems.length,
            itemBuilder: (context, index) {
              final item = galleryItems[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.file(
                            File(item['image']),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image, size: 100),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Başlık',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      galleryItems[index]['title'] = value;
                                    });
                                  },
                                  controller: TextEditingController(
                                    text: item['title'],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Konum',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      galleryItems[index]['location'] = value;
                                    });
                                  },
                                  controller: TextEditingController(
                                    text: item['location'],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Açıklama',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: (value) {
                          setState(() {
                            galleryItems[index]['description'] = value;
                          });
                        },
                        controller: TextEditingController(
                          text: item['description'],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tarih: ${item['date']}'),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                galleryItems.removeAt(index);
                              });
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
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
                  title: Text(form['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(form['email']),
                      Text(form['message']),
                      Text('Tarih: ${form['date']}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        contactForms.removeAt(index);
                      });
                      _contentStorage.saveContactForms(contactForms);
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

    super.dispose();
  }
}
