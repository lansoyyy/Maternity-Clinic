import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'prenatal_dashboard_screen.dart';
import 'postnatal_dashboard_screen.dart';
import 'prenatal_history_checkup_screen.dart';
import 'postnatal_history_checkup_screen.dart';
import 'notification_appointment_screen.dart';

class TransferRecordRequestScreen extends StatefulWidget {
  final String patientType; // 'PRENATAL' or 'POSTNATAL'
  
  const TransferRecordRequestScreen({
    super.key,
    required this.patientType,
  });

  @override
  State<TransferRecordRequestScreen> createState() => _TransferRecordRequestScreenState();
}

class _TransferRecordRequestScreenState extends State<TransferRecordRequestScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _otherController = TextEditingController();
  final TextEditingController _transferToController = TextEditingController();
  final TextEditingController _newDoctorController = TextEditingController();
  final TextEditingController _clinicAddressController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  bool _laboratoryResults = false;
  bool _diagnosticReports = false;
  bool _vaccinationRecords = false;
  bool _clinicalNotes = false;

  String _transferMethod = 'Pick-up by Patient/Authorized Representative';

  @override
  void dispose() {
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    _otherController.dispose();
    _transferToController.dispose();
    _newDoctorController.dispose();
    _clinicAddressController.dispose();
    _contactInfoController.dispose();
    _reasonController.dispose();
    super.dispose();
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
                  // Title
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'TRANSFER OF RECORD REQUEST',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Bold',
                          color: Colors.black,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Form Content
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        child: _buildLeftColumn(),
                      ),
                      const SizedBox(width: 60),

                      // Right Column
                      Expanded(
                        child: _buildRightColumn(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Submit Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle form submission
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Transfer request submitted successfully!',
                              style: TextStyle(fontFamily: 'Regular'),
                            ),
                            backgroundColor: primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Submit Request',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Bold',
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
          _buildMenuItem('NOTIFICATION\nAPPOINTMENT', false),
          _buildMenuItem('TRANSFER OF\nRECORD REQUEST', true),
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NotificationAppointmentScreen(patientType: widget.patientType)),
        );
        break;
      case 'TRANSFER OF\nRECORD REQUEST':
        // Already on this screen
        break;
    }
  }

  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Full Name:', _fullNameController),
        const SizedBox(height: 15),
        _buildTextField('Date of Birth:', _dateOfBirthController),
        const SizedBox(height: 15),
        _buildTextField('Address:', _addressController),
        const SizedBox(height: 25),

        // Records to Transfer
        const Text(
          'Medical History',
          style: TextStyle(fontSize: 14, fontFamily: 'Regular', color: Colors.black87),
        ),
        const SizedBox(height: 10),
        _buildCheckbox('Laboratory Results', _laboratoryResults, (value) {
          setState(() => _laboratoryResults = value!);
        }),
        _buildCheckbox('Diagnostic Reports', _diagnosticReports, (value) {
          setState(() => _diagnosticReports = value!);
        }),
        _buildCheckbox('Vaccination Records', _vaccinationRecords, (value) {
          setState(() => _vaccinationRecords = value!);
        }),
        _buildCheckbox('Clinical Notes', _clinicalNotes, (value) {
          setState(() => _clinicalNotes = value!);
        }),
        const SizedBox(height: 15),
        _buildTextField('Other (Please specify):', _otherController),
        const SizedBox(height: 25),

        // Transfer Information
        _buildTextField('Transfer To (New Clinic/Physician):', _transferToController),
        const SizedBox(height: 15),
        _buildTextField('Name of New Doctor/Clinic:', _newDoctorController),
        const SizedBox(height: 15),
        _buildTextField('Clinic Address:', _clinicAddressController),
        const SizedBox(height: 15),
        _buildTextField('Contact Information:', _contactInfoController),
        const SizedBox(height: 15),
        _buildTextField('Reason for Transfer:', _reasonController),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Method of Transfer:',
          style: TextStyle(fontSize: 14, fontFamily: 'Bold', color: Colors.black87),
        ),
        const SizedBox(height: 10),
        _buildRadioOption('Pick-up by Patient/Authorized Representative'),
        _buildRadioOption('Secure Email'),
        _buildRadioOption('Postal Mail to the address above'),
        const SizedBox(height: 30),

        const Text(
          'Signature of Patient/ Legal Guardian:',
          style: TextStyle(fontSize: 14, fontFamily: 'Bold', color: Colors.black87),
        ),
        const SizedBox(height: 10),
        _buildTextField('Printed Name:', TextEditingController()),
        const SizedBox(height: 15),
        _buildTextField('Date:', TextEditingController()),
        const SizedBox(height: 30),

        const Text(
          'For Office Use Only:',
          style: TextStyle(fontSize: 14, fontFamily: 'Bold', color: Colors.black87),
        ),
        const SizedBox(height: 10),
        _buildTextField('Date Request Received:', TextEditingController()),
        const SizedBox(height: 15),
        _buildTextField('Processed by:', TextEditingController()),
        const SizedBox(height: 15),
        _buildTextField('Date Sent:', TextEditingController()),
        const SizedBox(height: 15),
        _buildTextField('Method:', TextEditingController()),
        const SizedBox(height: 15),
        _buildTextField('Amount Paid:', TextEditingController()),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Regular',
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(fontSize: 13, fontFamily: 'Regular'),
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: primary,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Regular',
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String option) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Radio<String>(
            value: option,
            groupValue: _transferMethod,
            onChanged: (value) {
              setState(() {
                _transferMethod = value!;
              });
            },
            activeColor: primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            option,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Regular',
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
