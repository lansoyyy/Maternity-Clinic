import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'prenatal_dashboard_screen.dart';
import 'postnatal_dashboard_screen.dart';
import 'prenatal_history_checkup_screen.dart';
import 'postnatal_history_checkup_screen.dart';
import 'transfer_record_request_screen.dart';

class NotificationAppointmentScreen extends StatefulWidget {
  final String patientType; // 'PRENATAL' or 'POSTNATAL'
  
  const NotificationAppointmentScreen({
    super.key,
    required this.patientType,
  });

  @override
  State<NotificationAppointmentScreen> createState() => _NotificationAppointmentScreenState();
}

class _NotificationAppointmentScreenState extends State<NotificationAppointmentScreen> {
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Upcoming Appointment
                  _buildNotificationCard(
                    'Next Schedule Appointment',
                    'Sept 20, 2025,  10:00 AM',
                    'Upcoming',
                    Colors.grey.shade300,
                  ),
                  const SizedBox(height: 20),

                  // Tomorrow Reminder
                  _buildNotificationCard(
                    'Reminder: ${widget.patientType == 'PRENATAL' ? 'Prenatal' : 'Postnatal'} Check-up',
                    'Sept 20, 2025,  10:00 AM',
                    'Tomorrow',
                    Colors.grey.shade300,
                  ),
                  const SizedBox(height: 20),

                  // Today Appointment
                  _buildNotificationCard(
                    'Today Appointment',
                    'Sept 14, 2025,  2:00 PM',
                    'Today',
                    Colors.grey.shade300,
                  ),
                  const SizedBox(height: 20),

                  // Rescheduled Appointment
                  _buildNotificationCard(
                    'Your appointment has been moved\nto Sept 14, 2025  at 1:00 PM',
                    '',
                    'Rescheduled',
                    Colors.grey.shade300,
                  ),
                  const SizedBox(height: 20),

                  // Missed Appointment
                  _buildNotificationCard(
                    'You missed your ${widget.patientType == 'PRENATAL' ? 'Prenatal' : 'Postnatal'} check-up\nscheduled yesterday',
                    '',
                    'Missed',
                    Colors.grey.shade300,
                  ),
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
          _buildMenuItem('NOTIFICATION\nAPPOINTMENT', true),
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
          if (!isActive) {
            _handleNavigation(title);
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

  void _handleNavigation(String title) {
    switch (title) {
      case 'EDUCATIONAL\nLEARNERS':
        if (widget.patientType == 'PRENATAL') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PrenatalDashboardScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PostnatalDashboardScreen()),
          );
        }
        break;
      case 'HISTORY OF\nCHECK UP':
        if (widget.patientType == 'PRENATAL') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PrenatalHistoryCheckupScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PostnatalHistoryCheckupScreen()),
          );
        }
        break;
      case 'NOTIFICATION\nAPPOINTMENT':
        // Already on this screen
        break;
      case 'TRANSFER OF\nRECORD REQUEST':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TransferRecordRequestScreen(patientType: widget.patientType)),
        );
        break;
    }
  }

  Widget _buildNotificationCard(
    String title,
    String subtitle,
    String status,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Content
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
                    height: 1.4,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Regular',
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Right Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Bold',
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
