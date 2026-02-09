import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';
import '../../utils/responsive_utils.dart';
import 'home_screen.dart';
import 'about_us_screen.dart';
import 'services_screen.dart';
import 'dart:html' hide VoidCallback;
import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _launchTelephone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (!await launchUrl(phoneUri)) {
      _showErrorDialog('Could not launch phone dialer');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Navigation Bar
            _buildHeader(),

            // Main Content
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08,
                vertical: 60,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: _buildAddressSection(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isMobile = context.isMobile;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 40, vertical: isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, secondary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'VICTORY LYING IN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Bold',
                        letterSpacing: 1.2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => _showMobileMenu(context),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'VICTORY LYING IN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Bold',
                    letterSpacing: 1.2,
                  ),
                ),
                Wrap(
                  spacing: 40,
                  children: [
                    _buildNavItem('HOME', false),
                    _buildNavItem('ABOUT US', false),
                    _buildNavItem('SERVICES', false),
                    _buildNavItem('CONTACT US', true),
                  ],
                ),
              ],
            ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: primary,
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.home, color: Colors.white70),
                title: const Text('HOME',
                    style:
                        TextStyle(color: Colors.white70, fontFamily: 'Medium')),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.info, color: Colors.white70),
                title: const Text('ABOUT US',
                    style:
                        TextStyle(color: Colors.white70, fontFamily: 'Medium')),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AboutUsScreen()));
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.medical_services, color: Colors.white70),
                title: const Text('SERVICES',
                    style:
                        TextStyle(color: Colors.white70, fontFamily: 'Medium')),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ServicesScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.contact_mail, color: Colors.white),
                title: const Text('CONTACT US',
                    style: TextStyle(color: Colors.white, fontFamily: 'Bold')),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String title, bool isActive) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _handleNavigation(title);
        },
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: isActive ? 'Bold' : 'Medium',
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _handleNavigation(String title) {
    switch (title) {
      case 'HOME':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 'ABOUT US':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AboutUsScreen()),
        );
        break;
      case 'SERVICES':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ServicesScreen()),
        );
        break;

      case 'CONTACT US':
        // Already on contact us screen
        break;
    }
  }

  Widget _buildContactForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text(
          'Have Question or Concerns?',
          style: TextStyle(
            fontSize: 32,
            fontFamily: 'Bold',
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 30),

        // Form Card
        Container(
          padding: const EdgeInsets.all(35),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary.withOpacity(0.85), secondary.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name Field
              _buildTextField(
                controller: _nameController,
                hintText: 'Name',
              ),
              const SizedBox(height: 20),

              // Email Field
              _buildTextField(
                controller: _emailController,
                hintText: 'Email Address',
              ),
              const SizedBox(height: 20),

              // Contact Number Field
              _buildTextField(
                controller: _contactController,
                hintText: 'Contact Number',
              ),
              const SizedBox(height: 20),

              // Message Field
              _buildTextField(
                controller: _messageController,
                hintText: 'Message',
                maxLines: 5,
              ),
              const SizedBox(height: 25),

              // Send Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle send message
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 5,
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                  child: const Text(
                    'Send',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Bold',
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: Colors.black,
        fontFamily: 'Regular',
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade600,
          fontFamily: 'Regular',
          fontSize: 15,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: maxLines > 1 ? 15 : 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    final isMobile = context.isMobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'CONTACT INFORMATION',
          style: TextStyle(
            fontSize: isMobile ? 24 : 32,
            fontFamily: 'Bold',
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 30),

        // Contact Information Card
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 25),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary.withOpacity(0.85), secondary.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Email
              _buildContactItem(
                icon: Icons.email,
                label: 'Email',
                value: 'victorylying@yahoo.com',
                onTap: () => _launchEmail('victorylying@yahoo.com'),
              ),
              const SizedBox(height: 16),

              // Instagram
              _buildContactItem(
                icon: Icons.camera_alt,
                label: 'Instagram',
                value: '@victory_lyingincenter',
                onTap: () => _launchInstagram('victory_lyingincenter'),
              ),
              const SizedBox(height: 16),

              // Facebook
              _buildContactItem(
                icon: Icons.facebook,
                label: 'Facebook',
                value: 'Victory Lying-In Center',
                onTap: () => _launchFacebook(),
              ),
              const SizedBox(height: 16),

              // Telephone
              _buildContactItem(
                icon: Icons.phone,
                label: 'Telephone',
                value: '0956 879 1685',
                onTap: () => _launchTelephone('09568791685'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // Map Section with Embedded Google Maps
        Text(
          'ADDRESS & LOCATION',
          style: TextStyle(
            fontSize: isMobile ? 24 : 32,
            fontFamily: 'Bold',
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '2104-2114 Dimasalang St, Santa Cruz, Manila, 1008 Metro Manila',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontFamily: 'Regular',
            color: Colors.black87,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 30),

        // Embedded Google Maps
        Container(
          width: double.infinity,
          height: isMobile ? 250 : 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _buildGoogleMap(),
          ),
        ),
        const SizedBox(height: 20),

        // Open in Maps Button
        Center(
          child: ElevatedButton.icon(
            onPressed: () async {
              final Uri mapUri = Uri.parse(
                'https://www.google.com/maps/search/?api=1&query=14.6043,120.9898&query_place_id=ChIJY1iZ0PjJlzMRbDGxJ02EfSg',
              );
              if (!await launchUrl(mapUri,
                  mode: LaunchMode.externalApplication)) {
                _showErrorDialog('Could not open map');
              }
            },
            icon: const Icon(Icons.map, color: Colors.white),
            label: Text(
              'Open in Google Maps',
              style: TextStyle(
                fontFamily: 'Bold',
                color: Colors.white,
                fontSize: isMobile ? 14 : 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 30, vertical: isMobile ? 12 : 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleMap() {
    if (kIsWeb) {
      return HtmlElementView(
        viewType: 'google-maps-iframe',
      );
    }
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Text(
          'Map not available on mobile',
          style: TextStyle(fontFamily: 'Medium'),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final isMobile = context.isMobile;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(isMobile ? 12 : 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: isMobile ? 20 : 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.black54,
                        fontFamily: 'Medium',
                        fontSize: isMobile ? 12 : 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Bold',
                        fontSize: isMobile ? 14 : 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: primary,
                size: isMobile ? 14 : 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (!await launchUrl(emailUri)) {
      _showErrorDialog('Could not launch email app');
    }
  }

  Future<void> _launchInstagram(String username) async {
    final Uri instagramUri = Uri.parse('instagram://user/?username=$username');
    final Uri webUri = Uri.parse('https://www.instagram.com/$username');

    if (!await launchUrl(instagramUri)) {
      // If app is not installed, try to open in web browser
      if (!await launchUrl(webUri)) {
        _showErrorDialog('Could not launch Instagram');
      }
    }
  }

  Future<void> _launchFacebook() async {
    const String facebookUrl = 'https://www.facebook.com/VictoryLyingInCenter';
    final Uri facebookUri = Uri.parse(facebookUrl);

    if (!await launchUrl(facebookUri)) {
      _showErrorDialog('Could not launch Facebook');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Error',
          style: TextStyle(fontFamily: 'Bold'),
        ),
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Regular'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: primary, fontFamily: 'Bold'),
            ),
          ),
        ],
      ),
    );
  }
}
