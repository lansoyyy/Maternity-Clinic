import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/responsive_utils.dart';
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

                  // Services and Packages
                  _buildServicesAndPackages(),
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
                    _buildNavItem('SERVICES', true),
                    _buildNavItem('CONTACT US', false),
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
                    const Icon(Icons.medical_services, color: Colors.white),
                title: const Text('SERVICES',
                    style: TextStyle(color: Colors.white, fontFamily: 'Bold')),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.contact_mail, color: Colors.white70),
                title: const Text('CONTACT US',
                    style:
                        TextStyle(color: Colors.white70, fontFamily: 'Medium')),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ContactUsScreen()));
                },
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
      ],
    );
  }

  Widget _buildServiceDetailCard(
    String iconPath,
    String title,
    String description,
    List<String> features,
  ) {
    final isMobile = context.isMobile;

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 35),
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
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Center(
                  child: Container(
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
                ),
                const SizedBox(height: 20),
                // Content
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Bold',
                    color: primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Regular',
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: features.map((feature) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: primary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          feature,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Regular',
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            )
          : Row(
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
    final isMobile = context.isMobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ADDITIONAL SERVICES',
          style: TextStyle(
            fontSize: isMobile ? 24 : 28,
            fontFamily: 'Bold',
            color: primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 30),
        if (isMobile) ...[
          // Mobile: 2 cards per row
          Row(
            children: [
              Expanded(
                child: _buildAdditionalServiceCard(
                  Icons.medical_services,
                  'Laboratory Services',
                  'Complete laboratory testing and diagnostic services',
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildAdditionalServiceCard(
                  Icons.hotel,
                  'Comfortable Rooms',
                  'Clean and comfortable lying-in rooms for mothers',
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildAdditionalServiceCard(
                  Icons.people,
                  'Lactation Support',
                  'Breastfeeding guidance and lactation consultation',
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildAdditionalServiceCard(
                  Icons.school,
                  'Prenatal Classes',
                  'Educational sessions for expecting parents',
                ),
              ),
            ],
          ),
        ] else ...[
          // Desktop: 3 cards + 1 card layout
          Row(
            children: [
              Expanded(
                child: _buildAdditionalServiceCard(
                  Icons.medical_services,
                  'Laboratory Services',
                  'Complete laboratory testing and diagnostic services',
                ),
              ),
              const SizedBox(width: 25),
              Expanded(
                child: _buildAdditionalServiceCard(
                  Icons.hotel,
                  'Comfortable Rooms',
                  'Clean and comfortable lying-in rooms for mothers',
                ),
              ),
              const SizedBox(width: 25),
              Expanded(
                child: _buildAdditionalServiceCard(
                  Icons.people,
                  'Lactation Support',
                  'Breastfeeding guidance and lactation consultation',
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: _buildAdditionalServiceCard(
                  Icons.school,
                  'Prenatal Classes',
                  'Educational sessions for expecting parents',
                ),
              ),
              const SizedBox(width: 25),
              Expanded(child: const SizedBox()),
              const SizedBox(width: 25),
              Expanded(child: const SizedBox()),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAdditionalServiceCard(
    IconData icon,
    String title,
    String description,
  ) {
    final isMobile = context.isMobile;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 25),
      height: isMobile ? 160 : 200,
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
            padding: EdgeInsets.all(isMobile ? 10 : 15),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isMobile ? 28 : 35,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 13 : 16,
              fontFamily: 'Bold',
              color: primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 11 : 13,
              fontFamily: 'Regular',
              color: Colors.black87,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildServicesAndPackages() {
    final isMobile = context.isMobile;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SERVICES & PACKAGES',
          style: TextStyle(
            fontSize: isMobile ? 24 : 28,
            fontFamily: 'Bold',
            color: primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 30),
        if (screenWidth > 900) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildServicesOffered(),
              ),
              const SizedBox(width: 30),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildMaternityPackageCard()),
                        const SizedBox(width: 20),
                        Expanded(child: _buildNewbornPackageCard()),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildNsdPackageCard(),
                  ],
                ),
              ),
            ],
          ),
        ] else ...[
          // Services Offered Section
          _buildServicesOffered(),
          const SizedBox(height: 40),

          // Packages Section
          _buildPackages(),
        ],
      ],
    );
  }

  Widget _buildServicesOffered() {
    final isMobile = context.isMobile;

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 30),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_services,
                color: primary,
                size: isMobile ? 24 : 28,
              ),
              const SizedBox(width: 10),
              Text(
                '🩺 Services Offered',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 22,
                  fontFamily: 'Bold',
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Effective from January 2025 unless modified or changed.',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              fontFamily: 'Regular',
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          _buildServiceItem('Prenatal Checkup', 'Php 300.00'),
          _buildServiceItem('Postnatal Checkup', 'Php 300.00'),
          _buildServiceItem('Pap Smear', 'Php 800.00'),
          _buildServiceItem('NST / Fetal Monitoring', 'Php 500.00'),
          _buildServiceItem('Pregnancy Test', 'Php 150.00'),
          _buildServiceItem('Injectable Pill / DMPA', 'Php 500.00'),
          _buildServiceItem('Subdermal Implant', 'Php 3,000.00'),
          _buildServiceItem('Removal of Implant', 'Php 2,000.00'),
          _buildServiceItem('IUD Removal', 'Php 1,500.00'),
          _buildServiceItem('Newborn Screening', 'Php 1,750.00'),
          _buildServiceItem('Hearing Test', 'Php 500.00'),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String name, String price) {
    final isMobile = context.isMobile;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontFamily: 'Regular',
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: isMobile ? 85 : 100,
            child: Text(
              price,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontFamily: 'Bold',
                color: primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackages() {
    return Column(
      children: [
        // Maternity Care Package
        _buildMaternityPackageCard(),
        const SizedBox(height: 30),

        // Newborn Care Package
        _buildNewbornPackageCard(),
        const SizedBox(height: 30),

        // NSD Package
        _buildNsdPackageCard(),
      ],
    );
  }

  Widget _buildMaternityPackageCard() {
    return _buildPackageCard(
      '🤰 Maternity Care Package (MCP)',
      [
        'Without PhilHealth (Amount to be Paid)',
        'HCI Fees',
        'Facility / Room Charge',
        'Delivery Room Fee',
        'Drugs and Medications',
        'Supplies – Php 13,550',
        'Professional Fee – Php 12,000',
        'Total: Php 25,550',
      ],
      [
        'PhilHealth Benefits',
        'Php 6,240',
        'Php 4,160',
        'Total: Php 10,400',
      ],
      [
        'With PhilHealth (Amount to be Paid)',
        'Php 7,310',
        'Php 7,840',
        'Total: Php 15,100',
      ],
    );
  }

  Widget _buildNewbornPackageCard() {
    return _buildPackageCard(
      '👶 Newborn Care Package (NCP)',
      [
        'Without PhilHealth (Amount to be Paid)',
        'HCI Fees',
        'Essential Newborn Care',
        'BCG Vaccine',
        'Hepa B Vaccine',
        'Newborn Screening',
        'Hearing Test',
        'Professional Fee',
        'Total: Php 6,685',
      ],
      [
        'PhilHealth Benefits',
        'Total: Php 3,835',
      ],
      [
        'With PhilHealth (Amount to be Paid)',
        'Total: Php 2,850',
      ],
    );
  }

  Widget _buildNsdPackageCard() {
    return _buildPackageCard(
      '🤱 NSD Package (Mother and Baby)',
      [
        'Without PhilHealth (Amount to be Paid)',
        'Total: Php 32,235',
      ],
      [
        'PhilHealth Benefits',
        'Total: Php 14,235',
      ],
      [
        'With PhilHealth (Amount to be Paid)',
        'Total: Php 18,000',
      ],
      'Inclusion:\nMother:\n1 set of NSD delivery medication and supplies\nFacility / Room Charge\nDelivery Room Fee\nProfessional Fee\n\nBaby:\nEssential Newborn Care\nBCG\nHepa B Vaccine\nVitamin K\nOphthalmic Ointment\nNewborn Screening\nHearing Test\nWell Baby Clearance\n\nAdditional charges apply for excess medication and supplies.',
    );
  }

  Widget _buildPackageCard(
    String title,
    List<String> withoutPhilHealth,
    List<String> philHealthBenefits,
    List<String> withPhilHealth, [
    String inclusions = '',
  ]) {
    final isMobile = context.isMobile;

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.05), secondary.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontFamily: 'Bold',
              color: primary,
            ),
          ),
          const SizedBox(height: 20),

          // Without PhilHealth Section
          _buildPackageSection('Without PhilHealth', withoutPhilHealth),
          const SizedBox(height: 15),

          // PhilHealth Benefits Section
          _buildPackageSection('PhilHealth Benefits', philHealthBenefits),
          const SizedBox(height: 15),

          // With PhilHealth Section
          _buildPackageSection('With PhilHealth', withPhilHealth),

          if (inclusions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primary.withOpacity(0.3)),
              ),
              child: Text(
                inclusions,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontFamily: 'Regular',
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPackageSection(String title, List<String> items) {
    final isMobile = context.isMobile;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontFamily: 'Bold',
              color: primary,
            ),
          ),
          const SizedBox(height: 10),
          ...items
              .map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        fontFamily: 'Regular',
                        color: Colors.black87,
                      ),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildWhyChooseUs() {
    final isMobile = context.isMobile;

    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 40),
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
          Text(
            'WHY CHOOSE VICTORY LYING IN?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 24 : 32,
              fontFamily: 'Bold',
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 40),
          if (isMobile)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildWhyChooseUsItem(
                        Icons.verified,
                        'Experienced Staff',
                        'Highly qualified medical professionals',
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildWhyChooseUsItem(
                        Icons.medical_information,
                        'Modern Equipment',
                        'State-of-the-art medical technology',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: _buildWhyChooseUsItem(
                        Icons.favorite,
                        'Compassionate Care',
                        'Personalized attention for every patient',
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildWhyChooseUsItem(
                        Icons.price_check,
                        'Affordable Rates',
                        'Quality healthcare at reasonable prices',
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
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

  Widget _buildWhyChooseUsItem(
      IconData icon, String title, String description) {
    final isMobile = context.isMobile;

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 15 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primary,
              size: isMobile ? 35 : 45,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 14 : 18,
              fontFamily: 'Bold',
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
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
    final isMobile = context.isMobile;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 40, vertical: isMobile ? 20 : 30),
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
      child: Text(
        'We care about your health\nand well - being',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: isMobile ? 24 : 32,
          fontFamily: 'Bold',
          height: 1.3,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
