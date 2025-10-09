import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'admin_prenatal_records_screen.dart';
import 'admin_postnatal_records_screen.dart';

class AdminAppointmentSchedulingScreen extends StatefulWidget {
  const AdminAppointmentSchedulingScreen({super.key});

  @override
  State<AdminAppointmentSchedulingScreen> createState() => _AdminAppointmentSchedulingScreenState();
}

class _AdminAppointmentSchedulingScreenState extends State<AdminAppointmentSchedulingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),

          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Cards Row
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('8', 'Scheduled appointments')),
                      const SizedBox(width: 20),
                      Expanded(child: _buildStatCard('1', 'Pending appointments', icon: Icons.hourglass_empty)),
                      const SizedBox(width: 20),
                      Expanded(child: _buildStatCard('1', 'Cancelled appointments')),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Appointments Table
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SingleChildScrollView(
                        child: _buildAppointmentsTable(),
                      ),
                    ),
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
          _buildMenuItem('DATA GRAPHS', false),
          _buildMenuItem('PRENATAL PATIENT\nRECORD', false),
          _buildMenuItem('POSTNATAL PATIENT\nRECORD', false),
          _buildMenuItem('APPOINTMENT\nSCHEDULING', true),
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
      case 'DATA GRAPHS':
        Navigator.pop(context);
        break;
      case 'PRENATAL PATIENT\nRECORD':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPrenatalRecordsScreen()),
        );
        break;
      case 'POSTNATAL PATIENT\nRECORD':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPostnatalRecordsScreen()),
        );
        break;
      case 'APPOINTMENT\nSCHEDULING':
        // Already on this screen
        break;
    }
  }

  Widget _buildStatCard(String number, String label, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 40, color: Colors.black87),
                const SizedBox(width: 10),
              ],
              Text(
                number,
                style: const TextStyle(
                  fontSize: 48,
                  fontFamily: 'Bold',
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Bold',
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTable() {
    final appointments = [
      {
        'patientId': 'PNL-2025-001',
        'name': 'Maria Dela Cruz',
        'status': 'PENDING',
        'appointment': 'SEP 20, 2025 10 :00 a.m',
        'contact': '0919-316-7689',
        'maternityStatus': 'Postnatal',
      },
      {
        'patientId': 'P-2025-003',
        'name': 'Liza Dela Pena',
        'status': 'SCHEDULE',
        'appointment': 'JUL 3, 2025 11:00 a.m',
        'contact': '0921-316-6789',
        'maternityStatus': 'Prenatal',
      },
      {
        'patientId': 'PNL-2025-007',
        'name': 'Erica Villanueva',
        'status': 'CANCELLED',
        'appointment': 'JUN 26, 2025 11:00 a.m',
        'contact': '0976-332-1190',
        'maternityStatus': 'Postnatal',
      },
      {
        'patientId': 'P-2025-005',
        'name': 'Karen Villanueva',
        'status': 'SCHEDULE',
        'appointment': 'JUN 26, 2025 3:47 p.m',
        'contact': '0922-567-8901',
        'maternityStatus': 'Prenatal',
      },
      {
        'patientId': 'PNL-2025-010',
        'name': 'Michelle Torres',
        'status': 'SCHEDULE',
        'appointment': 'JUN 28, 2025 8 :00 a.m',
        'contact': '0924-119-5678',
        'maternityStatus': 'Postnatal',
      },
      {
        'patientId': 'P-2025-004',
        'name': 'Jenny Robles',
        'status': 'SCHEDULE',
        'appointment': 'JUN 28, 2025 3:30 a.m',
        'contact': '0919-456-7890',
        'maternityStatus': 'Prenatal',
      },
      {
        'patientId': 'P-2025-001',
        'name': 'Maria Santos',
        'status': 'SCHEDULE',
        'appointment': 'JUN 29, 2025 11:00 a.m',
        'contact': '0917-123-4567',
        'maternityStatus': 'Prenatal',
      },
      {
        'patientId': 'PNL-2025-008',
        'name': 'Grace Fernandez',
        'status': 'SCHEDULE',
        'appointment': 'JUN 29, 2025 3:30 p.m',
        'contact': '0918-552-7788',
        'maternityStatus': 'Postnatal',
      },
      {
        'patientId': 'PNL-2025-005',
        'name': 'Christine Bautista',
        'status': 'SCHEDULE',
        'appointment': 'JUN 30, 2025 5 :00 p.m',
        'contact': '0932-876-1109',
        'maternityStatus': 'Postnatal',
      },
      {
        'patientId': 'P-2025-007',
        'name': 'Rose Ann Mendoza',
        'status': 'SCHEDULE',
        'appointment': 'JUL 31, 2025 9 :00 a.m',
        'contact': '0923-789-0123',
        'maternityStatus': 'Prenatal',
      },
    ];

    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Row(
            children: [
              _buildHeaderCell('PATIENT ID', flex: 2),
              _buildHeaderCell('NAME', flex: 2),
              _buildHeaderCell('STATUS', flex: 2),
              _buildHeaderCell('APPOINTMENT', flex: 3),
              _buildHeaderCell('CONTACT NO.', flex: 2),
              _buildHeaderCell('MATERNITY STATUS', flex: 2),
              _buildHeaderCell('ACTIONS', flex: 2),
            ],
          ),
        ),

        // Table Rows
        ...appointments.map((appointment) {
          return _buildTableRow(
            appointment['patientId']!,
            appointment['name']!,
            appointment['status']!,
            appointment['appointment']!,
            appointment['contact']!,
            appointment['maternityStatus']!,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontFamily: 'Bold',
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableRow(
    String patientId,
    String name,
    String status,
    String appointment,
    String contact,
    String maternityStatus,
  ) {
    Color statusColor;
    IconData statusIcon;
    
    if (status == 'PENDING') {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
    } else if (status == 'SCHEDULE') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          _buildTableCell(patientId, flex: 2),
          _buildTableCell(name, flex: 2),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 5),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Bold',
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          _buildTableCell(appointment, flex: 3),
          _buildTableCell(contact, flex: 2),
          _buildTableCell(maternityStatus, flex: 2),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    // Handle schedule action
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Schedule appointment for $name',
                          style: const TextStyle(fontFamily: 'Regular'),
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text(
                    'Schedule',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Bold',
                      color: Colors.green,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Handle cancel action
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Cancel appointment for $name',
                          style: const TextStyle(fontFamily: 'Regular'),
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Bold',
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontFamily: 'Regular',
          color: Colors.grey.shade700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
