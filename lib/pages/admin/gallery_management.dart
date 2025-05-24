import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tatvan_kepenk/services/supabase_service.dart';
import 'package:tatvan_kepenk/utils/db_schema_fix.dart';
import 'package:tatvan_kepenk/utils/gallery_field_sync.dart';
import 'package:tatvan_kepenk/utils/improved_image_upload.dart';

class GalleryManagementPage extends StatefulWidget {
  const GalleryManagementPage({super.key});

  @override
  State<GalleryManagementPage> createState() => _GalleryManagementPageState();
}

class _GalleryManagementPageState extends State<GalleryManagementPage> {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  // We don't need a local picker since we use ImageUploadHelper

  bool _isLoading = true;
  List<Map<String, dynamic>> _galleryItems = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadGalleryItems();
  }

  Future<void> _loadGalleryItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final items = await _supabaseService.getGalleryItems();
      setState(() {
        _galleryItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Galeri öğeleri yüklenirken hata oluştu: $e';
        _isLoading = false;
      });
      print('Error loading gallery items: $e');
    }
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
          // If schema fix failed, show an error
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

      // Create an instance of ImageUploadHelper
      final imageUploadHelper = ImprovedImageUpload(
        client: _supabaseService.client,
      );

      // Use the helper to pick and upload the image in one step
      final String? imageUrl = await imageUploadHelper.pickAndUploadImage();

      // Close the loading dialog
      Navigator.of(context).pop();

      if (imageUrl != null) {
        // Show dialog to fill in the image details
        final result = await showDialog<Map<String, String>>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return GalleryItemInputDialog(imageUrl: imageUrl);
          },
        );

        if (result != null) {
          setState(() => _isLoading = true);

          // Add to Supabase directly using the extension method with all fields
          await _supabaseService.saveGalleryItem(
            title: result['title'] ?? '',
            description: result['description'] ?? '',
            location: result['location'] ?? '',
            date: result['date'] ?? DateTime.now().toIso8601String(),
            imageUrl: imageUrl,
          );

          // Refresh the gallery items
          await _loadGalleryItems();
          imageAdded = true;
        }
      }
    } catch (e) {
      print('Error adding image: $e');
      imageAdded = false;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Resim eklenirken hata oluştu: $e';
      });
    } finally {
      if (_isLoading) {
        setState(() => _isLoading = false);
      }

      // Show success or error message if the dialog was closed
      if (mounted && imageAdded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resim başarıyla eklendi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _repairGallery() async {
    try {
      final result = await GalleryFieldSync.syncImageFields(
        context: context,
        showProgress: true,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Veri tabanı alanları senkronize edildi.\n'
              'Güncellenen: ${result['updated']}, '
              'Başarısız: ${result['failed']}',
            ),
            backgroundColor:
                result['failed'] > 0 ? Colors.orange : Colors.green,
          ),
        );
      }

      // Refresh the gallery items
      await _loadGalleryItems();
    } catch (e) {
      print('Error repairing gallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Galeri tamiri başarısız: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeri Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.build_circle),
            tooltip: 'Galeri Veritabanını Tamir Et',
            onPressed: _repairGallery,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: _loadGalleryItems,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'back',
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: Colors.blueGrey,
            child: const Icon(Icons.arrow_back),
            tooltip: 'Yönetim Paneline Dön',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: _addImage,
            tooltip: 'Resim Ekle',
            child: const Icon(Icons.add_photo_alternate),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadGalleryItems,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_galleryItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Henüz galeri öğesi yok',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Resim Ekle'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _galleryItems.length,
      itemBuilder: (context, index) {
        final item = _galleryItems[index];

        return GalleryItemCard(
          item: item,
          onEdit: () => _editItem(item),
          onDelete: () => _deleteItem(item),
          onRefresh: _loadGalleryItems,
          supabaseService: _supabaseService,
        );
      },
    );
  }

  Future<void> _editItem(Map<String, dynamic> item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => GalleryItemEditPage(
              item: item,
              supabaseService: _supabaseService,
            ),
      ),
    );

    if (result == true) {
      await _loadGalleryItems();
    }
  }

  Future<void> _deleteItem(Map<String, dynamic> item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Resmi Sil'),
            content: const Text(
              'Bu resim silinecek. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Sil'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        if (item['id'] != null) {
          final imageUrl = item['image_url'] ?? item['image_path'];
          if (imageUrl != null) {
            final String imageUrlStr = imageUrl.toString();
            await _supabaseService.deleteGalleryItem(
              item['id'].toString(),
              imageUrlStr,
            );
          }
        }

        await _loadGalleryItems();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Resim başarıyla silindi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Resim silinirken hata oluştu: $e';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Resim silinirken hata oluştu: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

// Gallery Item Card Widget
class GalleryItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;
  final SupabaseService supabaseService;

  const GalleryItemCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
    required this.supabaseService,
  });

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = item['image_url'] ?? item['image_path'] ?? '';
    final title = item['title']?.toString() ?? '';
    final description = item['description']?.toString() ?? '';
    final dateStr = item['date']?.toString() ?? '';
    final date = item['date']?.toString() ?? '';

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onEdit,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image with overlay
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  imageUrl.isNotEmpty
                      ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.white,
                              size: 64,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                            ),
                          );
                        },
                      )
                      : Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.white,
                          size: 64,
                        ),
                      ),

                  // Action buttons
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        // Edit button
                        Material(
                          color: Colors.white.withOpacity(0.8),
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: onEdit,
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.edit,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Delete button
                        Material(
                          color: Colors.white.withOpacity(0.8),
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: onDelete,
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Title and description overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title.isNotEmpty)
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          if (description.isNotEmpty)
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                          if (dateStr.isNotEmpty)
                            Text(
                              _formatDate(dateStr),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          if (date.isNotEmpty)
                            Text(
                              _formatDate(date),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
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
        ),
      ),
    );
  }
}

