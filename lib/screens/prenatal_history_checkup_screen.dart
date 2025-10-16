import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';
import 'prenatal_dashboard_screen.dart';
import 'notification_appointment_screen.dart';
import 'transfer_record_request_screen.dart';

class PrenatalHistoryCheckupScreen extends StatefulWidget {
  const PrenatalHistoryCheckupScreen({super.key});

  @override
  State<PrenatalHistoryCheckupScreen> createState() => _PrenatalHistoryCheckupScreenState();
}

class _PrenatalHistoryCheckupScreenState extends State<PrenatalHistoryCheckupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _userName = 'Loading...';
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _completedAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadUserData();
    _loadCompletedAppointments();
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
          if (mounted) {
            setState(() {
              _userName = userData['name'] ?? 'User';
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userName = 'User';
        });
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists && mounted) {
          setState(() {
            _userData = userDoc.data() as Map<String, dynamic>;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadCompletedAppointments() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot appointmentSnapshot = await _firestore
            .collection('appointments')
            .where('userId', isEqualTo: user.uid)
            .where('status', isEqualTo: 'Completed')
            .get();

        List<Map<String, dynamic>> appointments = [];
        for (var doc in appointmentSnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          appointments.add(data);
        }

        // Sort in memory by createdAt
        appointments.sort((a, b) {
          var aTime = a['createdAt'];
          var bTime = b['createdAt'];
          if (aTime == null || bTime == null) return 0;
          return (aTime as Timestamp).compareTo(bTime as Timestamp);
        });

        if (mounted) {
          setState(() {
            _completedAppointments = appointments;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error loading appointments: $e');
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
                  // Page Title
                  const Text(
                    'Prenatal Checkup History',
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: 'Bold',
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'View your completed prenatal appointments and checkup records',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Regular',
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Patient Information Card
                  _buildPatientInfoCard(),
                  const SizedBox(height: 30),

                  // All Completed Appointments Summary
                  if (_completedAppointments.isNotEmpty) ...[
                    const Text(
                      'Completed Appointments Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Bold',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ..._completedAppointments.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> appointment = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildAppointmentSummaryCard(appointment, index + 1),
                      );
                    }).toList(),
                    const SizedBox(height: 30),
                  ],

                  // Checkup History Table
                  const Text(
                    'Appointment History',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Bold',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildCheckupHistoryTable(),
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
                  'PRENATAL PATIENT',
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
          _buildMenuItem('HISTORY OF\nCHECK UP', true),
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PrenatalDashboardScreen()),
        );
        break;
      case 'HISTORY OF\nCHECK UP':
        // Already on this screen
        break;
      case 'NOTIFICATION\nAPPOINTMENT':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NotificationAppointmentScreen(patientType: 'PRENATAL')),
        );
        break;
      case 'TRANSFER OF\nRECORD REQUEST':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TransferRecordRequestScreen(patientType: 'PRENATAL')),
        );
        break;
    }
  }

  Widget _buildPatientInfoCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.1), secondary.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userData?['name'] ?? 'Loading...',
                  style: const TextStyle(
                    fontSize: 22,
                    fontFamily: 'Bold',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.email, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      _userData?['email'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Regular',
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      _userData?['contact'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Regular',
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  '${_completedAppointments.length}',
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'Bold',
                    color: primary,
                  ),
                ),
                Text(
                  'Completed',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Regular',
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentSummaryCard(Map<String, dynamic> appointment, int visitNumber) {
    String date = 'N/A';
    if (appointment['createdAt'] != null) {
      try {
        DateTime dateTime = (appointment['createdAt'] as Timestamp).toDate();
        date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } catch (e) {
        date = 'N/A';
      }
    }

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '#$visitNumber',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Bold',
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['appointmentType'] ?? 'Clinic',
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Bold',
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Completed on $date',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Regular',
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  appointment['status'] ?? 'Completed',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Bold',
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Details in 3 columns
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: Schedule
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: primary),
                        const SizedBox(width: 6),
                        const Text(
                          'Schedule',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Bold',
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Day:', appointment['day'] ?? 'N/A'),
                    _buildInfoRow('Time:', appointment['timeSlot'] ?? 'N/A'),
                  ],
                ),
              ),
              // Column 2: Reason
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.medical_services, size: 16, color: primary),
                        const SizedBox(width: 6),
                        const Text(
                          'Reason',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Bold',
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appointment['reason'] ?? 'Not specified',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Regular',
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // Column 3: Notes
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.note_alt, size: 16, color: primary),
                        const SizedBox(width: 6),
                        const Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Bold',
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appointment['notes']?.toString().isNotEmpty == true
                          ? appointment['notes']
                          : 'No notes',
                      style: TextStyle(
                        fontSize: 12,
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
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Bold',
                color: Colors.black87,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Regular',
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckupHistoryTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                _buildTableHeaderCell('Visit No.', flex: 1),
                _buildTableHeaderCell('Date', flex: 2),
                _buildTableHeaderCell('Day', flex: 2),
                _buildTableHeaderCell('Time Slot', flex: 2),
                _buildTableHeaderCell('Type', flex: 2),
                _buildTableHeaderCell('Reason', flex: 3),
                _buildTableHeaderCell('Notes', flex: 3),
              ],
            ),
          ),

          // Table Rows - Dynamic from Firestore
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(color: primary),
              ),
            )
          else if (_completedAppointments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Text(
                  'No completed checkups yet',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Regular',
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            )
          else
            ..._completedAppointments.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> appointment = entry.value;
              return _buildTableRowFromAppointment(
                (index + 1).toString(),
                appointment,
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text, {int flex = 1}) {
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

  Widget _buildTableRowFromAppointment(String visitNo, Map<String, dynamic> appointment) {
    String date = 'N/A';
    if (appointment['createdAt'] != null) {
      try {
        DateTime dateTime;
        if (appointment['createdAt'] is Timestamp) {
          dateTime = (appointment['createdAt'] as Timestamp).toDate();
        } else {
          dateTime = DateTime.now();
        }
        date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } catch (e) {
        date = 'N/A';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          _buildTableCell(visitNo, flex: 1),
          _buildTableCell(date, flex: 2),
          _buildTableCell(appointment['day'] ?? 'N/A', flex: 2),
          _buildTableCell(appointment['timeSlot'] ?? 'N/A', flex: 2),
          _buildTableCell(appointment['appointmentType'] ?? 'N/A', flex: 2),
          _buildTableCell(appointment['reason'] ?? 'N/A', flex: 3),
          _buildTableCell(appointment['notes'] ?? '-', flex: 3),
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
