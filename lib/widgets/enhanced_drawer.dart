import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tatvan_kepenk/models/drawer_settings.dart';
import 'package:tatvan_kepenk/services/supabase_content_service.dart';
import 'package:tatvan_kepenk/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class EnhancedDrawer extends StatefulWidget {
  final Function(int)? onPageChanged;
  final int currentPageIndex;

  const EnhancedDrawer({
    super.key,
    this.onPageChanged,
    this.currentPageIndex = 0,
  });

  @override
  State<EnhancedDrawer> createState() => _EnhancedDrawerState();
}

class _EnhancedDrawerState extends State<EnhancedDrawer> {
  DrawerSettings? _drawerSettings;
  late SupabaseContentService _contentService;
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _initContentService();
  }

  Future<void> _initContentService() async {
    try {
      // Get the content service that should already be registered in GetX
      if (Get.isRegistered<SupabaseContentService>()) {
        _contentService = Get.find<SupabaseContentService>();
        await _loadDrawerSettings();
      } else {
        _updateDebugInfo(
          'SupabaseContentService is not registered, attempting to register it',
        );
        // If not registered, create and register it
        final supabaseService = Get.find<SupabaseService>();
        final prefs = await SharedPreferences.getInstance();
        _contentService = SupabaseContentService(supabaseService, prefs);
        Get.put(_contentService);
        await _loadDrawerSettings();
      }
    } catch (e) {
      _updateDebugInfo('Error initializing content service: $e');
    }
  }

  void _updateDebugInfo(String info) {
    print(info);
    if (mounted) {
      setState(() {
        _debugInfo = info;
      });
    }
  }

  Future<void> _loadDrawerSettings() async {
    try {
      // First try to get cached settings
      _updateDebugInfo('Attempting to load drawer settings from cache...');
      var settings = _contentService.getDrawerSettings();

      if (settings != null && mounted) {
        setState(() {
          _drawerSettings = settings;
        });
        _updateDebugInfo(
          'Loaded settings from cache: ${settings.headerTitle}, Phone: ${settings.phone}, Email: ${settings.email}',
        );
      } else {
        _updateDebugInfo(
          'No settings in cache - will try to fetch from Supabase',
        );
      }

      // Then fetch the latest data from Supabase
      _updateDebugInfo('Fetching latest data from Supabase...');
      try {
        await _contentService.syncAllData();
        _updateDebugInfo('Sync completed successfully');
      } catch (syncError) {
        _updateDebugInfo('Error during sync: $syncError');
      }

      // Get updated settings after sync
      _updateDebugInfo('Checking for updated settings after sync...');
      settings = _contentService.getDrawerSettings();
      if (settings != null && mounted) {
        setState(() {
          _drawerSettings = settings;
        });
        _updateDebugInfo(
          'Updated with settings from Supabase: ${settings.headerTitle}, Phone: ${settings.phone}, Email: ${settings.email}',
        );
      } else {
        _updateDebugInfo(
          'No settings found in Supabase after sync - will create default',
        );

        // If still no settings, create default settings
      }
    } catch (e) {
      _updateDebugInfo('Error loading drawer settings: $e');
    }
  }

  void _handleNavigation(BuildContext context, int index) {
    Navigator.pop(context); // Close drawer
    if (widget.onPageChanged != null) {
      widget.onPageChanged!(index);
    }
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            const Color(0xFF0A0A1A).withOpacity(0.95),
            const Color(0xFF141432).withOpacity(0.9),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              _buildDrawerHeader(),
              const SizedBox(height: 20),
              _buildDrawerMenuItem(
                Icons.home_outlined,
                'Ana Sayfa',
                isActive: widget.currentPageIndex == 0,
                onTap: () => _handleNavigation(context, 0),
              ),
              _buildDrawerMenuItem(
                Icons.window_outlined,
                'Kepenk Sistemleri',
                isActive: widget.currentPageIndex == 1,
                onTap: () => _handleNavigation(context, 1),
              ),
              _buildDrawerMenuItem(
                Icons.door_sliding_outlined,
                'Endüstriyel Kapılar',
                isActive: widget.currentPageIndex == 2,
                onTap: () => _handleNavigation(context, 2),
              ),
              _buildDrawerMenuItem(
                Icons.info_outline,
                'Hakkımızda',
                isActive: widget.currentPageIndex == 3,
                onTap: () => _handleNavigation(context, 3),
              ),
              _buildDrawerMenuItem(
                Icons.mail_outline,
                'İletişim',
                isActive: widget.currentPageIndex == 4,
                onTap: () => _handleNavigation(context, 4),
              ),
              const Spacer(),
              _buildDrawerFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withOpacity(0.1), Colors.transparent],
        ),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', width: 100),
            const SizedBox(height: 8),
            if (_drawerSettings != null) ...[
              Text(
                _drawerSettings!.headerTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                _drawerSettings!.headerTagline,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            Container(
              height: 2,
              width: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerMenuItem(
    IconData icon,
    String title, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white70,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
            fontSize: 16,
          ),
        ),
        trailing:
            isActive
                ? const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.white,
                )
                : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDrawerFooter() {
    if (_drawerSettings == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Contact information
          if (_drawerSettings!.address.isNotEmpty) ...[
            _buildContactItem(
              Icons.location_on,
              _drawerSettings!.address,
              onTap: () {},
            ),
            const SizedBox(height: 8),
          ],
          if (_drawerSettings!.phone.isNotEmpty) ...[
            _buildContactItem(
              Icons.phone,
              _drawerSettings!.phone,
              onTap: () => _launchUrl(_drawerSettings!.phoneLink),
            ),
            const SizedBox(height: 8),
          ],
          if (_drawerSettings!.email.isNotEmpty) ...[
            _buildContactItem(
              Icons.email,
              _drawerSettings!.email,
              onTap: () => _launchUrl(_drawerSettings!.emailLink),
            ),
            const SizedBox(height: 8),
          ],
          if (_drawerSettings!.workingHours.isNotEmpty) ...[
            _buildContactItem(
              Icons.access_time,
              _drawerSettings!.workingHours,
              onTap: () {},
            ),
            const SizedBox(height: 16),
          ],

          // Social media buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_drawerSettings!.facebookLink.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildSocialButton(
                    Icons.facebook,
                    onTap: () => _launchUrl(_drawerSettings!.facebookLink),
                  ),
                ),
              if (_drawerSettings!.instagramLink.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildSocialButton(
                    Icons.camera_alt,
                    onTap: () => _launchUrl(_drawerSettings!.instagramLink),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildSocialButton(
                  Icons.phone,
                  onTap: () => _launchUrl(_drawerSettings!.phoneLink),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildSocialButton(
                  Icons.email,
                  onTap: () => _launchUrl(_drawerSettings!.emailLink),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}
