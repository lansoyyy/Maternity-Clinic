import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';
import 'postnatal_history_checkup_screen.dart';
import 'notification_appointment_screen.dart';
import 'transfer_record_request_screen.dart';

class PostnatalDashboardScreen extends StatefulWidget {
  const PostnatalDashboardScreen({super.key});

  @override
  State<PostnatalDashboardScreen> createState() => _PostnatalDashboardScreenState();
}

class _PostnatalDashboardScreenState extends State<PostnatalDashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _userName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _userName = userData['name'] ?? 'User';
          });
        }
      }
    } catch (e) {
      setState(() {
        _userName = 'User';
      });
    }
  }

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
                    'Life After Birth: Essential Postnatal Care Tips',
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
              children: [
                Text(
                  _userName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Bold',
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'POSTNATAL PATIENT',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'Regular',
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
              MaterialPageRoute(builder: (context) => const PostnatalHistoryCheckupScreen()),
            );
          } else if (title == 'NOTIFICATION\nAPPOINTMENT') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationAppointmentScreen(patientType: 'POSTNATAL')),
            );
          } else if (title == 'TRANSFER OF\nRECORD REQUEST') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TransferRecordRequestScreen(patientType: 'POSTNATAL')),
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
        'title': 'Rest When You Can',
        'description': 'Sleep while your baby sleeps, to help your body recover.',
      },
      {
        'number': '2',
        'title': 'Eat Nutritious Foods',
        'description': 'Continue a healthy diet with fruits, vegetables, lean protein, and whole grains.',
      },
      {
        'number': '3',
        'title': 'Stay Hydrated',
        'description': 'Drink enough water, especially if you\'re breastfeeding.',
      },
      {
        'number': '4',
        'title': 'Take Prescribed Supplements',
        'description': 'Follow your doctor\'s advice on vitamins and iron after delivery.',
      },
      {
        'number': '5',
        'title': 'Practice Good Hygiene',
        'description': 'Keep your body and stitches (if any) clean to avoid infection.',
      },
      {
        'number': '6',
        'title': 'Manage Pain',
        'description': 'Follow doctor-approved relief methods and report unusual discomfort.',
      },
      {
        'number': '7',
        'title': 'Feed Safely',
        'description': 'Breastfeed or bottle-feed properly to support your baby\'s nutrition.',
      },
      {
        'number': '8',
        'title': 'Watch for Warning Signs',
        'description': 'Seek care for fever, heavy bleeding, pain, or mood changes.',
      },
      {
        'number': '9',
        'title': 'Do Gentle Exercises',
        'description': 'Begin light activities only with your doctor\'s approval.',
      },
      {
        'number': '10',
        'title': 'Seek Support',
        'description': 'Reach out to loved ones or professionals if you feel overwhelmed.',
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
