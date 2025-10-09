import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'prenatal_history_checkup_screen.dart';
import 'notification_appointment_screen.dart';
import 'transfer_record_request_screen.dart';

class PrenatalDashboardScreen extends StatefulWidget {
  const PrenatalDashboardScreen({super.key});

  @override
  State<PrenatalDashboardScreen> createState() => _PrenatalDashboardScreenState();
}

class _PrenatalDashboardScreenState extends State<PrenatalDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Healthy Pregnancy, Healthy Baby: A Guide to\nPrenatal Care',
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: 'Bold',
                      color: Colors.black,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Guide Items Grid
                  _buildGuideGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, secondary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          // User Info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'DELA CRUZ,',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Bold',
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'JUAN B.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Bold',
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Menu Items
          _buildMenuItem('EDUCATIONAL\nLEARNERS', false),
          _buildMenuItem('HISTORY OF\nCHECK UP', false),
          _buildMenuItem('NOTIFICATION\nAPPOINTMENT', false),
          _buildMenuItem('TRANSFER OF\nRECORD REQUEST', false),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, bool isActive) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Handle menu navigation
          if (title == 'HISTORY OF\nCHECK UP') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrenatalHistoryCheckupScreen()),
            );
          } else if (title == 'NOTIFICATION\nAPPOINTMENT') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationAppointmentScreen(patientType: 'PRENATAL')),
            );
          } else if (title == 'TRANSFER OF\nRECORD REQUEST') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TransferRecordRequestScreen(patientType: 'PRENATAL')),
            );
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isActive ? Colors.white : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: isActive ? 'Bold' : 'Medium',
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideGrid() {
    final guides = [
      {
        'number': '1',
        'title': 'Schedule Your First Prenatal Visit',
        'description': 'Book an appointment as soon as you find out you\'re pregnant.',
      },
      {
        'number': '2',
        'title': 'Attend Checkups',
        'description': 'Follow your doctor\'s recommended prenatal visit schedule.',
      },
      {
        'number': '3',
        'title': 'Get Tests',
        'description': 'Follow your doctor\'s advice for ultrasounds, labs, and screenings.',
      },
      {
        'number': '4',
        'title': 'Discuss Concerns',
        'description': 'Share symptoms, medications, and lifestyle openly with your doctor.',
      },
      {
        'number': '5',
        'title': 'Follow Medical Advice',
        'description': 'Take prescribed supplements, maintain healthy habits, and follow up on clinic instructions.',
      },
      {
        'number': '6',
        'title': 'Eat Nutritious Meals',
        'description': 'Choose fruits, veggies, grains, and protein; limit processed foods.',
      },
      {
        'number': '7',
        'title': 'Take Prenatal Vitamins',
        'description': 'Take prescribed folic acid, iron, and calcium daily.',
      },
      {
        'number': '8',
        'title': 'Stay Hydrated & Active',
        'description': 'Drink water and do light daily exercise.',
      },
      {
        'number': '9',
        'title': 'Get Proper Rest',
        'description': 'Sleep 7–9 hours, nap when needed, and rest on your side.',
      },
      {
        'number': '10',
        'title': 'Practice Safety',
        'description': 'Avoid alcohol, smoking, and unsafe medicines; follow doctor\'s advice.',
      },
    ];

    return Wrap(
      spacing: 30,
      runSpacing: 30,
      children: guides.map((guide) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 250 - 120) / 2,
          child: _buildGuideCard(
            guide['number']!,
            guide['title']!,
            guide['description']!,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGuideCard(String number, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number Circle
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFB8764F),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 22,
                  fontFamily: 'Bold',
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Bold',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Regular',
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
