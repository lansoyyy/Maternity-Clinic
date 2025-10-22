import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maternity_clinic/screens/admin/admin_appointment_scheduling_screen.dart';
import 'package:maternity_clinic/screens/admin/admin_postnatal_records_screen.dart';
import 'package:maternity_clinic/screens/admin/admin_prenatal_records_screen.dart';
import 'package:maternity_clinic/screens/admin/admin_transfer_requests_screen.dart';
import '../../utils/colors.dart';


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
          _completedAppointments = completed;
          _cancelledAppointments = cancelled;
          _prenatalAppointments = prenatalAppts;
          _postnatalAppointments = postnatalAppts;
          _prenatalYearlyCount = prenatalYearly;
          _postnatalYearlyCount = postnatalYearly;
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
                        // Top Row - Pie Charts
                        Row(
                          children: [
                            Expanded(
                              child: _buildPrenatalPostnatalChart(),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildAgePercentageChart(),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildPostnatalBarChart(),
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

  Widget _buildAgePercentageChart() {
    int total = _pendingAppointments + _acceptedAppointments + _completedAppointments + _cancelledAppointments;
    double pendingPercent = total > 0 ? (_pendingAppointments / total) * 100 : 0;
    double acceptedPercent = total > 0 ? (_acceptedAppointments / total) * 100 : 0;
    double completedPercent = total > 0 ? (_completedAppointments / total) * 100 : 0;
    double cancelledPercent = total > 0 ? (_cancelledAppointments / total) * 100 : 0;
    
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
            height: 200,
            child: total > 0
                ? PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 35,
                      sections: [
                        if (_pendingAppointments > 0)
                          PieChartSectionData(
                            value: _pendingAppointments.toDouble(),
                            title: 'PENDING: $_pendingAppointments\n${pendingPercent.toStringAsFixed(1)}%',
                            color: Colors.orange,
                            radius: 70,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'Bold',
                              color: Colors.white,
                            ),
                          ),
                        if (_acceptedAppointments > 0)
                          PieChartSectionData(
                            value: _acceptedAppointments.toDouble(),
                            title: 'ACCEPTED: $_acceptedAppointments\n${acceptedPercent.toStringAsFixed(1)}%',
                            color: Colors.green,
                            radius: 70,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'Bold',
                              color: Colors.white,
                            ),
                          ),
                        if (_completedAppointments > 0)
                          PieChartSectionData(
                            value: _completedAppointments.toDouble(),
                            title: 'COMPLETED: $_completedAppointments\n${completedPercent.toStringAsFixed(1)}%',
                            color: Colors.blue,
                            radius: 70,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'Bold',
                              color: Colors.white,
                            ),
                          ),
                        if (_cancelledAppointments > 0)
                          PieChartSectionData(
                            value: _cancelledAppointments.toDouble(),
                            title: 'CANCELLED: $_cancelledAppointments\n${cancelledPercent.toStringAsFixed(1)}%',
                            color: Colors.red,
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
                : const Center(child: Text('No appointments yet', style: TextStyle(fontSize: 14, color: Colors.grey))),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Text(
              'APPOINTMENT STATUS',
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

  Widget _buildPostnatalBarChart() {
    int maxValue = _prenatalAppointments > _postnatalAppointments ? _prenatalAppointments : _postnatalAppointments;
    
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('PRENATAL', const Color(0xFF5DCED9)),
              const SizedBox(width: 20),
              _buildLegend('POSTNATAL', const Color(0xFF3F7B9E)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue > 0 ? maxValue.toDouble() + 10 : 10,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
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
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue > 10 ? 5 : 2,
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: _prenatalAppointments.toDouble(),
                        color: const Color(0xFF5DCED9),
                        width: 60,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: _postnatalAppointments.toDouble(),
                        color: const Color(0xFF3F7B9E),
                        width: 60,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Text(
              'APPOINTMENTS BY PATIENT TYPE',
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
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_prenatalYearlyCount.isNotEmpty || _postnatalYearlyCount.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_postnatalYearlyCount.isNotEmpty) _buildLegend('postnatal', Colors.red),
                if (_postnatalYearlyCount.isNotEmpty && _prenatalYearlyCount.isNotEmpty) const SizedBox(width: 30),
                if (_prenatalYearlyCount.isNotEmpty) _buildLegend('prenatal', const Color(0xFF3F51B5)),
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
                        isCurved: false,
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
                        belowBarData: BarAreaData(show: false),
                      ),
                    // Postnatal line (red)
                    if (_postnatalYearlyCount.isNotEmpty)
                      LineChartBarData(
                        spots: _getPostnatalSpots(),
                        isCurved: false,
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
                        belowBarData: BarAreaData(show: false),
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Text(
              'HISTORY COUNTING PATIENT',
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
