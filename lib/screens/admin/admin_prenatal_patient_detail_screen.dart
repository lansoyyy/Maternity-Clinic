import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/colors.dart';

class AdminPrenatalPatientDetailScreen extends StatefulWidget {
  final Map<String, String> patientData;

  const AdminPrenatalPatientDetailScreen({
    super.key,
    required this.patientData,
  });

  @override
  State<AdminPrenatalPatientDetailScreen> createState() => _AdminPrenatalPatientDetailScreenState();
}

class _AdminPrenatalPatientDetailScreenState extends State<AdminPrenatalPatientDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

  Future<void> _fetchPatientData() async {
    try {
      // Fetch appointments for this patient
      final appointmentsSnapshot = await _firestore
          .collection('appointments')
          .where('userId', isEqualTo: widget.patientData['patientId'])
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> appointments = [];
      for (var doc in appointmentsSnapshot.docs) {
        Map<String, dynamic> appointment = doc.data();
        appointment['id'] = doc.id;
        appointments.add(appointment);
      }

      // Fetch medical records (if you have a separate collection)
      // For now, we'll use appointments as records
      
      if (mounted) {
        setState(() {
          _appointments = appointments;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching patient data: $e');
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
      backgroundColor: Colors.grey.shade100,
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),

          // Main Content
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primary))
                : SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back, size: 28),
                        color: Colors.black87,
                        tooltip: 'Back to Records',
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Patient Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Bold',
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Top Section - Information Cards
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildPatientInfoCard()),
                      const SizedBox(width: 20),
                      Expanded(child: _buildObstetricHistoryCard()),
                      const SizedBox(width: 20),
                      Expanded(child: _buildMedicalHistoryCard()),
                      const SizedBox(width: 20),
                      Expanded(child: _buildLaboratoryResultsCard()),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Checkup History Table
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
          _buildMenuItem('PRENATAL PATIENT\nRECORD', true),
          _buildMenuItem('POSTNATAL PATIENT\nRECORD', false),
          _buildMenuItem('APPOINTMENT\nSCHEDULING', false),
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
            Navigator.pop(context);
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

  Widget _buildPatientInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PATIENT INFORMATION',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Bold',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          if (widget.patientData['patientId'] != null && widget.patientData['patientId']!.isNotEmpty)
            _buildInfoRow('Patient ID:', widget.patientData['patientId']!),
          if (widget.patientData['name'] != null && widget.patientData['name']!.isNotEmpty)
            _buildInfoRow('Name:', widget.patientData['name']!),
          if (widget.patientData['email'] != null && widget.patientData['email']!.isNotEmpty)
            _buildInfoRow('Email:', widget.patientData['email']!),
          if (widget.patientData['status'] != null && widget.patientData['status']!.isNotEmpty)
            _buildInfoRow('Status:', widget.patientData['status']!),
          const SizedBox(height: 10),
          Text(
            'Additional patient information will be added during medical consultations.',
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'Regular',
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObstetricHistoryCard() {
    int totalAppointments = _appointments.length;
    int pendingCount = _appointments.where((a) => a['status'] == 'Pending').length;
    int acceptedCount = _appointments.where((a) => a['status'] == 'Accepted').length;
    int completedCount = _appointments.where((a) => a['status'] == 'Completed').length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'APPOINTMENT SUMMARY',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Bold',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          _buildInfoRow('Total Appointments:', totalAppointments.toString()),
          _buildInfoRow('Pending:', pendingCount.toString()),
          _buildInfoRow('Accepted:', acceptedCount.toString()),
          _buildInfoRow('Completed:', completedCount.toString()),
          const SizedBox(height: 10),
          if (totalAppointments == 0)
            Text(
              'No appointments yet',
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'Regular',
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicalHistoryCard() {
    // Get latest appointment if exists
    String latestAppointment = 'No appointments';
    String nextAppointment = 'No upcoming appointments';
    
    if (_appointments.isNotEmpty) {
      var latest = _appointments.first;
      latestAppointment = _formatDate(latest['createdAt']);
      
      // Find next accepted appointment
      var upcoming = _appointments.where((a) => a['status'] == 'Accepted').toList();
      if (upcoming.isNotEmpty) {
        nextAppointment = '${upcoming.first['day']} - ${upcoming.first['timeSlot']}';
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'APPOINTMENT SCHEDULE',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Bold',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          _buildInfoRow('Latest Appointment:', latestAppointment),
          const SizedBox(height: 5),
          _buildInfoRow('Next Scheduled:', nextAppointment),
          const SizedBox(height: 10),
          Text(
            'Patient Type: PRENATAL',
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'Bold',
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaboratoryResultsCard() {
    int cancelledCount = _appointments.where((a) => a['status'] == 'Cancelled').length;
    String accountStatus = widget.patientData['status'] ?? 'Active';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACCOUNT STATUS',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Bold',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accountStatus == 'Active' ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  accountStatus.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'Bold',
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildInfoRow('Email:', widget.patientData['email'] ?? 'N/A'),
          const SizedBox(height: 5),
          _buildInfoRow('Cancelled Appointments:', cancelledCount.toString()),
          const SizedBox(height: 10),
          Text(
            'All appointment history is shown below',
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'Regular',
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
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
    if (_appointments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.event_note_outlined, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 20),
              const Text(
                'No Appointment Records',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Bold',
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Appointment records will appear here after the patient books appointments.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Regular',
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                _buildTableHeaderCell('No.', flex: 1),
                _buildTableHeaderCell('Date', flex: 2),
                _buildTableHeaderCell('Day', flex: 2),
                _buildTableHeaderCell('Time Slot', flex: 2),
                _buildTableHeaderCell('Status', flex: 2),
                _buildTableHeaderCell('Patient Type', flex: 2),
              ],
            ),
          ),

          // Table Rows
          ..._appointments.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> appointment = entry.value;
            return _buildAppointmentRow(
              (index + 1).toString(),
              _formatDate(appointment['createdAt']),
              appointment['day'] ?? 'N/A',
              appointment['timeSlot'] ?? 'N/A',
              appointment['status'] ?? 'Pending',
              appointment['patientType'] ?? 'PRENATAL',
            );
          }).toList(),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      DateTime date = (timestamp as Timestamp).toDate();
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
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

  Widget _buildAppointmentRow(
    String no,
    String date,
    String day,
    String timeSlot,
    String status,
    String patientType,
  ) {
    Color statusColor;
    if (status == 'Pending') {
      statusColor = Colors.orange;
    } else if (status == 'Accepted') {
      statusColor = Colors.green;
    } else if (status == 'Completed') {
      statusColor = Colors.blue;
    } else if (status == 'Cancelled') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.grey;
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
          _buildTableCell(no, flex: 1),
          _buildTableCell(date, flex: 2),
          _buildTableCell(day, flex: 2),
          _buildTableCell(timeSlot, flex: 2),
          Expanded(
            flex: 2,
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'Bold',
                color: statusColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          _buildTableCell(patientType, flex: 2),
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
