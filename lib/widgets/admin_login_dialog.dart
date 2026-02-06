import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maternity_clinic/screens/admin/admin_dashboard_screen.dart';

import '../utils/colors.dart';
import '../services/audit_log_service.dart';

class AdminLoginDialog extends StatefulWidget {
  const AdminLoginDialog({super.key});

  @override
  State<AdminLoginDialog> createState() => _AdminLoginDialogState();
}

class _AdminLoginDialogState extends State<AdminLoginDialog> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Hardcoded user credentials
  final Map<String, Map<String, String>> _userCredentials = {
    'admin': {'password': 'admin123', 'role': 'admin', 'name': 'Administrator'},
    'nurse1': {'password': 'nurse123', 'role': 'nurse', 'name': 'Nurse 1'},
    'nurse2': {'password': 'nurse123', 'role': 'nurse', 'name': 'Nurse 2'},
  };

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog('Please enter both username and password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? role;
      String? name;

      try {
        final doc =
            await _firestore.collection('staffAccounts').doc(username).get();
        if (doc.exists) {
          final data = doc.data();
          final storedPassword = (data?['password'] ?? '').toString();
          if (storedPassword.isNotEmpty && storedPassword == password) {
            role = (data?['role'] ?? '').toString();
            name = (data?['name'] ?? '').toString();
          }
        }
      } catch (_) {}

      if (role == null || name == null || role.isEmpty || name.isEmpty) {
        if (_userCredentials.containsKey(username) &&
            _userCredentials[username]?['password'] == password) {
          final userData = _userCredentials[username]!;
          role = userData['role']!;
          name = userData['name']!;
        }
      }

      if (role != null && name != null && role.isNotEmpty && name.isNotEmpty) {
        await AuditLogService.log(
          role: role,
          userName: name,
          action: '$name logged in',
          entityType: 'auth',
          entityId: username,
        );

        if (!mounted) return;
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDashboardScreen(
              userRole: role!,
              userName: name!,
            ),
          ),
        );
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Invalid username or password');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Login failed. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Login Error',
          style: TextStyle(fontFamily: 'Bold'),
        ),
        content: Text(
          message,
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Close Button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey.shade600,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(height: 10),

              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 25),

              // Title
              Text(
                'Admin Login',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: 'Bold',
                  color: primary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              // Description
              Text(
                'Access the administrative dashboard',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Regular',
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),

              // Username Field
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontFamily: 'Regular',
                    fontSize: 14,
                  ),
                  hintText: 'Enter admin username',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontFamily: 'Regular',
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: primary,
                    size: 22,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontFamily: 'Regular',
                    fontSize: 14,
                  ),
                  hintText: 'Enter admin password',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontFamily: 'Regular',
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: primary,
                    size: 22,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primary, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Login Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Bold',
                          letterSpacing: 0.5,
                        ),
                      ),
              ),

              const SizedBox(height: 15),

              // Back to Patient Login
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Back to Patient Login',
                  style: TextStyle(
                    color: primary,
                    fontSize: 14,
                    fontFamily: 'Medium',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
