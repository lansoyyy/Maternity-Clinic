import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'home_screen.dart';
import 'about_us_screen.dart';
import 'contact_us_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
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
                    'OUR SERVICES',
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
                  const SizedBox(height: 20),
                  const Text(
                    'Comprehensive healthcare services for mothers and children',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Regular',
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Main Services
                  _buildMainServices(),
                  const SizedBox(height: 60),

                  // Additional Services
                  _buildAdditionalServices(),
                  const SizedBox(height: 60),

                  // Why Choose Us
                  _buildWhyChooseUs(),
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
              _buildNavItem('ABOUT US', false),
              _buildNavItem('SERVICES', true),
            
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AboutUsScreen()),
        );
        break;
      case 'SERVICES':
        // Already on services screen
        break;
   
      case 'CONTACT US':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ContactUsScreen()),
        );
        break;
    }
  }

  Widget _buildMainServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRIMARY SERVICES',
          style: TextStyle(
            fontSize: 28,
            fontFamily: 'Bold',
            color: primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 30),
        _buildServiceDetailCard(
          'assets/images/ob-gyne.png',
          'OBSTETRICS & GYNECOLOGY',
          'Comprehensive women\'s health services including prenatal care, labor and delivery, postnatal care, and gynecological consultations. Our experienced OB-GYNEs provide personalized care throughout your pregnancy journey.',
          [
            'Prenatal checkups and monitoring',
            'High-risk pregnancy management',
            'Normal and cesarean deliveries',
            'Postnatal care and consultation',
            'Family planning services',
            'Gynecological examinations',
          ],
        ),
        const SizedBox(height: 30),
        _buildServiceDetailCard(
          'assets/images/ultra sound.png',
          'ULTRASOUND SERVICES',
          'State-of-the-art ultrasound imaging technology for accurate prenatal monitoring and diagnostics. Our advanced equipment ensures clear visualization for better assessment of your baby\'s development.',
          [
            '2D/3D/4D ultrasound imaging',
            'Fetal growth monitoring',
            'Gender determination',
            'Anomaly screening',
            'Doppler studies',
            'Pelvic ultrasound',
          ],
        ),
        const SizedBox(height: 30),
        _buildServiceDetailCard(
          'assets/images/pediatrics.png',
          'PEDIATRIC CARE',
          'Expert pediatric services for newborns and children. Our pediatricians provide comprehensive care from birth through childhood, ensuring your child\'s optimal health and development.',
          [
            'Newborn care and assessment',
            'Well-baby checkups',
            'Vaccination and immunization',
            'Growth and development monitoring',
            'Pediatric consultations',
            'Treatment of common childhood illnesses',
          ],
        ),
      ],
    );
  }

  Widget _buildServiceDetailCard(
    String iconPath,
    String title,
    String description,
    List<String> features,
  ) {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: orangePallete,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(22),
            child: Image.asset(
              iconPath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 30),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Bold',
                    color: primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Regular',
                    color: Colors.black87,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 15,
                  runSpacing: 12,
                  children: features.map((feature) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          feature,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Regular',
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ADDITIONAL SERVICES',
          style: TextStyle(
            fontSize: 28,
            fontFamily: 'Bold',
            color: primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            _buildAdditionalServiceCard(
              Icons.medical_services,
              'Laboratory Services',
              'Complete laboratory testing and diagnostic services',
            ),
            const SizedBox(width: 25),
            _buildAdditionalServiceCard(
              Icons.local_pharmacy,
              'Pharmacy',
              'In-house pharmacy for convenient medication access',
            ),
            const SizedBox(width: 25),
            _buildAdditionalServiceCard(
              Icons.emergency,
              '24/7 Emergency Care',
              'Round-the-clock emergency obstetric services',
            ),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          children: [
            _buildAdditionalServiceCard(
              Icons.hotel,
              'Comfortable Rooms',
              'Clean and comfortable lying-in rooms for mothers',
            ),
            const SizedBox(width: 25),
            _buildAdditionalServiceCard(
              Icons.people,
              'Lactation Support',
              'Breastfeeding guidance and lactation consultation',
            ),
            const SizedBox(width: 25),
            _buildAdditionalServiceCard(
              Icons.school,
              'Prenatal Classes',
              'Educational sessions for expecting parents',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalServiceCard(
    IconData icon,
    String title,
    String description,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(25),
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary.withOpacity(0.1), secondary.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: primary.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 35,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Bold',
                color: primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Regular',
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyChooseUs() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, secondary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'WHY CHOOSE VICTORY LYING IN?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontFamily: 'Bold',
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              _buildWhyChooseUsItem(
                Icons.verified,
                'Experienced Staff',
                'Highly qualified medical professionals',
              ),
              const SizedBox(width: 30),
              _buildWhyChooseUsItem(
                Icons.medical_information,
                'Modern Equipment',
                'State-of-the-art medical technology',
              ),
              const SizedBox(width: 30),
              _buildWhyChooseUsItem(
                Icons.favorite,
                'Compassionate Care',
                'Personalized attention for every patient',
              ),
              const SizedBox(width: 30),
              _buildWhyChooseUsItem(
                Icons.price_check,
                'Affordable Rates',
                'Quality healthcare at reasonable prices',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhyChooseUsItem(IconData icon, String title, String description) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primary,
              size: 45,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontFamily: 'Bold',
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Regular',
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
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
