import 'package:flutter/material.dart';
import 'package:maternity_clinic/screens/admin/admin_prenatal_patient_detail_screen.dart';
import 'package:maternity_clinic/utils/colors.dart';

import 'admin_postnatal_records_screen.dart';
import 'admin_appointment_scheduling_screen.dart';

class AdminPrenatalRecordsScreen extends StatefulWidget {
  const AdminPrenatalRecordsScreen({super.key});

  @override
  State<AdminPrenatalRecordsScreen> createState() => _AdminPrenatalRecordsScreenState();
}

class _AdminPrenatalRecordsScreenState extends State<AdminPrenatalRecordsScreen> {
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
        // Already on this screen
        break;
      case 'POSTNATAL PATIENT\nRECORD':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPostnatalRecordsScreen()),
        );
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
        'status': 'Active',
        'childBirth': 'Active',
        'patientId': 'P-2025-001',
        'name': 'Maria Santos',
        'address': '123 Mabini St. Brgy. San Isidro, Quezon City',
        'contact': '0917-123-4567',
        'gestation': '20 Weeks 2 Days',
        'age': '27',
      },
      {
        'status': 'Delivered',
        'childBirth': 'Delivered',
        'patientId': 'P-2025-002',
        'name': 'Ana Cruz',
        'address': '45 Rizal Ave. Brgy. 5, Manila',
        'contact': '0918-234-5678',
        'gestation': '39 Weeks',
        'age': '31',
      },
      {
        'status': 'Active',
        'childBirth': 'Active',
        'patientId': 'P-2025-003',
        'name': 'Liza Dela Peña',
        'address': '99 Legaspi St. Brgy. Pio Del Pilar, Makati',
        'contact': '0921-345-6789',
        'gestation': '3 Weeks 4 Days',
        'age': '24',
      },
      {
        'status': 'Active',
        'childBirth': 'Active',
        'patientId': 'P-2025-004',
        'name': 'Jenny Robles',
        'address': '56 Melchor St. Brgy. 12, Quezon City',
        'contact': '0919-456-7890',
        'gestation': '8 Weeks 3 Days',
        'age': '29',
      },
      {
        'status': 'Active',
        'childBirth': 'Active',
        'patientId': 'P-2025-005',
        'name': 'Karen Villanueva',
        'address': '210 M. Roxas St. Brgy. San Antonio, Pasig City',
        'contact': '0922-567-8901',
        'gestation': '5 Weeks 6 Days',
        'age': '33',
      },
      {
        'status': 'Active',
        'childBirth': 'Active',
        'patientId': 'P-2025-006',
        'name': 'Michelle Flores',
        'address': '8 Luna St. Brgy. 1, Taguig City',
        'contact': '0917-678-9012',
        'gestation': '4 Weeks 5 Days',
        'age': '26',
      },
      {
        'status': 'Delivered',
        'childBirth': 'Delivered',
        'patientId': 'P-2025-007',
        'name': 'Rose Ann Mendoza',
        'address': '33 Aguinaldo Hwy. Brgy. 5, Lucena City',
        'contact': '0923-789-0123',
        'gestation': '39 Weeks',
        'age': '35',
      },
      {
        'status': 'Active',
        'childBirth': 'Active',
        'patientId': 'P-2025-008',
        'name': 'Carla Gutierrez',
        'address': '99 National Hwy. Brgy. San Pedro, Laguna',
        'contact': '0918-890-1234',
        'gestation': '2 Weeks 2 Days',
        'age': '28',
      },
      {
        'status': 'Active',
        'childBirth': 'Active',
        'patientId': 'P-2025-009',
        'name': 'Joyce Ramirez',
        'address': '77 Bonifacio St. Brgy. Halsey, Bacoor, Cavite',
        'contact': '0924-901-2345',
        'gestation': '5 Weeks 2 Days',
        'age': '32',
      },
      {
        'status': 'Delivered',
        'childBirth': 'Delivered',
        'patientId': 'P-2025-010',
        'name': 'Angelica Torres',
        'address': '67 Mabuhay St. Brgy. Barangka, Bulacan',
        'contact': '0917-012-3456',
        'gestation': '39 Weeks',
        'age': '30',
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
              _buildHeaderCell('CHILD BIRTH', flex: 1),
              _buildHeaderCell('PATIENT ID', flex: 1),
              _buildHeaderCell('NAME', flex: 2),
              _buildHeaderCell('ADDRESS', flex: 3),
              _buildHeaderCell('CONTACT NO.', flex: 2),
              _buildHeaderCell('AGE OF GESTATION', flex: 2),
              _buildHeaderCell('AGE', flex: 1),
            ],
          ),
        ),

        // Table Rows
        ...patients.map((patient) {
          return _buildTableRow(
            patient['status']!,
            patient['childBirth']!,
            patient['patientId']!,
            patient['name']!,
            patient['address']!,
            patient['contact']!,
            patient['gestation']!,
            patient['age']!,
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
    String status,
    String childBirth,
    String patientId,
    String name,
    String address,
    String contact,
    String gestation,
    String age,
  ) {
    Color statusColor;
    if (childBirth == 'Active') {
      statusColor = Colors.green;
    } else if (childBirth == 'Delivered') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.grey;
    }

    Color gestationColor;
    if (gestation.contains('39 Weeks')) {
      gestationColor = Colors.red;
    } else {
      gestationColor = Colors.green;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminPrenatalPatientDetailScreen(
                patientData: {
                  'patientId': patientId,
                  'name': name,
                  'age': age,
                  'address': address,
                  'contact': contact,
                  'gestation': gestation,
                  'status': status,
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
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                childBirth,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Bold',
                  color: statusColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          _buildTableCell(patientId, flex: 1),
          _buildTableCell(name, flex: 2),
          _buildTableCell(address, flex: 3),
          _buildTableCell(contact, flex: 2),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                gestation,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Regular',
                  color: gestationColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          _buildTableCell(age, flex: 1),
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
