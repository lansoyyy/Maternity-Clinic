import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/colors.dart';
import '../../utils/history_logger.dart';
import '../../utils/responsive_utils.dart';
import 'admin_dashboard_screen.dart';
import 'admin_appointment_scheduling_screen.dart';
import 'admin_appointment_management_screen.dart';
import 'admin_patient_records_screen.dart';
import '../auth/home_screen.dart';

class AdminStaffManagementScreen extends StatefulWidget {
  final String userRole;
  final String userName;

  const AdminStaffManagementScreen({
    super.key,
    required this.userRole,
    required this.userName,
  });

  @override
  State<AdminStaffManagementScreen> createState() =>
      _AdminStaffManagementScreenState();
}

class _AdminStaffManagementScreenState extends State<AdminStaffManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool get _isAdmin => widget.userRole == 'admin';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddStaffDialog() async {
    if (!_isAdmin) return;

    final TextEditingController nameController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    String role = 'nurse';
    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text(
                'Add Staff Account',
                style: TextStyle(fontFamily: 'Bold'),
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Staff Name',
                        style: TextStyle(fontSize: 13, fontFamily: 'Regular'),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Username',
                        style: TextStyle(fontSize: 13, fontFamily: 'Regular'),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Role',
                        style: TextStyle(fontSize: 13, fontFamily: 'Regular'),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: role,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'nurse',
                            child: Text('Nurse'),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                        ],
                        onChanged: (value) {
                          setStateDialog(() {
                            role = value ?? 'nurse';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Password',
                        style: TextStyle(fontSize: 13, fontFamily: 'Regular'),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Confirm Password',
                        style: TextStyle(fontSize: 13, fontFamily: 'Regular'),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontFamily: 'Regular',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          final username =
                              usernameController.text.trim().toLowerCase();
                          final password = passwordController.text.trim();
                          final confirm =
                              confirmPasswordController.text.trim();

                          if (name.isEmpty ||
                              username.isEmpty ||
                              password.isEmpty ||
                              confirm.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in all fields'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (password != confirm) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Password and confirm password do not match'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setStateDialog(() {
                            isSaving = true;
                          });

                          try {
                            final docRef = _firestore
                                .collection('staffAccounts')
                                .doc(username);
                            final existing = await docRef.get();
                            if (existing.exists) {
                              setStateDialog(() {
                                isSaving = false;
                              });
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Username already exists'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            await docRef.set({
                              'username': username,
                              'name': name,
                              'role': role,
                              'password': password,
                              'createdAt': FieldValue.serverTimestamp(),
                              'createdBy': widget.userName,
                            });

                            await HistoryLogger.log(
                              role: widget.userRole,
                              userName: widget.userName,
                              action:
                                  '${widget.userName} (ADMIN) added staff account $username ($role)',
                              metadata: {
                                'username': username,
                                'staffName': name,
                                'staffRole': role,
                              },
                            );

                            if (!mounted) return;
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Staff account added'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (_) {
                            setStateDialog(() {
                              isSaving = false;
                            });
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to add staff account'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(fontFamily: 'Bold'),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteStaffAccount(Map<String, dynamic> staff) async {
    final String username = (staff['username'] ?? '').toString();
    if (username.isEmpty) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Staff Account',
          style: TextStyle(fontFamily: 'Bold'),
        ),
        content: Text(
          'Are you sure you want to delete the staff account "$username"?',
          style: const TextStyle(fontFamily: 'Regular'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade700, fontFamily: 'Medium'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red.shade600, fontFamily: 'Bold'),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _firestore.collection('staffAccounts').doc(username).delete();

      await HistoryLogger.log(
        role: widget.userRole,
        userName: widget.userName,
        action:
            '${widget.userName} (ADMIN) deleted staff account $username',
        metadata: {
          'username': username,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Staff account deleted'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete staff account'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'Access denied',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Bold',
              color: Colors.grey.shade700,
            ),
          ),
        ),
      );
    }

    final isMobile = context.isMobile;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: isMobile ? AppBar(
        backgroundColor: primary,
        title: Text(
          'STAFF MANAGEMENT',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.responsiveFontSize(18),
            fontFamily: 'Bold',
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ) : null,
      drawer: isMobile ? Drawer(
        child: _buildSidebar(),
      ) : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMobile) _buildHeader(),
                  if (!isMobile) const SizedBox(height: 20),
                  isMobile 
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search staff',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Regular',
                                color: Colors.grey.shade500,
                              ),
                              prefixIcon: const Icon(Icons.search, size: 18),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: primary, width: 1.5),
                              ),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _showAddStaffDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.person_add, color: Colors.white),
                            label: const Text(
                              'Add Staff',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Bold',
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search staff',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Regular',
                                  color: Colors.grey.shade500,
                                ),
                                prefixIcon: const Icon(Icons.search, size: 18),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: primary, width: 1.5),
                                ),
                                isDense: true,
                              ),
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: _showAddStaffDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.person_add, color: Colors.white),
                            label: const Text(
                              'Add Staff',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Bold',
                              ),
                            ),
                          ),
                        ],
                      ),
                  SizedBox(height: isMobile ? 16 : 20),
                  _buildStaffTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.badge, size: 28, color: Colors.black87),
          SizedBox(width: 12),
          Text(
            'Staff Management',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Bold',
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicWidth(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('staffAccounts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator(color: primary)),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final items = docs.map((d) {
            final data = d.data() as Map<String, dynamic>;
            return {
              'id': d.id,
              ...data,
            };
          }).where((m) {
            if (_searchQuery.isEmpty) return true;
            final name = (m['name'] ?? '').toString().toLowerCase();
            final username = (m['username'] ?? m['id'] ?? '')
                .toString()
                .toLowerCase();
            final role = (m['role'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery) ||
                username.contains(_searchQuery) ||
                role.contains(_searchQuery);
          }).toList();

          if (items.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: Text(
                  'No staff accounts found',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Regular',
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            );
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: const [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Name',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Bold', fontSize: 12),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Username',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Bold', fontSize: 12),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Role',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Bold', fontSize: 12),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Action',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Bold', fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...items.map((staff) {
                final String staffName = (staff['name'] ?? '').toString();
                final String username =
                    (staff['username'] ?? staff['id'] ?? '').toString();
                final String role = (staff['role'] ?? '').toString();

                final bool canDelete = username.toLowerCase() != 'admin';

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          staffName.isEmpty ? '-' : staffName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Regular',
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          username,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Regular',
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          role.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Bold',
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            color: canDelete ? Colors.red : Colors.grey,
                            onPressed: canDelete
                                ? () => _deleteStaffAccount({
                                      ...staff,
                                      'username': username,
                                    })
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
        ),
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
          _buildMenuItem('PATIENT RECORDS', false),
          _buildMenuItem('HISTORY LOGS', false),
          _buildMenuItem('ADD NEW STAFF/NURSE', true),
          _buildMenuItem('CHANGE PASSWORD', false),
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
            color: isActive
                ? Colors.white.withOpacity(0.2)
                : Colors.transparent,
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
        screen = AdminPatientRecordsScreen(
          userRole: widget.userRole,
          userName: widget.userName,
        );
        break;
      case 'HISTORY LOGS':
        screen = AdminDashboardScreen(
          userRole: widget.userRole,
          userName: widget.userName,
          openHistoryLogsOnLoad: true,
        );
        break;
      case 'CHANGE PASSWORD':
        screen = AdminDashboardScreen(
          userRole: widget.userRole,
          userName: widget.userName,
          openChangePasswordOnLoad: true,
        );
        break;
      case 'ADD NEW STAFF/NURSE':
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
              style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Medium'),
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
