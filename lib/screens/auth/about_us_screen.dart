import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import 'home_screen.dart';
import 'contact_us_screen.dart';
import 'services_screen.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Title
                  const Text(
                    'ABOUT US',
                    style: TextStyle(
                      fontSize: 42,
                      fontFamily: 'Bold',
                      color: Colors.black,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 100,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primary, secondary],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // About Section
                  _buildAboutSection(),
                  const SizedBox(height: 60),

                  // Mission & Vision Section
                  _buildMissionVisionSection(),
                  const SizedBox(height: 60),

                  // Services Overview
                  _buildServicesOverview(),
                ],
              ),
            ),

            // Footer Section
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          const Text(
            'VICTORY LYING IN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: 'Bold',
              letterSpacing: 1.2,
            ),
          ),

          // Navigation Menu
          Wrap(
            spacing: 40,
            children: [
              _buildNavItem('HOME', false),
              _buildNavItem('ABOUT US', true),
              _buildNavItem('SERVICES', false),
        
              _buildNavItem('CONTACT US', false),
            ],
          ),
        ],
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
        // Already on about us screen
        break;
      case 'SERVICES':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ServicesScreen()),
        );
        break;
   
      case 'CONTACT US':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ContactUsScreen()),
        );
        break;
    }
  }

  Widget _buildAboutSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left - Image
        Expanded(
          flex: 1,
          child: Container(
            height: 350,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/figure.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: orangePallete,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.medical_services,
                        size: 80,
                        color: primary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 60),

        // Right - Content
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Victory Lying In',
                style: TextStyle(
                  fontSize: 32,
                  fontFamily: 'Bold',
                  color: primary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Victory Lying In is a premier maternity clinic dedicated to providing exceptional care for mothers and their babies. Our state-of-the-art facility combines modern medical technology with compassionate, personalized care.',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Regular',
                  color: Colors.black87,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'We understand that pregnancy and childbirth are among life\'s most precious moments. Our experienced team of healthcare professionals is committed to ensuring the health and well-being of both mother and child throughout every stage of the journey.',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Regular',
                  color: Colors.black87,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: orangePallete,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: primary,
                      size: 40,
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Text(
                        'Trusted by thousands of families for quality maternal care',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Medium',
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMissionVisionSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mission
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary.withOpacity(0.1), secondary.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primary.withOpacity(0.3), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.flag,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      'OUR MISSION',
                      style: TextStyle(
                        fontSize: 26,
                        fontFamily: 'Bold',
                        color: primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                const Text(
                  'To provide comprehensive, compassionate, and high-quality maternal and child healthcare services. We strive to create a safe, comfortable, and supportive environment where every mother feels valued and cared for throughout her pregnancy journey.',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Regular',
                    color: Colors.black87,
                    height: 1.8,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 40),

        // Vision
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary.withOpacity(0.1), secondary.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primary.withOpacity(0.3), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.visibility,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      'OUR VISION',
                      style: TextStyle(
                        fontSize: 26,
                        fontFamily: 'Bold',
                        color: primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                const Text(
                  'To be the leading maternity clinic recognized for excellence in maternal and child healthcare. We envision a future where every family has access to world-class medical care, delivered with warmth, respect, and dedication.',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Regular',
                    color: Colors.black87,
                    height: 1.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OUR SERVICES',
          style: TextStyle(
            fontSize: 32,
            fontFamily: 'Bold',
            color: primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            _buildServiceCard(
              'assets/images/ob-gyne.png',
              'OB-GYNE',
              'Comprehensive obstetrics and gynecology services for women\'s health',
            ),
            const SizedBox(width: 30),
            _buildServiceCard(
              'assets/images/ultra sound.png',
              'ULTRASOUND',
              'Advanced ultrasound imaging for prenatal monitoring and diagnostics',
            ),
            const SizedBox(width: 30),
            _buildServiceCard(
              'assets/images/pediatrics.png',
              'PEDIATRICS',
              'Expert pediatric care for newborns and children\'s health needs',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceCard(String iconPath, String title, String description) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(30),
        height: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: orangePallete,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(18),
              child: Image.asset(
                iconPath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Bold',
                color: primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Regular',
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, secondary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: const Text(
        'We care about your health\nand well - being',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontFamily: 'Bold',
          height: 1.3,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
