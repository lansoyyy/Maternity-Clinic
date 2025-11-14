import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maternity_clinic/screens/admin/admin_transfer_requests_screen.dart';
import 'package:maternity_clinic/utils/colors.dart';

import 'admin_prenatal_records_screen.dart';
import 'admin_postnatal_records_screen.dart';
import 'admin_dashboard_screen.dart';

class AdminAppointmentSchedulingScreen extends StatefulWidget {
  final String userRole;
  final String userName;

  const AdminAppointmentSchedulingScreen({
    super.key,
    required this.userRole,
    required this.userName,
  });

  @override
  State<AdminAppointmentSchedulingScreen> createState() =>
      _AdminAppointmentSchedulingScreenState();
}

class _AdminAppointmentSchedulingScreenState
    extends State<AdminAppointmentSchedulingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  int _scheduledCount = 0;
  int _pendingCount = 0;
  int _cancelledCount = 0;
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      // Fetch all appointments
      final appointmentSnapshot =
          await _firestore.collection('appointments').get();

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
    // Handle new appointment structure with appointmentDate
    if (appointmentData.containsKey('appointmentDate')) {
      Timestamp dateTimestamp = appointmentData['appointmentDate'];
      DateTime date = dateTimestamp.toDate();
      String timeSlot = appointmentData['timeSlot'] ?? 'Unknown';
      return '${_formatDate(date)}, $timeSlot';
    }

    // Handle old structure for backward compatibility
    String day = appointmentData['day'] ?? 'Unknown';
    String timeSlot = appointmentData['timeSlot'] ?? 'Unknown';
    return '$day, $timeSlot';
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Future<void> _acceptAppointment(
      String appointmentId, String patientName) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'Accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
        'acceptedBy': widget.userName,
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

  Future<void> _cancelAppointment(
      String appointmentId, String patientName) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'Cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancelledBy': widget.userName,
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

  Future<void> _completeAppointment(
      String appointmentId, String patientName) async {
    // Show confirmation dialog
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Complete Appointment',
            style: const TextStyle(fontFamily: 'Bold'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patient: $patientName',
                style: const TextStyle(
                  fontFamily: 'Regular',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Are you sure you want to mark this appointment as completed?',
                style: TextStyle(fontFamily: 'Regular'),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Text(
                  'This will:\n• Mark appointment as completed\n• Add completion timestamp\n• Update patient records',
                  style: TextStyle(
                    fontFamily: 'Regular',
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(
                    color: Colors.grey.shade600, fontFamily: 'Regular'),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Complete',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Bold',
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _firestore.collection('appointments').doc(appointmentId).update({
          'status': 'Completed',
          'completedAt': FieldValue.serverTimestamp(),
          'completedBy': widget.userName,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Appointment for $patientName has been marked as completed',
                style: const TextStyle(fontFamily: 'Regular'),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
          _fetchAppointments(); // Refresh the list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to complete appointment: $e',
                style: const TextStyle(fontFamily: 'Regular'),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _rescheduleAppointment(String appointmentId, String patientName,
      Map<String, dynamic> currentAppointment) async {
    // Show dialog to select new date and time
    DateTime? selectedDate;
    String? selectedTime;

    // Available time slots matching the patient booking system
    List<String> availableTimeSlots = [
      '8:00 AM',
      '10:00 AM',
      '12:00 PM',
      '2:00 PM'
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Reschedule Appointment',
                style: const TextStyle(fontFamily: 'Bold'),
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient: $patientName',
                      style: const TextStyle(
                        fontFamily: 'Regular',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Current: ${currentAppointment['appointment']}',
                      style: const TextStyle(fontFamily: 'Regular'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Select New Date:',
                      style: TextStyle(
                        fontFamily: 'Bold',
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate:
                              DateTime.now().add(const Duration(days: 1)),
                          firstDate:
                              DateTime.now().add(const Duration(days: 1)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          selectedDate != null
                              ? _formatDate(selectedDate!)
                              : 'Select Date',
                          style: TextStyle(
                            fontFamily: 'Regular',
                            color: selectedDate != null
                                ? Colors.black87
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Select New Time:',
                      style: TextStyle(
                        fontFamily: 'Bold',
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableTimeSlots.map((time) {
                        bool isSelected = selectedTime == time;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTime = time;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? primary : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              time,
                              style: TextStyle(
                                fontFamily: 'Regular',
                                fontSize: 12,
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontFamily: 'Regular'),
                  ),
                ),
                ElevatedButton(
                  onPressed: selectedDate != null && selectedTime != null
                      ? () async {
                          Navigator.pop(context);
                          await _updateAppointment(appointmentId, patientName,
                              selectedDate!, selectedTime!);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                  ),
                  child: const Text(
                    'Reschedule',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Bold',
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateAppointment(String appointmentId, String patientName,
      DateTime newDate, String newTime) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'appointmentDate': Timestamp.fromDate(newDate),
        'timeSlot': newTime,
        'rescheduledAt': FieldValue.serverTimestamp(),
        'status': 'Rescheduled',
        'rescheduleReason': 'Admin rescheduled appointment',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Appointment for $patientName has been rescheduled to ${_formatDate(newDate)}, $newTime',
              style: const TextStyle(fontFamily: 'Regular'),
            ),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
        _fetchAppointments(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to reschedule appointment: $e',
              style: const TextStyle(fontFamily: 'Regular'),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
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
                      Expanded(
                          child: _buildStatCard(
                              '$_scheduledCount', 'Scheduled appointments')),
                      const SizedBox(width: 20),
                      Expanded(
                          child: _buildStatCard(
                              '$_pendingCount', 'Pending appointments',
                              icon: Icons.hourglass_empty)),
                      const SizedBox(width: 20),
                      Expanded(
                          child: _buildStatCard(
                              '$_cancelledCount', 'Cancelled appointments')),
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
                          ? Center(
                              child: CircularProgressIndicator(color: primary))
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
                              : Scrollbar(
                                  controller: _horizontalScrollController,
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    controller: _horizontalScrollController,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: _buildAppointmentsTable(),
                                    ),
                                  ),
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
              children: [
                Text(
                  widget.userName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Bold',
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.userRole.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'Medium',
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
          _buildMenuItem('TRANSFER\nREQUESTS', false),
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
            color:
                isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDashboardScreen(
              userRole: widget.userRole,
              userName: widget.userName,
            ),
          ),
        );
        break;
      case 'PRENATAL PATIENT\nRECORD':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminPrenatalRecordsScreen(
              userRole: widget.userRole,
              userName: widget.userName,
            ),
          ),
        );
        break;
      case 'POSTNATAL PATIENT\nRECORD':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminPostnatalRecordsScreen(
              userRole: widget.userRole,
              userName: widget.userName,
            ),
          ),
        );
        break;
      case 'APPOINTMENT\nSCHEDULING':
        // Already on this screen
        break;
      case 'TRANSFER\nREQUESTS':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminTransferRequestsScreen(
              userRole: widget.userRole,
              userName: widget.userName,
            ),
          ),
        );
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
    const double columnWidth = 120.0;

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
              SizedBox(
                width: columnWidth * 0.8,
                child: _buildHeaderCell('NO.'),
              ),
              SizedBox(
                width: columnWidth * 1.2,
                child: _buildHeaderCell('NAME'),
              ),
              SizedBox(
                width: columnWidth * 1.5,
                child: _buildHeaderCell('STATUS (with timestamps)'),
              ),
              SizedBox(
                width: columnWidth * 1.3,
                child: _buildHeaderCell('APPOINTMENT'),
              ),
              SizedBox(
                width: columnWidth * 1.2,
                child: _buildHeaderCell('MATERNITY STATUS'),
              ),
              SizedBox(
                width: columnWidth * 2.5,
                child: _buildHeaderCell('ACTIONS'),
              ),
            ],
          ),
        ),

        // Table Rows
        ..._appointments.map((appointment) {
          return _buildTableRow(
            appointment['id'] ?? '', // This is the actual appointment ID
            (_appointments.indexOf(appointment) + 1)
                .toString(), // This is the row number
            appointment['name'] ?? 'Unknown',
            appointment['status'] ?? 'Pending',
            appointment['appointment'] ?? 'Not specified',
            appointment['maternityStatus'] ?? 'Unknown',
            appointment, // Pass full appointment data for timestamps
          );
        }).toList(),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontFamily: 'Bold',
        color: Colors.black87,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTableRow(
    String appointmentId,
    String rowNumber,
    String name,
    String status,
    String appointment,
    String maternityStatus,
    Map<String, dynamic> appointmentData,
  ) {
    Color statusColor;
    IconData statusIcon;

    if (status == 'Pending') {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
    } else if (status == 'Accepted') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (status == 'Rescheduled') {
      statusColor = Colors.blue;
      statusIcon = Icons.event;
    } else if (status == 'Completed') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    }

    // Format timestamps for display
    String statusTimestamp = '';
    if (appointmentData['acceptedAt'] != null && status == 'Accepted') {
      final timestamp = appointmentData['acceptedAt'] as Timestamp;
      final date = timestamp.toDate();
      statusTimestamp = 'Accepted: ${_formatDateTime(date)}';
    } else if (appointmentData['rescheduledAt'] != null &&
        status == 'Rescheduled') {
      final timestamp = appointmentData['rescheduledAt'] as Timestamp;
      final date = timestamp.toDate();
      statusTimestamp = 'Rescheduled: ${_formatDateTime(date)}';
    } else if (appointmentData['completedAt'] != null &&
        status == 'Completed') {
      final timestamp = appointmentData['completedAt'] as Timestamp;
      final date = timestamp.toDate();
      final completedBy = appointmentData['completedBy'] ?? 'System';
      statusTimestamp = 'Completed: ${_formatDateTime(date)} by $completedBy';
    } else if (appointmentData['cancelledAt'] != null &&
        status == 'Cancelled') {
      final timestamp = appointmentData['cancelledAt'] as Timestamp;
      final date = timestamp.toDate();
      statusTimestamp = 'Cancelled: ${_formatDateTime(date)}';
    }

    const double columnWidth = 120.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // NO. Column
          SizedBox(
            width: columnWidth * 0.8,
            child: _buildTableCell(rowNumber),
          ),
          // NAME Column
          SizedBox(
            width: columnWidth * 1.2,
            child: _buildTableCell(name),
          ),
          // STATUS Column
          SizedBox(
            width: columnWidth * 1.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
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
                if (statusTimestamp.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    statusTimestamp,
                    style: TextStyle(
                      fontSize: 9,
                      fontFamily: 'Regular',
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // APPOINTMENT Column
          SizedBox(
            width: columnWidth * 1.3,
            child: _buildTableCell(appointment),
          ),
          // MATERNITY STATUS Column
          SizedBox(
            width: columnWidth * 1.2,
            child: _buildTableCell(maternityStatus),
          ),
          // ACTIONS Column
          SizedBox(
            width: columnWidth * 2.5,
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
                if (status == 'Accepted' || status == 'Rescheduled')
                  TextButton(
                    onPressed: () =>
                        _rescheduleAppointment(appointmentId, name, {
                      'appointment': appointment,
                      'status': status,
                    }),
                    child: const Text(
                      'Reschedule',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Bold',
                        color: Colors.orange,
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
                if (status == 'Accepted' || status == 'Rescheduled')
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildTableCell(String text) {
    return Text(
      text.isNotEmpty ? text : '-',
      style: TextStyle(
        fontSize: 11,
        fontFamily: 'Regular',
        color: text.isNotEmpty ? Colors.grey.shade700 : Colors.grey.shade400,
      ),
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );
  }
}
