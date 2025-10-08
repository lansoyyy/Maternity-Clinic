import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/colors.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
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
          _buildMenuItem('DATA GRAPHS', true),
          _buildMenuItem('PRENATAL PATIENT\nRECORD', false),
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
        screen = const PrenatalPatientRecordPlaceholder();
        break;
      case 'POSTNATAL PATIENT\nRECORD':
        screen = const PostnatalPatientRecordPlaceholder();
        break;
      case 'APPOINTMENT\nSCHEDULING':
        screen = const AppointmentSchedulingPlaceholder();
        break;
      default:
        return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Widget _buildPrenatalPostnatalChart() {
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
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 0,
                sections: [
                  PieChartSectionData(
                    value: 56.7,
                    title: 'PRE NATAL\n56.7%',
                    color: const Color(0xFF5DCED9),
                    radius: 100,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Bold',
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 21.3,
                    title: 'POSTNATAL\n21.3%',
                    color: const Color(0xFF3F51B5),
                    radius: 100,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Bold',
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 22,
                    title: '',
                    color: const Color(0xFF5B6B9E),
                    radius: 100,
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
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 35,
                sections: [
                  PieChartSectionData(
                    value: 35,
                    title: 'MINOR AGE: 211\n35.0%',
                    color: const Color(0xFF5DCED9),
                    radius: 70,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'Bold',
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 40,
                    title: 'YOUNG ADULTS 18E: 285\n40.0%',
                    color: const Color(0xFF3F7B9E),
                    radius: 70,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'Bold',
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 25,
                    title: 'ADULTS 31+: 185\n25.0%',
                    color: const Color(0xFF3F51B5),
                    radius: 70,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'Bold',
                      color: Colors.white,
                    ),
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
              'AGE PERCENTAGE',
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
              _buildLegend('NORMAL', const Color(0xFF5DCED9)),
              const SizedBox(width: 20),
              _buildLegend('CESAREAN', const Color(0xFF3F7B9E)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 200,
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
                  horizontalInterval: 50,
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: 100,
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
                        toY: 180,
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
              'POSTNATAL ( NORMAL VS CESAREAN)',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('postnatal', Colors.red),
              const SizedBox(width: 30),
              _buildLegend('prenatal', const Color(0xFF3F51B5)),
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
                        switch (value.toInt()) {
                          case 0:
                            return const Text('2023',
                                style: TextStyle(fontSize: 12, fontFamily: 'Regular'));
                          case 1:
                            return const Text('2024',
                                style: TextStyle(fontSize: 12, fontFamily: 'Regular'));
                          case 2:
                            return const Text('2025',
                                style: TextStyle(fontSize: 12, fontFamily: 'Regular'));
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
                maxY: 5000,
                lineBarsData: [
                  // Prenatal line (blue)
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1500),
                      FlSpot(1, 3000),
                      FlSpot(2, 4200),
                    ],
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
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 2000),
                      FlSpot(1, 1000),
                      FlSpot(2, 2000),
                    ],
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
