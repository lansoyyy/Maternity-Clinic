import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:maternity_clinic/utils/colors.dart';
import 'package:maternity_clinic/screens/admin/admin_dashboard_screen.dart';
import 'package:maternity_clinic/screens/admin/admin_appointment_management_screen.dart';
import 'package:maternity_clinic/screens/admin/admin_appointment_scheduling_screen.dart';
import 'package:maternity_clinic/screens/admin/admin_prenatal_patient_detail_screen.dart';
import 'package:maternity_clinic/screens/admin/admin_postnatal_patient_detail_screen.dart';
import '../auth/home_screen.dart';

class AdminPatientRecordsScreen extends StatefulWidget {
  final String userRole;
  final String userName;

  const AdminPatientRecordsScreen({
    super.key,
    required this.userRole,
    required this.userName,
  });

  @override
  State<AdminPatientRecordsScreen> createState() =>
      _AdminPatientRecordsScreenState();
}

class _AdminPatientRecordsScreenState extends State<AdminPatientRecordsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedType = 'PRENATAL';
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _patients = [];
  List<Map<String, dynamic>> _filteredPatients = [];

  @override
  void initState() {
    super.initState();
    _fetchPatients();
    _searchController.addListener(_filterPatients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPatients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('patientType', isEqualTo: _selectedType)
          .get();

      List<Map<String, dynamic>> patients = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        final Map<String, dynamic> patient = {
          'userId': doc.id,
          'patientId': doc.id,
          'name': (data['name'] ?? '').toString(),
          'email': (data['email'] ?? '').toString(),
          'contact': (data['contactNumber'] ?? data['phone'] ?? '').toString(),
          'dob': data['dob'],
          'status':
              (data['accountStatus'] ?? data['status'] ?? 'Active').toString(),
        };

        patients.add(patient);
      }

      // Sort by name for a consistent view
      patients.sort((a, b) {
        final an = (a['name'] ?? '').toString().toLowerCase();
        final bn = (b['name'] ?? '').toString().toLowerCase();
        return an.compareTo(bn);
      });

      if (mounted) {
        setState(() {
          _patients = patients;
          _filteredPatients = patients;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterPatients() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _filteredPatients = List<Map<String, dynamic>>.from(_patients);
      });
      return;
    }

    setState(() {
      _filteredPatients = _patients.where((patient) {
        final id = patient['patientId']?.toString().toLowerCase() ?? '';
        final name = patient['name']?.toString().toLowerCase() ?? '';
        return id.contains(query) || name.contains(query);
      }).toList();
    });
  }

  String _formatDob(dynamic dobField) {
    if (dobField is Timestamp) {
      final date = dobField.toDate();
      return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildTypeToggle(),
                  const SizedBox(height: 20),
                  _buildSearchRow(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _isLoading
                          ? Center(
                              child: CircularProgressIndicator(color: primary),
                            )
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

  Widget _buildHeader() {
    return const Text(
      'Patient Records',
      style: TextStyle(
        fontSize: 22,
        fontFamily: 'Bold',
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Row(
      children: [
        _buildToggleButton('PRENATAL PATIENT RECORD', 'PRENATAL'),
        const SizedBox(width: 10),
        _buildToggleButton('POSTNATAL PATIENT RECORD', 'POSTNATAL'),
      ],
    );
  }

  Widget _buildToggleButton(String label, String type) {
    final bool isSelected = _selectedType == type;
    return ElevatedButton(
      onPressed: isSelected
          ? null
          : () {
              setState(() {
                _selectedType = type;
              });
              _fetchPatients();
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? primary : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontFamily: 'Bold',
        ),
      ),
    );
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        SizedBox(
          width: 260,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by ID or Name',
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
      ],
    );
  }

  Widget _buildPatientTable() {
    return Column(
      children: [
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
            children: const [
              Expanded(
                flex: 2,
                child: Text(
                  'PATIENT ID',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Bold',
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'NAME',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Bold',
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'EMAIL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Bold',
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'CONTACT NO.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Bold',
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'DATE OF BIRTH',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Bold',
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(
                width: 40,
              ),
            ],
          ),
        ),
        ..._filteredPatients
            .map((patient) => _buildPatientRow(patient))
            .toList(),
      ],
    );
  }

  Widget _buildPatientRow(Map<String, dynamic> patient) {
    final String patientId = patient['patientId']?.toString() ?? 'N/A';
    final String name = patient['name']?.toString() ?? 'Unknown';
    final String email = patient['email']?.toString() ?? '';
    final String contact = patient['contact']?.toString() ?? '';
    final String dob = _formatDob(patient['dob']);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              patientId,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'Regular',
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'Regular',
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              email,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'Regular',
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              contact,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'Regular',
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              dob,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'Regular',
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Align(
              alignment: Alignment.center,
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'personal' || value == 'history') {
                    _openPatientDetail(patient);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'personal',
                    child: Text('Personal Details'),
                  ),
                  PopupMenuItem<String>(
                    value: 'history',
                    child: Text('Complete History Checkup'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openPatientDetail(Map<String, dynamic> patient) {
    final String userId = patient['userId']?.toString() ?? '';
    final String name = patient['name']?.toString() ?? '';
    final String email = patient['email']?.toString() ?? '';
    final String status = patient['status']?.toString() ?? 'Active';

    final Map<String, String> patientData = {
      'patientId': userId,
      'name': name,
      'email': email,
      'status': status,
    };

    if (_selectedType == 'PRENATAL') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminPrenatalPatientDetailScreen(
            patientData: patientData,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminPostnatalPatientDetailScreen(
            patientData: patientData,
          ),
        ),
      );
    }
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
          _buildMenuItem('DATA GRAPHS', false),
          _buildMenuItem('APPOINTMENT MANAGEMENT', false),
          _buildMenuItem('APPROVE SCHEDULES', false),
          _buildMenuItem('PATIENT RECORDS', true),
          const Spacer(),
          _buildMenuItem('LOGOUT', false),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, bool isActive) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (title == 'LOGOUT') {
            _showLogoutConfirmationDialog();
            return;
          }
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
    Widget screen;
    switch (title) {
      case 'DATA GRAPHS':
        screen = AdminDashboardScreen(
          userRole: widget.userRole,
          userName: widget.userName,
        );
        break;
      case 'APPOINTMENT MANAGEMENT':
        screen = AdminAppointmentManagementScreen(
          userRole: widget.userRole,
          userName: widget.userName,
        );
        break;
      case 'APPROVE SCHEDULES':
        screen = AdminAppointmentSchedulingScreen(
          userRole: widget.userRole,
          userName: widget.userName,
        );
        break;
      case 'PATIENT RECORDS':
        // Already on this screen
        return;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Logout Confirmation',
          style: TextStyle(fontFamily: 'Bold'),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontFamily: 'Regular'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style:
                  TextStyle(color: Colors.grey.shade600, fontFamily: 'Medium'),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _auth.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.red.shade600, fontFamily: 'Bold'),
            ),
          ),
        ],
      ),
    );
  }
}