// Gallery Item Edit Page
class GalleryItemEditPage extends StatefulWidget {
  final Map<String, dynamic> item;
  final SupabaseService supabaseService;

  const GalleryItemEditPage({
    super.key,
    required this.item,
    required this.supabaseService,
  });

  @override
  State<GalleryItemEditPage> createState() => _GalleryItemEditPageState();
}

class _GalleryItemEditPageState extends State<GalleryItemEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late DateTime _selectedDate;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _hasChanges = false;
  late String _imageUrl;
  final ImagePicker _picker = ImagePicker();
  dynamic _newImageFile;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.item['title']?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.item['description']?.toString() ?? '',
    );
    _locationController = TextEditingController(
      text: widget.item['location']?.toString() ?? '',
    );
    _selectedDate =
        widget.item['date'] != null
            ? DateTime.parse(widget.item['date'].toString())
            : DateTime.now();
    _imageUrl =
        widget.item['image_url']?.toString() ??
        widget.item['image_path']?.toString() ??
        '';

    // Listen for changes
    _titleController.addListener(_onChanges);
    _descriptionController.addListener(_onChanges);
    _locationController.addListener(_onChanges);
  }

  void _onChanges() {
    setState(() {
      _hasChanges = true;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_hasChanges) {
      Navigator.of(context).pop(false);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      // Make sure we have an ID
      if (widget.item['id'] != null) {
        String imageUrl = _imageUrl;
        if (_newImageFile != null) {
          imageUrl = await widget.supabaseService.uploadImageToGallery(
            _newImageFile,
          );
        } // Update the gallery item with all changes
        final bool updateSuccess = await widget.supabaseService
            .updateGalleryItem(
              id: widget.item['id'].toString(),
              title: _titleController.text,
              description: _descriptionController.text,
              location: _locationController.text,
              date: _selectedDate.toIso8601String(),
              imageUrl:
                  _newImageFile != null
                      ? imageUrl
                      : _imageUrl, // Always send the current image URL
            );

        // Check if update was successful
        if (updateSuccess) {
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Değişiklikler başarıyla kaydedildi'),
                backgroundColor: Colors.green,
              ),
            );
          }
          Navigator.of(context).pop(true);
        } else {
          // If update failed, show warning
          setState(() {
            _errorMessage =
                'Değişiklikler kaydedilemedi. Lütfen yeniden deneyiniz.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Bu öğenin ID\'si bulunamadı. Değişiklikler kaydedilemedi.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Değişiklikler kaydedilirken hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _newImageFile = image; // Store the XFile directly
          _hasChanges = true;
        });

        // Show a preview of the new image
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Yeni resim seçildi. Kaydetmek için "Değişiklikleri Kaydet" butonuna tıklayın.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Resim seçilirken hata oluştu: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeri Öğesini Düzenle'),
        actions: [
          if (_hasChanges)
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Kaydet',
              onPressed: _isLoading ? null : _saveChanges,
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ), // Image preview
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              _newImageFile != null
                                  ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      // Using a FutureBuilder to handle the XFile
                                      FutureBuilder<String>(
                                        future: Future.value(
                                          _newImageFile is XFile
                                              ? (_newImageFile as XFile).path
                                              : '',
                                        ),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData &&
                                              snapshot.data!.isNotEmpty) {
                                            return Image.network(
                                              snapshot.data!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Container(
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    size: 64,
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                          return Container(
                                            color: Colors.grey[200],
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        },
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(
                                              0.8,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Yeni Resim',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : _imageUrl.isNotEmpty
                                  ? Image.network(
                                    _imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                              size: 64,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Resim yüklenemedi: $error',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                  : Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                        size: 64,
                                      ),
                                    ),
                                  ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Form fields
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Başlık',
                          border: OutlineInputBorder(),
                          hintText: 'Galeri öğesi için bir başlık girin',
                        ),
                        maxLength: 100,
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Konum',
                          border: OutlineInputBorder(),
                          hintText: 'Konum bilgisi girin (isteğe bağlı)',
                        ),
                        maxLength: 100,
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Açıklama',
                          border: OutlineInputBorder(),
                          hintText: 'Galeri öğesi için bir açıklama girin',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                        maxLength: 500,
                      ),

                      const SizedBox(height: 24),

                      // Image details
                      Text(
                        'Resim Bilgileri',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),

                      const SizedBox(height: 8),

                      Text('ID: ${widget.item['id'] ?? 'N/A'}'),
                      Text(
                        'Eklenme Tarihi: ${_formatDate(widget.item['date'])}',
                      ),

                      const SizedBox(height: 24), // Image replacement
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resim Değiştir',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Mevcut resmi değiştirmek için yeni bir resim seçebilirsiniz.',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.image),
                                  label: const Text('Resim Seç'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                if (_newImageFile != null)
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.green[300]!,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _newImageFile!.path
                                                  .split('/')
                                                  .last,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24), // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isLoading || !_hasChanges ? null : _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            elevation: 3,
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.save),
                                      const SizedBox(width: 10),
                                      const Text('Değişiklikleri Kaydet'),
                                      if (_hasChanges) ...[
                                        const SizedBox(width: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.3,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Text(
                                            'Değişiklikler Var',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';

    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return date.toString();
    }
  }
}

