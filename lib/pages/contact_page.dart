import 'package:flutter/material.dart';
import 'package:tatvan_kepenk/widgets/animated_background.dart';
import 'package:tatvan_kepenk/widgets/enhanced_header.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:tatvan_kepenk/services/content_storage.dart';

class ContactPageContent extends StatefulWidget {
  const ContactPageContent({super.key});

  @override
  State<ContactPageContent> createState() => _ContactPageContentState();
}

class _ContactPageContentState extends State<ContactPageContent> {
  late ContentStorage _contentStorage;

  String _address = "Tatvan, Bitlis, Türkiye";
  String _phone = "+90 XXX XXX XX XX";
  String _email = "info@tatvankepenk.com";
  String _workHours = "Pazartesi - Cumartesi\n08:30 - 18:30";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _contentStorage = Get.find<ContentStorage>();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      _address = _contentStorage.getContactInfo('address');
      _phone = _contentStorage.getContactInfo('phone');
      _email = _contentStorage.getContactInfo('email');
      _workHours = _contentStorage.getContactInfo('workHours');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading contact info: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 800;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              Center(
                child: Text(
                  "İLETİŞİM",
                  style: GoogleFonts.montserrat(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              isSmallScreen
                  ? _buildContactContentMobile()
                  : _buildContactContentDesktop(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactContentDesktop() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 1, child: _buildContactInfo()),
        const SizedBox(width: 30),
        Expanded(flex: 1, child: _buildContactForm()),
      ],
    );
  }

  Widget _buildContactContentMobile() {
    return Column(
      children: [
        _buildContactInfo(),
        const SizedBox(height: 30),
        _buildContactForm(),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoItem(
            icon: Icons.location_on_outlined,
            title: "Adres",
            content: _address.isNotEmpty ? _address : "Tatvan, Bitlis, Türkiye",
          ),
          const SizedBox(height: 20),
          _buildInfoItem(
            icon: Icons.phone_outlined,
            title: "Telefon",
            content: _phone.isNotEmpty ? _phone : "+90 XXX XXX XX XX",
          ),
          const SizedBox(height: 20),
          _buildInfoItem(
            icon: Icons.email_outlined,
            title: "E-posta",
            content: _email.isNotEmpty ? _email : "info@tatvankepenk.com",
          ),
          const SizedBox(height: 20),
          _buildInfoItem(
            icon: Icons.access_time,
            title: "Çalışma Saatleri",
            content:
                _workHours.isNotEmpty
                    ? _workHours
                    : "Pazartesi - Cumartesi\n08:30 - 18:30",
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bize Ulaşın",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField("İsim Soyisim"),
          const SizedBox(height: 15),
          _buildTextField("E-posta"),
          const SizedBox(height: 15),
          _buildTextField("Telefon"),
          const SizedBox(height: 15),
          _buildTextField("Mesajınız", maxLines: 4),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Gönder",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.9), size: 24),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      style: TextStyle(color: Colors.white.withOpacity(0.9)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
      ),
    );
  }
}

// Original ContactPage that uses the content
class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: EnhancedHeader(),
      ),
      body: AnimatedBackground(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 100,
            left: 20,
            right: 20,
            bottom: 40,
          ),
          child: ContactPageContent(),
        ),
      ),
    );
  }
}
