import 'package:flutter/material.dart';
import '../utils/colors.dart';

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
            child: SingleChildScrollView(
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
          _buildInfoRow('Patient ID:', widget.patientData['patientId'] ?? 'P-2025-001'),
          _buildInfoRow('Name:', widget.patientData['name'] ?? 'Maria Santos'),
          _buildInfoRow('Age:', widget.patientData['age'] ?? '27'),
          _buildInfoRow('Address:', widget.patientData['address'] ?? '123 Mabini St., Brgy. San Isidro, Quezon City'),
          _buildInfoRow('Contact:', widget.patientData['contact'] ?? '0917-123-4567'),
        ],
      ),
    );
  }

  Widget _buildObstetricHistoryCard() {
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
          _buildInfoRow('Complications:', 'Spontaneous Vaginal Delivery (2020)'),
          _buildInfoRow('Last Menstrual Period (LMP):', 'January 15, 2025'),
          _buildInfoRow('Expected Date of Delivery (EDD):', 'October 22, 2025'),
        ],
      ),
    );
  }

  Widget _buildMedicalHistoryCard() {
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
        color: Colors.grey.shade200,
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
          _buildInfoRow('Urinalysis:', 'No protein, no sugar'),
          _buildInfoRow('HBsAg:', 'Non-reactive'),
          _buildInfoRow('HIV Test:', 'Non-reactive'),
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
                _buildTableHeaderCell('Weight (kg)', flex: 1),
                _buildTableHeaderCell('BP (mmHg)', flex: 2),
                _buildTableHeaderCell('Fundic Height (cm)', flex: 2),
                _buildTableHeaderCell('Fetal Heart (bpm)', flex: 2),
                _buildTableHeaderCell('Remarks', flex: 2),
                _buildTableHeaderCell('Pregnancy Risk Classification', flex: 2),
              ],
            ),
          ),

          // Table Rows
          _buildTableRow('1', 'Feb 20, 2025', '4 weeks', '55', '110/70', 'N/A', 'N/A', 'Initial check-up', 'Low Risk'),
          _buildTableRow('2', 'Mar 18, 2025', '10 weeks', '56', '110/70', 'N/A', 'N/A', 'Advised vitamins', 'Low Risk'),
          _buildTableRow('3', 'Apr 8, 2025', '12 weeks', '57', '110/70', '12', '140', 'Normal findings', 'Low Risk'),
          _buildTableRow('4', 'May 6, 2025', '16 weeks', '58', '110/70', '16', '145', 'Normal, ultrasound', 'Low Risk'),
          _buildTableRow('5', 'Jun 3, 2025', '20 weeks', '59', '115/75', '20', '148', 'Anatomy scan done', 'Low Risk'),
          _buildTableRow('6', 'Jul 1, 2025', '24 weeks', '61', '120/80', '24', '150', 'Normal progress', 'Low Risk'),
          _buildTableRow('7', 'Aug 5, 2025', '28 weeks', '64', '135/90', '28', '152', 'Elevated BP edema noted', 'High Risk'),
          
          // Empty rows
          _buildEmptyTableRow(),
          _buildEmptyTableRow(),
          _buildEmptyTableRow(),
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
    String fetalHeart,
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
          _buildTableCell(weight, flex: 1),
          _buildTableCell(bp, flex: 2),
          _buildTableCell(fundicHeight, flex: 2),
          _buildTableCell(fetalHeart, flex: 2),
          _buildTableCell(remarks, flex: 2),
          _buildTableCell(riskClassification, flex: 2),
        ],
      ),
    );
  }

  Widget _buildEmptyTableRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          _buildTableCell('', flex: 1),
          _buildTableCell('', flex: 2),
          _buildTableCell('', flex: 2),
          _buildTableCell('', flex: 1),
          _buildTableCell('', flex: 2),
          _buildTableCell('', flex: 2),
          _buildTableCell('', flex: 2),
          _buildTableCell('', flex: 2),
          _buildTableCell('', flex: 2),
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
