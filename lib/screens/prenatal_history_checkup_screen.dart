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
                  // Top Section - Patient Information Cards
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
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
          _buildInfoRow('Patient ID:', 'P-00255-001'),
          _buildInfoRow('Name:', 'Maria Santos'),
          _buildInfoRow('Age:', '27'),
          _buildInfoRow('Address:', '123 Maharlika St., Brgy. San Isidro, Quezon City'),
          _buildInfoRow('Contact:', '0912-123-4567'),
        ],
      ),
    );
  }

  Widget _buildObstetricHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OBSTETRIC HISTORY',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Bold',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          _buildInfoRow('Gravida:', '2'),
          _buildInfoRow('Para:', '1'),
          _buildInfoRow('Last Delivery:', 'Normal'),
          _buildInfoRow('Complications:', 'None'),
          _buildInfoRow('Last Menstrual Period:', 'January 15, 2024'),
          _buildInfoRow('Expected Date of Delivery (EDD):', 'October 22, 2024'),
        ],
      ),
    );
  }

  Widget _buildMedicalHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MEDICAL HISTORY',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Bold',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          _buildInfoRow('Past Illnesses:', 'NONE'),
          _buildInfoRow('Past Surgeries:', 'NONE'),
          _buildInfoRow('Allergies:', 'No known drug allergies'),
        ],
      ),
    );
  }

  Widget _buildLaboratoryResultsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LABORATORY RESULTS',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Bold',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          _buildInfoRow('CBC:', 'Within normal limits'),
          _buildInfoRow('Urinalysis:', 'No proteins, no glucose'),
          _buildInfoRow('Blood Type:', 'O+'),
          _buildInfoRow('HbsAg:', 'Non-reactive'),
          _buildInfoRow('HIV:', 'Non-reactive'),
          _buildInfoRow('Ultrasound:', 'Normal findings'),
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
                _buildTableHeaderCell('Age of Gestation', flex: 2),
                _buildTableHeaderCell('Weight (kg)', flex: 2),
                _buildTableHeaderCell('BP (mmHg)', flex: 2),
                _buildTableHeaderCell('Fundic Height (cm)', flex: 2),
                _buildTableHeaderCell('Fetal Heart Rate (bpm)', flex: 2),
                _buildTableHeaderCell('Remarks', flex: 2),
                _buildTableHeaderCell('Risk Classification', flex: 2),
              ],
            ),
          ),

          // Table Rows
          _buildTableRow('1', 'Feb 15, 2024', '4 weeks', '52', '110/70', 'N/A', 'N/A', 'Initial checkup', 'Low Risk'),
          _buildTableRow('2', 'Mar 18, 2024', '10 weeks', '54', '115/75', 'N/A', 'N/A', 'Advised vitamins', 'Low Risk'),
          _buildTableRow('3', 'Apr 8, 2024', '15 weeks', '57', '110/70', '10', '145', 'Normal progress', 'Low Risk'),
          _buildTableRow('4', 'May 6, 2024', '18 weeks', '58', '110/75', '16', '150', 'Normal ultrasound', 'Low Risk'),
          _buildTableRow('5', 'May 27, 2024', '22 weeks', '59', '108/70', '20', '155', 'Anatomy scan done', 'Low Risk'),
          _buildTableRow('6', 'Jul 8, 2024', '26 weeks', '61', '120/80', '24', '160', 'Normal progress', 'Low Risk'),
          _buildTableRow('7', 'Aug 5, 2024', '30 weeks', '63', '125/85', '28', '155', 'Encouraged rest', 'High Risk'),
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

  Widget _buildTableRow(
    String visitNo,
    String date,
    String ageOfGestation,
    String weight,
    String bp,
    String fundicHeight,
    String fetalHeartRate,
    String remarks,
    String riskClassification,
  ) {
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
          _buildTableCell(ageOfGestation, flex: 2),
          _buildTableCell(weight, flex: 2),
          _buildTableCell(bp, flex: 2),
          _buildTableCell(fundicHeight, flex: 2),
          _buildTableCell(fetalHeartRate, flex: 2),
          _buildTableCell(remarks, flex: 2),
          _buildTableCell(riskClassification, flex: 2),
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
