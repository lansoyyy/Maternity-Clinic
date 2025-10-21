import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maternity_clinic/utils/colors.dart';

import 'admin_prenatal_records_screen.dart';
import 'admin_postnatal_records_screen.dart';

class AdminAppointmentSchedulingScreen extends StatefulWidget {
  const AdminAppointmentSchedulingScreen({super.key});

  @override
  State<AdminAppointmentSchedulingScreen> createState() => _AdminAppointmentSchedulingScreenState();
}

class _AdminAppointmentSchedulingScreenState extends State<AdminAppointmentSchedulingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  int _scheduledCount = 0;
  int _pendingCount = 0;
  int _cancelledCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      // Fetch all appointments
      final appointmentSnapshot = await _firestore.collection('appointments').get();
      
      // Fetch all users to get patient information
      final userSnapshot = await _firestore.collection('users').get();
      
      List<Map<String, dynamic>> appointments = [];
      Map<String, dynamic> users = {};
      
      // Create a map of users for easy lookup
      for (var doc in userSnapshot.docs) {
        users[doc.id] = doc.data();
      }
      
      // Process appointments
      int scheduled = 0;
      int pending = 0;
      int cancelled = 0;
      
      for (var doc in appointmentSnapshot.docs) {
        Map<String, dynamic> appointmentData = doc.data();
        String userId = appointmentData['userId'] ?? '';
        Map<String, dynamic>? userData = users[userId];
        
        // Create appointment with user information
        Map<String, dynamic> appointment = {
          'id': doc.id,
          'status': appointmentData['status'] ?? 'Pending',
          'appointment': _formatAppointment(appointmentData),
          'reason': appointmentData['reason'] ?? '',
          'notes': appointmentData['notes'] ?? '',
          'appointmentType': appointmentData['appointmentType'] ?? 'Clinic',
        };
        
        // Add user information if available
        if (userData != null) {
          appointment['patientId'] = userData['userId'] ?? 'N/A';
          appointment['name'] = userData['name'] ?? 'Unknown';
          appointment['maternityStatus'] = userData['patientType'] ?? 'Unknown';
        } else {
          appointment['patientId'] = 'N/A';
          appointment['name'] = 'Unknown';
          appointment['maternityStatus'] = 'Unknown';
        }
        
        appointments.add(appointment);
        
        // Count by status
        String status = appointment['status'].toString().toLowerCase();
        if (status == 'accepted' || status == 'completed') {
          scheduled++;
        } else if (status == 'pending') {
          pending++;
        } else if (status == 'cancelled') {
          cancelled++;
        }
      }
      
      if (mounted) {
        setState(() {
          _appointments = appointments;
          _users = users.values.map((e) => e as Map<String, dynamic>).toList();
          _scheduledCount = scheduled;
          _pendingCount = pending;
          _cancelledCount = cancelled;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching appointments: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatAppointment(Map<String, dynamic> appointmentData) {
    String day = appointmentData['day'] ?? 'Unknown';
    String timeSlot = appointmentData['timeSlot'] ?? 'Unknown';
    return '$day, $timeSlot';
  }

  Future<void> _acceptAppointment(String appointmentId, String patientName) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'Accepted',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Appointment for $patientName has been accepted',
              style: const TextStyle(fontFamily: 'Regular'),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchAppointments(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Failed to accept appointment',
              style: TextStyle(fontFamily: 'Regular'),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _cancelAppointment(String appointmentId, String patientName) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'Cancelled',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Appointment for $patientName has been cancelled',
              style: const TextStyle(fontFamily: 'Regular'),
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchAppointments(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Failed to cancel appointment',
              style: TextStyle(fontFamily: 'Regular'),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _completeAppointment(String appointmentId, String patientName) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'Completed',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Appointment for $patientName has been marked as completed',
              style: const TextStyle(fontFamily: 'Regular'),
            ),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchAppointments(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Failed to complete appointment',
              style: TextStyle(fontFamily: 'Regular'),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

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
                      Expanded(child: _buildStatCard('$_scheduledCount', 'Scheduled appointments')),
                      const SizedBox(width: 20),
                      Expanded(child: _buildStatCard('$_pendingCount', 'Pending appointments', icon: Icons.hourglass_empty)),
                      const SizedBox(width: 20),
                      Expanded(child: _buildStatCard('$_cancelledCount', 'Cancelled appointments')),
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
                      child: _isLoading
                          ? Center(child: CircularProgressIndicator(color: primary))
                          : _appointments.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No appointments found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Regular',
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : SingleChildScrollView(
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
              _buildHeaderCell('NO.', flex: 2),
              _buildHeaderCell('NAME', flex: 3),
              _buildHeaderCell('STATUS', flex: 2),
              _buildHeaderCell('APPOINTMENT', flex: 3),
              _buildHeaderCell('MATERNITY STATUS', flex: 2),
              _buildHeaderCell('ACTIONS', flex: 2),
            ],
          ),
        ),

        // Table Rows
        ..._appointments.map((appointment) {
          return _buildTableRow(
           ( _appointments.indexOf(appointment) + 1).toString(),
            appointment['patientId'] ?? 'N/A',
            appointment['name'] ?? 'Unknown',
            appointment['status'] ?? 'Pending',
            appointment['appointment'] ?? 'Not specified',
            appointment['maternityStatus'] ?? 'Unknown',
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
    String appointmentId,
    String patientId,
    String name,
    String status,
    String appointment,
    String maternityStatus,
  ) {
    Color statusColor;
    IconData statusIcon;
    
    if (status == 'Pending') {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
    } else if (status == 'Accepted') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (status == 'Completed') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    }else {
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
          _buildTableCell(appointmentId, flex: 2),
          _buildTableCell(name, flex: 3),
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
          _buildTableCell(maternityStatus, flex: 2),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (status == 'Pending')
                  TextButton(
                    onPressed: () => _acceptAppointment(appointmentId, name),
                    child: const Text(
                      'Accept',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Bold',
                        color: Colors.green,
                      ),
                    ),
                  ),
                if (status != 'Cancelled')
                  TextButton(
                    onPressed: () => _cancelAppointment(appointmentId, name),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Bold',
                        color: Colors.red,
                      ),
                    ),
                  ),
                if (status == 'Accepted')
                  TextButton(
                    onPressed: () => _completeAppointment(appointmentId, name),
                    child: const Text(
                      'Complete',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Bold',
                        color: Colors.blue,
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
        text.isNotEmpty ? text : '-',
        style: TextStyle(
          fontSize: 11,
          fontFamily: 'Regular',
          color: text.isNotEmpty ? Colors.grey.shade700 : Colors.grey.shade400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
