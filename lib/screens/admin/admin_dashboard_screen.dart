import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maternity_clinic/screens/admin/admin_appointment_scheduling_screen.dart';
import 'package:maternity_clinic/screens/admin/admin_postnatal_records_screen.dart';
import 'package:maternity_clinic/screens/admin/admin_prenatal_records_screen.dart';
import 'package:maternity_clinic/screens/admin/admin_transfer_requests_screen.dart';
import '../../utils/colors.dart';
import '../auth/home_screen.dart';


class AdminDashboardScreen extends StatefulWidget {
  final String userRole;
  final String userName;

  const AdminDashboardScreen({
    super.key,
    required this.userRole,
    required this.userName,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  int _prenatalCount = 0;
  int _postnatalCount = 0;
  int _pendingAppointments = 0;
  int _acceptedAppointments = 0;
  int _completedAppointments = 0;
  int _cancelledAppointments = 0;
  int _prenatalAppointments = 0;
  int _postnatalAppointments = 0;
  Map<int, int> _prenatalYearlyCount = {};
  Map<int, int> _postnatalYearlyCount = {};
  
  // Age group statistics
  Map<String, int> _ageGroupCounts = {
    '12-19': 0,
    '20-29': 0,
    '30-39': 0,
    '40+': 0,
  };
  
  // Delivery type statistics
  int _normalDeliveryCount = 0;
  int _cesareanDeliveryCount = 0;
  
  bool _isLoading = true;

  // Check if current user is admin
  bool get _isAdmin => widget.userRole == 'admin';

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      // Fetch prenatal and postnatal counts
      final prenatalSnapshot = await _firestore
          .collection('users')
          .where('patientType', isEqualTo: 'PRENATAL')
          .get();
      
      final postnatalSnapshot = await _firestore
          .collection('users')
          .where('patientType', isEqualTo: 'POSTNATAL')
          .get();

      // Fetch all appointments
      final appointmentsSnapshot = await _firestore
          .collection('appointments')
          .get();
      
      // Fetch delivery type data (simulated for now - in real app this would come from patient records)
      // For demo purposes, we'll use some sample data
      _normalDeliveryCount = (_postnatalCount * 0.7).round(); // 70% normal
      _cesareanDeliveryCount = (_postnatalCount * 0.3).round(); // 30% cesarean

      // Count appointments by status
      int pending = 0;
      int accepted = 0;
      int completed = 0;
      int cancelled = 0;
      int prenatalAppts = 0;
      int postnatalAppts = 0;

      for (var doc in appointmentsSnapshot.docs) {
        final data = doc.data();
        String status = data['status']?.toString().toLowerCase() ?? '';
        String patientType = data['patientType']?.toString().toUpperCase() ?? '';

        // Count by status
        if (status == 'pending') {
          pending++;
        } else if (status == 'accepted') {
          accepted++;
        } else if (status == 'completed') {
          completed++;
        } else if (status == 'cancelled') {
          cancelled++;
        }

        // Count by patient type
        if (patientType == 'PRENATAL') {
          prenatalAppts++;
        } else if (patientType == 'POSTNATAL') {
          postnatalAppts++;
        }
      }

      // Process age group data
      Map<String, int> ageGroups = {
        '12-19': 0,
        '20-29': 0,
        '30-39': 0,
        '40+': 0,
      };
      
      // Process prenatal patients for age groups
      for (var doc in prenatalSnapshot.docs) {
        final data = doc.data();
        if (data['age'] != null) {
          int age = data['age'] as int;
          if (age >= 12 && age <= 19) {
            ageGroups['12-19'] = (ageGroups['12-19'] ?? 0) + 1;
          } else if (age >= 20 && age <= 29) {
            ageGroups['20-29'] = (ageGroups['20-29'] ?? 0) + 1;
          } else if (age >= 30 && age <= 39) {
            ageGroups['30-39'] = (ageGroups['30-39'] ?? 0) + 1;
          } else if (age >= 40) {
            ageGroups['40+'] = (ageGroups['40+'] ?? 0) + 1;
          }
        }
      }
      
      // Process postnatal patients for age groups
      for (var doc in postnatalSnapshot.docs) {
        final data = doc.data();
        if (data['age'] != null) {
          int age = data['age'] as int;
          if (age >= 12 && age <= 19) {
            ageGroups['12-19'] = (ageGroups['12-19'] ?? 0) + 1;
          } else if (age >= 20 && age <= 29) {
            ageGroups['20-29'] = (ageGroups['20-29'] ?? 0) + 1;
          } else if (age >= 30 && age <= 39) {
            ageGroups['30-39'] = (ageGroups['30-39'] ?? 0) + 1;
          } else if (age >= 40) {
            ageGroups['40+'] = (ageGroups['40+'] ?? 0) + 1;
          }
        }
      }

      // Fetch yearly counts for history chart
      Map<int, int> prenatalYearly = {};
      Map<int, int> postnatalYearly = {};

      for (var doc in prenatalSnapshot.docs) {
        final data = doc.data();
        if (data['createdAt'] != null) {
          DateTime date = (data['createdAt'] as Timestamp).toDate();
          int year = date.year;
          prenatalYearly[year] = (prenatalYearly[year] ?? 0) + 1;
        }
      }

      for (var doc in postnatalSnapshot.docs) {
        final data = doc.data();
        if (data['createdAt'] != null) {
          DateTime date = (data['createdAt'] as Timestamp).toDate();
          int year = date.year;
          postnatalYearly[year] = (postnatalYearly[year] ?? 0) + 1;
        }
      }

      if (mounted) {
        setState(() {
          _prenatalCount = prenatalSnapshot.docs.length;
          _postnatalCount = postnatalSnapshot.docs.length;
          _pendingAppointments = pending;
          _acceptedAppointments = accepted;
          _acceptedAppointments = accepted;
          _completedAppointments = completed;
          _cancelledAppointments = cancelled;
          _cancelledAppointments = cancelled;
          _prenatalAppointments = prenatalAppts;
          _postnatalAppointments = postnatalAppts;
          _prenatalYearlyCount = prenatalYearly;
          _postnatalYearlyCount = postnatalYearly;
          _ageGroupCounts = ageGroups;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching dashboard data: $e');
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
      backgroundColor: const Color(0xFFF5F7FA),
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
                        // Dashboard Header
                        Container(
                          margin: const EdgeInsets.only(bottom: 30),
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primary.withOpacity(0.9), secondary.withOpacity(0.9)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.dashboard_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'ADMIN DASHBOARD',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontFamily: 'Bold',
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Welcome back, ${widget.userName}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                        fontFamily: 'Medium',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  'Role: ${widget.userRole.toUpperCase()}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Bold',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Statistics Cards Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total Patients',
                                '${_prenatalCount + _postnatalCount}',
                                Icons.people_rounded,
                                const Color(0xFF5DCED9),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildStatCard(
                                'Pending Appointments',
                                '$_pendingAppointments',
                                Icons.pending_actions_rounded,
                                Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildStatCard(
                                'Completed Today',
                                '$_completedAppointments',
                                Icons.check_circle_rounded,
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Top Row - Charts
                        Row(
                          children: [
                            Expanded(
                              child: _buildPrenatalPostnatalChart(),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildAgeGroupChart(),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildDeliveryTypeChart(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Bottom - Line Chart
                        _buildHistoryCountingChart(),
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
          _buildMenuItem('DATA GRAPHS', true),
          if (_isAdmin) _buildMenuItem('PRENATAL PATIENT\nRECORD', false),
          if (_isAdmin) _buildMenuItem('POSTNATAL PATIENT\nRECORD', false),
          _buildMenuItem('APPOINTMENT\nSCHEDULING', false),
          if (_isAdmin) _buildMenuItem('TRANSFER\nREQUESTS', false),
          
          const Spacer(),
          
          // Logout Menu Item
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildLogoutMenuItem(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, bool isActive) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _handleMenuNavigation(title);
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

  Widget _buildLogoutMenuItem() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _showLogoutConfirmationDialog();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(
              left: BorderSide(
                color: Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'LOGOUT',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontFamily: 'Medium',
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
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
              style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Medium'),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
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

  void _handleMenuNavigation(String title) {
    Widget screen;
    switch (title) {
      case 'DATA GRAPHS':
        // Already on this screen, do nothing
        return;
      case 'PRENATAL PATIENT\nRECORD':
        if (_isAdmin) {
          screen = AdminPrenatalRecordsScreen(
            userRole: widget.userRole,
            userName: widget.userName,
          );
        } else {
          _showAccessDeniedDialog();
          return;
        }
        break;
      case 'POSTNATAL PATIENT\nRECORD':
        if (_isAdmin) {
          screen = AdminPostnatalRecordsScreen(
            userRole: widget.userRole,
            userName: widget.userName,
          );
        } else {
          _showAccessDeniedDialog();
          return;
        }
        break;
      case 'APPOINTMENT\nSCHEDULING':
        screen = AdminAppointmentSchedulingScreen(
          userRole: widget.userRole,
          userName: widget.userName,
        );
        break;
      case 'TRANSFER\nREQUESTS':
        if (_isAdmin) {
          screen = AdminTransferRequestsScreen(
            userRole: widget.userRole,
            userName: widget.userName,
          );
        } else {
          _showAccessDeniedDialog();
          return;
        }
        break;
      default:
        return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _showAccessDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Access Denied',
          style: TextStyle(fontFamily: 'Bold'),
        ),
        content: Text(
          'This feature is only available to administrators. You are logged in as ${widget.userRole}.',
          style: const TextStyle(fontFamily: 'Regular'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: primary, fontFamily: 'Bold'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrenatalPostnatalChart() {
    int total = _prenatalCount + _postnatalCount;
    double prenatalPercent = total > 0 ? (_prenatalCount / total) * 100 : 0;
    double postnatalPercent = total > 0 ? (_postnatalCount / total) * 100 : 0;
    
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: total > 0 ? 200 : 0,
            child: total > 0
                ? PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 0,
                      sections: [
                        if (_prenatalCount > 0)
                          PieChartSectionData(
                            value: _prenatalCount.toDouble(),
                            title: 'PRENATAL\n${prenatalPercent.toStringAsFixed(1)}%',
                            color: const Color(0xFF5DCED9),
                            radius: 100,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Bold',
                              color: Colors.white,
                            ),
                          ),
                        if (_postnatalCount > 0)
                          PieChartSectionData(
                            value: _postnatalCount.toDouble(),
                            title: 'POSTNATAL\n${postnatalPercent.toStringAsFixed(1)}%',
                            color: const Color(0xFF3F51B5),
                            radius: 100,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Bold',
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Text(
              'PRENATAL AND POSTNATAL',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Bold',
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.more_vert_rounded,
                color: Colors.grey.shade400,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontFamily: 'Bold',
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Medium',
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeGroupChart() {
    int totalPatients = _prenatalCount + _postnatalCount;
    
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'AGE GROUP DISTRIBUTION',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Bold',
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: totalPatients > 0
                ? PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        if (_ageGroupCounts['12-19']! > 0)
                          PieChartSectionData(
                            value: _ageGroupCounts['12-19']!.toDouble(),
                            title: '12-19\n${((_ageGroupCounts['12-19']! / totalPatients) * 100).toStringAsFixed(1)}%',
                            color: const Color(0xFF9C27B0),
                            radius: 70,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'Bold',
                              color: Colors.white,
                            ),
                          ),
                        if (_ageGroupCounts['20-29']! > 0)
                          PieChartSectionData(
                            value: _ageGroupCounts['20-29']!.toDouble(),
                            title: '20-29\n${((_ageGroupCounts['20-29']! / totalPatients) * 100).toStringAsFixed(1)}%',
                            color: const Color(0xFF2196F3),
                            radius: 70,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'Bold',
                              color: Colors.white,
                            ),
                          ),
                        if (_ageGroupCounts['30-39']! > 0)
                          PieChartSectionData(
                            value: _ageGroupCounts['30-39']!.toDouble(),
                            title: '30-39\n${((_ageGroupCounts['30-39']! / totalPatients) * 100).toStringAsFixed(1)}%',
                            color: const Color(0xFF4CAF50),
                            radius: 70,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'Bold',
                              color: Colors.white,
                            ),
                          ),
                        if (_ageGroupCounts['40+']! > 0)
                          PieChartSectionData(
                            value: _ageGroupCounts['40+']!.toDouble(),
                            title: '40+\n${((_ageGroupCounts['40+']! / totalPatients) * 100).toStringAsFixed(1)}%',
                            color: const Color(0xFFFF9800),
                            radius: 70,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'Bold',
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  )
                : const Center(child: Text('No patient data yet', style: TextStyle(fontSize: 14, color: Colors.grey))),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('12-19', const Color(0xFF9C27B0)),
              _buildLegendItem('20-29', const Color(0xFF2196F3)),
              _buildLegendItem('30-39', const Color(0xFF4CAF50)),
              _buildLegendItem('40+', const Color(0xFFFF9800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontFamily: 'Medium',
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryTypeChart() {
    int totalDeliveries = _normalDeliveryCount + _cesareanDeliveryCount;
    
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'DELIVERY TYPE',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Bold',
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: totalDeliveries > 0
                ? PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        if (_normalDeliveryCount > 0)
                          PieChartSectionData(
                            value: _normalDeliveryCount.toDouble(),
                            title: 'Normal\n${((_normalDeliveryCount / totalDeliveries) * 100).toStringAsFixed(1)}%',
                            color: const Color(0xFF4CAF50),
                            radius: 70,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Bold',
                              color: Colors.white,
                            ),
                          ),
                        if (_cesareanDeliveryCount > 0)
                          PieChartSectionData(
                            value: _cesareanDeliveryCount.toDouble(),
                            title: 'Cesarean\n${((_cesareanDeliveryCount / totalDeliveries) * 100).toStringAsFixed(1)}%',
                            color: const Color(0xFFF44336),
                            radius: 70,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Bold',
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  )
                : const Center(child: Text('No delivery data yet', style: TextStyle(fontSize: 14, color: Colors.grey))),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Normal', const Color(0xFF4CAF50)),
              const SizedBox(width: 20),
              _buildLegendItem('Cesarean', const Color(0xFFF44336)),
            ],
          ),
        ],
      ),
    );
  }


  List<FlSpot> _getPrenatalSpots() {
    List<FlSpot> spots = [];
    int currentYear = DateTime.now().year;
    for (int i = 0; i < 3; i++) {
      int year = currentYear - 2 + i;
      double count = (_prenatalYearlyCount[year] ?? 0).toDouble();
      spots.add(FlSpot(i.toDouble(), count));
    }
    return spots;
  }

  List<FlSpot> _getPostnatalSpots() {
    List<FlSpot> spots = [];
    int currentYear = DateTime.now().year;
    for (int i = 0; i < 3; i++) {
      int year = currentYear - 2 + i;
      double count = (_postnatalYearlyCount[year] ?? 0).toDouble();
      spots.add(FlSpot(i.toDouble(), count));
    }
    return spots;
  }

  double _calculateMaxY() {
    double maxPrenatal = 0;
    double maxPostnatal = 0;
    
    for (var count in _prenatalYearlyCount.values) {
      if (count > maxPrenatal) maxPrenatal = count.toDouble();
    }
    
    for (var count in _postnatalYearlyCount.values) {
      if (count > maxPostnatal) maxPostnatal = count.toDouble();
    }
    
    double max = maxPrenatal > maxPostnatal ? maxPrenatal : maxPostnatal;
    return max > 0 ? max + (max * 0.2) : 100; // Add 20% padding or minimum 100
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontFamily: 'Medium',
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCountingChart() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'PATIENT HISTORY TRENDS',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Bold',
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          if (_prenatalYearlyCount.isNotEmpty || _postnatalYearlyCount.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_postnatalYearlyCount.isNotEmpty) _buildLegend('Postnatal', Colors.red),
                if (_postnatalYearlyCount.isNotEmpty && _prenatalYearlyCount.isNotEmpty) const SizedBox(width: 30),
                if (_prenatalYearlyCount.isNotEmpty) _buildLegend('Prenatal', const Color(0xFF3F51B5)),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1000,
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          int currentYear = DateTime.now().year;
                          switch (value.toInt()) {
                            case 0:
                              return Text('${currentYear - 2}',
                                  style: const TextStyle(fontSize: 12, fontFamily: 'Regular'));
                            case 1:
                              return Text('${currentYear - 1}',
                                  style: const TextStyle(fontSize: 12, fontFamily: 'Regular'));
                            case 2:
                              return Text('$currentYear',
                                  style: const TextStyle(fontSize: 12, fontFamily: 'Regular'));
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: 1000,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Regular',
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                      left: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  minX: 0,
                  maxX: 2,
                  minY: 0,
                  maxY: _calculateMaxY(),
                  lineBarsData: [
                    // Prenatal line (blue)
                    if (_prenatalYearlyCount.isNotEmpty)
                      LineChartBarData(
                        spots: _getPrenatalSpots(),
                        isCurved: true,
                        color: const Color(0xFF3F51B5),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 5,
                              color: const Color(0xFF3F51B5),
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFF3F51B5).withOpacity(0.1),
                        ),
                      ),
                    // Postnatal line (red)
                    if (_postnatalYearlyCount.isNotEmpty)
                      LineChartBarData(
                        spots: _getPostnatalSpots(),
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 5,
                              color: Colors.red,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.red.withOpacity(0.1),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Placeholder Screens
class PrenatalPatientRecordPlaceholder extends StatelessWidget {
  const PrenatalPatientRecordPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text(
          'Prenatal Patient Record',
          style: TextStyle(fontFamily: 'Bold'),
        ),
      ),
      body: const Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Center(
            child: Text(
              'Prenatal Patient Record\n(Coming Soon)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Medium',
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PostnatalPatientRecordPlaceholder extends StatelessWidget {
  const PostnatalPatientRecordPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text(
          'Postnatal Patient Record',
          style: TextStyle(fontFamily: 'Bold'),
        ),
      ),
      body: const Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Center(
            child: Text(
              'Postnatal Patient Record\n(Coming Soon)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Medium',
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppointmentSchedulingPlaceholder extends StatelessWidget {
  const AppointmentSchedulingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text(
          'Appointment Scheduling',
          style: TextStyle(fontFamily: 'Bold'),
        ),
      ),
      body: const Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Center(
            child: Text(
              'Appointment Scheduling\n(Coming Soon)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Medium',
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
