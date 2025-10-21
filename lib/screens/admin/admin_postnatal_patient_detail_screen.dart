import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class AdminPostnatalPatientDetailScreen extends StatefulWidget {
  final Map<String, String> patientData;

  const AdminPostnatalPatientDetailScreen({
    super.key,
    required this.patientData,
  });

  @override
  State<AdminPostnatalPatientDetailScreen> createState() => _AdminPostnatalPatientDetailScreenState();
}

class _AdminPostnatalPatientDetailScreenState extends State<AdminPostnatalPatientDetailScreen> {
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
          _buildMenuItem('PRENATAL PATIENT\nRECORD', false),
          _buildMenuItem('POSTNATAL PATIENT\nRECORD', true),
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
          if (widget.patientData['age'] != null && widget.patientData['age']!.isNotEmpty)
            _buildInfoRow('Age:', widget.patientData['age']!),
          if (widget.patientData['address'] != null && widget.patientData['address']!.isNotEmpty)
            _buildInfoRow('Address:', widget.patientData['address']!),
          if (widget.patientData['contact'] != null && widget.patientData['contact']!.isNotEmpty)
            _buildInfoRow('Contact:', widget.patientData['contact']!),
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
          if (widget.patientData['deliveryType'] != null && widget.patientData['deliveryType']!.isNotEmpty)
            _buildInfoRow('Last Delivery:', widget.patientData['deliveryType']!),
          if (widget.patientData['dateOfDelivery'] != null && widget.patientData['dateOfDelivery']!.isNotEmpty)
            _buildInfoRow('Date of Delivery:', widget.patientData['dateOfDelivery']!),
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
                _buildTableHeaderCell('Days of Postpartum', flex: 2),
                _buildTableHeaderCell('Weight (kg)', flex: 1),
                _buildTableHeaderCell('BP (mmHg)', flex: 2),
                _buildTableHeaderCell('Temp (°C)', flex: 1),
                _buildTableHeaderCell('Lochia', flex: 1),
                _buildTableHeaderCell('Remarks', flex: 2),
                _buildTableHeaderCell('Pregnancy Risk Classification', flex: 2),
              ],
            ),
          ),

          // Table Rows
          _buildTableRow('1', '2025-08-25', '5', '63', '120/80', '36.8', 'Normal', 'Initial check-up', 'Low Risk'),
          _buildTableRow('2', '2025-09-05', '16', '63', '118/76', '36.7', 'Scant', 'Advised vitamins', 'Low Risk'),
          _buildTableRow('3', '2025-09-20', '31', '61', '116/75', '36.6', 'None', 'Normal findings', 'Low Risk'),
          
          // Empty rows
          _buildEmptyTableRow(),
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
    String daysOfPostpartum,
    String weight,
    String bp,
    String temp,
    String lochia,
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
          _buildTableCell(daysOfPostpartum, flex: 2),
          _buildTableCell(weight, flex: 1),
          _buildTableCell(bp, flex: 2),
          _buildTableCell(temp, flex: 1),
          _buildTableCell(lochia, flex: 1),
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
          _buildTableCell('', flex: 1),
          _buildTableCell('', flex: 1),
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