// Gallery Item Input Dialog
class GalleryItemInputDialog extends StatefulWidget {
  final String imageUrl;

  const GalleryItemInputDialog({super.key, required this.imageUrl});

  @override
  State<GalleryItemInputDialog> createState() => _GalleryItemInputDialogState();
}

class _GalleryItemInputDialogState extends State<GalleryItemInputDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_validateInputs);
    _descriptionController.addListener(_validateInputs);
    _locationController.addListener(_validateInputs);
  }

  void _validateInputs() {
    setState(() {
      _isValid =
          _titleController.text.isNotEmpty &&
          _descriptionController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Galeri Resmi Detayları',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Kapat',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Preview of the uploaded image
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.imageUrl,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        width: 300,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title field
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Başlık *',
                  hintText: 'Galeri öğesi için bir başlık girin',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
              ),

              const SizedBox(height: 16),

              // Description field
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama *',
                  hintText: 'Galeri öğesi için bir açıklama girin',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                maxLength: 500,
              ),

              const SizedBox(height: 16),

              // Location field
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Konum',
                  hintText: 'Opsiyonel konum bilgisi',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
              ),

              const SizedBox(height: 16),

              // Date picker field
              ListTile(
                title: const Text('Tarih'),
                subtitle: Text(
                  _selectedDate.toString().split(' ')[0],
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
              ),

              const SizedBox(height: 24),

              // Help text
              const Text(
                '* işareti olan alanların doldurulması zorunludur.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('İptal'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed:
                        _isValid
                            ? () {
                              Navigator.of(context).pop({
                                'title': _titleController.text,
                                'description': _descriptionController.text,
                                'location': _locationController.text,
                                'date': _selectedDate.toIso8601String(),
                              });
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Kaydet'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
