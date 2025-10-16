import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';
import 'prenatal_dashboard_screen.dart';
import 'postnatal_dashboard_screen.dart';
import 'prenatal_history_checkup_screen.dart';
import 'postnatal_history_checkup_screen.dart';
import 'transfer_record_request_screen.dart';
import '../widgets/book_appointment_dialog.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _userName = 'Loading...';
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadUserAppointments();
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

  Future<void> _loadUserAppointments() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        print('Current User UID: ${user.uid}');

        // Query without orderBy to avoid index requirement
        QuerySnapshot appointmentSnapshot = await _firestore
            .collection('appointments')
            .where('userId', isEqualTo: user.uid)
            .get();

        print('Appointments found for current user: ${appointmentSnapshot.docs.length}');

        List<Map<String, dynamic>> appointments = [];
        for (var doc in appointmentSnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          appointments.add(data);
          print('Appointment: ${data['reason']} - Status: ${data['status']}');
        }

        // Sort in memory instead of in query
        appointments.sort((a, b) {
          var aTime = a['createdAt'];
          var bTime = b['createdAt'];
          if (aTime == null || bTime == null) return 0;
          return (bTime as Timestamp).compareTo(aTime as Timestamp);
        });

        if (mounted) {
          setState(() {
            _appointments = appointments;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading appointments: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (context) => BookAppointmentDialog(
              patientType: widget.patientType,
            ),
          );
          
          // Refresh appointments if booking was successful
          if (result == true) {
            _loadUserAppointments();
          }
        },
        backgroundColor: primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Book Appointment',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Bold',
          ),
        ),
      ),
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
                  // Title
                  Text(
                    'My Appointments',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Bold',
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'View and manage your scheduled appointments',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Regular',
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Loading State
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE91E63),
                      ),
                    )

                  // Appointments List
                  else if (_appointments.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No Appointments Yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Bold',
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Book your first appointment using the button below',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Regular',
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ..._appointments.map((appointment) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildAppointmentCard(appointment),
                    )),
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
                Text(
                  '${widget.patientType} PATIENT',
                  style: const TextStyle(
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

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    String status = appointment['status'] ?? 'Pending';
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'Confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Type and Status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  appointment['appointmentType'] ?? 'Clinic',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Bold',
                    color: primary,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Bold',
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Appointment Details
          Row(
            children: [
              // Left Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${appointment['day'] ?? 'Unknown Day'}, ${appointment['timeSlot'] ?? 'Unknown Time'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Bold',
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reason: ${appointment['reason'] ?? 'Not specified'}',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Regular',
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (appointment['notes'] != null && appointment['notes'].toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Notes: ${appointment['notes']}',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Regular',
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Timestamp
          if (appointment['createdAt'] != null)
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  'Booked on ${_formatTimestamp(appointment['createdAt'])}',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Regular',
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    try {
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else {
        date = DateTime.now();
      }
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
