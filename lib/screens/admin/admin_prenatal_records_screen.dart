import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maternity_clinic/screens/admin/admin_prenatal_patient_detail_screen.dart';
import 'package:maternity_clinic/screens/admin/admin_transfer_requests_screen.dart';
import 'package:maternity_clinic/utils/colors.dart';

import 'admin_postnatal_records_screen.dart';
import 'admin_appointment_scheduling_screen.dart';
import 'admin_dashboard_screen.dart';

class AdminPrenatalRecordsScreen extends StatefulWidget {
  final String userRole;
  final String userName;

  const AdminPrenatalRecordsScreen({
    super.key,
    required this.userRole,
    required this.userName,
  });

  @override
  State<AdminPrenatalRecordsScreen> createState() => _AdminPrenatalRecordsScreenState();
}

class _AdminPrenatalRecordsScreenState extends State<AdminPrenatalRecordsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'ACTIVE';
  List<Map<String, dynamic>> _patients = [];
  List<Map<String, dynamic>> _filteredPatients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
    _searchController.addListener(_filterPatients);
  }

  Future<void> _fetchPatients() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('patientType', isEqualTo: 'PRENATAL')
          .get();

      List<Map<String, dynamic>> patients = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        // Only include fields that have actual data
        Map<String, dynamic> patient = {
          'id': doc.id,
          'patientId': data['patientId'] ?? doc.id,
        };
        
        // Only add fields if they exist and are not empty
        if (data['name'] != null && data['name'].toString().isNotEmpty) {
          patient['name'] = data['name'];
        }
        if (data['email'] != null && data['email'].toString().isNotEmpty) {
          patient['email'] = data['email'];
        }
        if (data['address'] != null && data['address'].toString().isNotEmpty) {
          patient['address'] = data['address'];
        }
        if (data['phone'] != null && data['phone'].toString().isNotEmpty) {
          patient['contact'] = data['phone'];
        }
        if (data['gestationAge'] != null && data['gestationAge'].toString().isNotEmpty) {
          patient['gestation'] = data['gestationAge'];
        }
        if (data['age'] != null && data['age'].toString().isNotEmpty) {
          patient['age'] = data['age'].toString();
        }
        if (data['deliveryStatus'] != null && data['deliveryStatus'].toString().isNotEmpty) {
          patient['childBirth'] = data['deliveryStatus'];
        } else {
          patient['childBirth'] = 'Active'; // Default status for prenatal patients
        }
        
        patients.add(patient);
      }

      if (mounted) {
        setState(() {
          _patients = patients;
          _filteredPatients = patients;
          _isLoading = false;
        });
        _filterPatients();
      }
    } catch (e) {
      print('Error fetching prenatal patients: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterPatients() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPatients = _patients.where((patient) {
        bool matchesSearch = patient['name']?.toString().toLowerCase().contains(query) ?? false;
        bool matchesFilter = _selectedFilter == 'ACTIVE'
            ? (patient['childBirth'] == 'Active' || patient['childBirth'] == null)
            : patient['childBirth'] == 'Delivered';
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

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
                            _filterPatients();
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
                      child: _isLoading
                          ? Center(child: CircularProgressIndicator(color: primary))
                          : _filteredPatients.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No patients found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Regular',
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : SingleChildScrollView(
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
          if (widget.userRole == 'admin') _buildMenuItem('PRENATAL PATIENT\nRECORD', true),
          if (widget.userRole == 'admin') _buildMenuItem('POSTNATAL PATIENT\nRECORD', false),
          _buildMenuItem('APPOINTMENT\nSCHEDULING', false),
          if (widget.userRole == 'admin') _buildMenuItem('TRANSFER\nREQUESTS', false),
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
        // Already on this screen
        break;
      case 'POSTNATAL PATIENT\nRECORD':
        if (widget.userRole == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminPostnatalRecordsScreen(
                userRole: widget.userRole,
                userName: widget.userName,
              ),
            ),
          );
        }
        break;
      case 'APPOINTMENT\nSCHEDULING':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminAppointmentSchedulingScreen(
              userRole: widget.userRole,
              userName: widget.userName,
            ),
          ),
        );
        break;
      case 'TRANSFER\nREQUESTS':
        if (widget.userRole == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminTransferRequestsScreen(
                userRole: widget.userRole,
                userName: widget.userName,
              ),
            ),
          );
        }
        break;
    }
  }

  Widget _buildPatientTable() {
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
              _buildHeaderCell('NAME', flex: 3),
              _buildHeaderCell('EMAIL', flex: 3),
              _buildHeaderCell('PATIENT TYPE', flex: 2),
              _buildHeaderCell('STATUS', flex: 2),
            ],
          ),
        ),

        // Table Rows
        ..._filteredPatients.map((patient) {
          return _buildTableRow(
            patient['patientId'] ?? 'N/A',
            patient['name'] ?? 'Unknown',
            patient['email'] ?? '',
            'PRENATAL',
            patient['childBirth'] ?? 'Active',
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
    String email,
    String patientType,
    String status,
  ) {
    Color statusColor;
    if (status == 'Active') {
      statusColor = Colors.green;
    } else if (status == 'Delivered') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.grey;
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
                  'email': email,
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
          _buildTableCell(patientId, flex: 2),
          _buildTableCell(name, flex: 3),
          _buildTableCell(email, flex: 3),
          _buildTableCell(patientType, flex: 2),
          Expanded(
            flex: 2,
            child: Center(
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
          ),
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
