import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'admin_postnatal_patient_detail_screen.dart';
import 'admin_prenatal_records_screen.dart';
import 'admin_appointment_scheduling_screen.dart';

class AdminPostnatalRecordsScreen extends StatefulWidget {
  const AdminPostnatalRecordsScreen({super.key});

  @override
  State<AdminPostnatalRecordsScreen> createState() => _AdminPostnatalRecordsScreenState();
}

class _AdminPostnatalRecordsScreenState extends State<AdminPostnatalRecordsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'ACTIVE';

  @override
  void dispose() {
    _searchController.dispose();
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
                  // Search and Filter Row
                  Row(
                    children: [
                      // Search Field
                      Container(
                        width: 250,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'SEARCH NAME',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Regular',
                              color: Colors.grey.shade600,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Regular',
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Active Filter Button
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedFilter = 'ACTIVE';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedFilter == 'ACTIVE'
                              ? Colors.grey.shade300
                              : Colors.grey.shade200,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontFamily: 'Bold',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Table
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SingleChildScrollView(
                        child: _buildPatientTable(),
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
        // Already on this screen
        break;
      case 'APPOINTMENT\nSCHEDULING':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminAppointmentSchedulingScreen()),
        );
        break;
    }
  }

  Widget _buildPatientTable() {
    final patients = [
      {
        'patientId': 'PNL-2025-001',
        'name': 'Maria Dela Cruz',
        'age': '38',
        'deliveryType': 'Cesarean',
        'dateOfDelivery': '8/20/2025',
        'address': '123 Sampaguita St., QC',
        'contact': '0919-336-6789',
      },
      {
        'patientId': 'PNL-2025-002',
        'name': 'Ana Santos',
        'age': '32',
        'deliveryType': 'Normal',
        'dateOfDelivery': '8/15/2025',
        'address': '45 Mabini St., Manila',
        'contact': '0921-567-3348',
      },
      {
        'patientId': 'PNL-2025-003',
        'name': 'Liza Reyes',
        'age': '24',
        'deliveryType': 'Normal',
        'dateOfDelivery': '7/30/2025',
        'address': '67 Rizal Ave., Caloocan',
        'contact': '0958-221-7658',
      },
      {
        'patientId': 'PNL-2025-004',
        'name': 'Joanna Mendoza',
        'age': '30',
        'deliveryType': 'Cesarean',
        'dateOfDelivery': '8/5/2025',
        'address': '15 Katipunan Rd., QC',
        'contact': '0917-665-8435',
      },
      {
        'patientId': 'PNL-2025-005',
        'name': 'Christine Bautista',
        'age': '27',
        'deliveryType': 'Normal',
        'dateOfDelivery': '7/28/2025',
        'address': '78 Boni Ave., Mandaluyong',
        'contact': '0932-876-1109',
      },
      {
        'patientId': 'PNL-2025-006',
        'name': 'Camille Garcia',
        'age': '35',
        'deliveryType': 'Cesarean',
        'dateOfDelivery': '8/10/2025',
        'address': '89 Taft Ave., Manila',
        'contact': '0918-223-8821',
      },
      {
        'patientId': 'PNL-2025-007',
        'name': 'Erika Villanueva',
        'age': '29',
        'deliveryType': 'Normal',
        'dateOfDelivery': '8/18/2025',
        'address': '23 P. Tuazon, Cubao',
        'contact': '0976-332-1190',
      },
      {
        'patientId': 'PNL-2025-008',
        'name': 'Grace Fernandez',
        'age': '31',
        'deliveryType': 'Cesarean',
        'dateOfDelivery': '7/25/2025',
        'address': '16 Melchor St.,Pasig',
        'contact': '0918-552-7788',
      },
      {
        'patientId': 'PNL-2025-009',
        'name': 'Janine Cruz',
        'age': '26',
        'deliveryType': 'Normal',
        'dateOfDelivery': '8/12/2025',
        'address': '54 Aurora Blvd., Marikina',
        'contact': '0991-728-4960',
      },
      {
        'patientId': 'PNL-2025-010',
        'name': 'Michelle Torres',
        'age': '33',
        'deliveryType': 'Normal',
        'dateOfDelivery': '7/22/2025',
        'address': '34 Roxas Blvd., Pasay',
        'contact': '0924-119-5678',
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
              _buildHeaderCell('Age', flex: 1),
              _buildHeaderCell('Delivery Type', flex: 2),
              _buildHeaderCell('Date of Delivery', flex: 2),
              _buildHeaderCell('Address', flex: 3),
              _buildHeaderCell('Contact No.', flex: 2),
            ],
          ),
        ),

        // Table Rows
        ...patients.map((patient) {
          return _buildTableRow(
            patient['patientId']!,
            patient['name']!,
            patient['age']!,
            patient['deliveryType']!,
            patient['dateOfDelivery']!,
            patient['address']!,
            patient['contact']!,
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
    String age,
    String deliveryType,
    String dateOfDelivery,
    String address,
    String contact,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminPostnatalPatientDetailScreen(
                patientData: {
                  'patientId': patientId,
                  'name': name,
                  'age': age,
                  'deliveryType': deliveryType,
                  'dateOfDelivery': dateOfDelivery,
                  'address': address,
                  'contact': contact,
                },
              ),
            ),
          );
        },
        child: Container(
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
              _buildTableCell(age, flex: 1),
              _buildTableCell(deliveryType, flex: 2),
              _buildTableCell(dateOfDelivery, flex: 2),
              _buildTableCell(address, flex: 3),
              _buildTableCell(contact, flex: 2),
            ],
          ),
        ),
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
