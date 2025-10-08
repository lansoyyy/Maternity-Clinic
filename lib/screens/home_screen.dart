import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'contact_us_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Navigation Bar
            _buildHeader(),

            // Main Content
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: 40,
              ),
              child: screenWidth > 900
                  ? _buildDesktopLayout(screenWidth, screenHeight)
                  : _buildMobileLayout(screenWidth, screenHeight),
            ),

            // Footer Section
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, secondary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          const Text(
            'VICTORY LYING IN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: 'Bold',
              letterSpacing: 1.2,
            ),
          ),

          // Navigation Menu
          Wrap(
            spacing: 40,
            children: [
              _buildNavItem('HOME', true),
              _buildNavItem('ABOUT US', false),
              _buildNavItem('SERVICES', false),
              _buildNavItem('STAFF & DOCTORS', false),
              _buildNavItem('CONTACT US', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, bool isActive) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _handleNavigation(title);
        },
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: isActive ? 'Bold' : 'Medium',
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _handleNavigation(String title) {
    switch (title) {
      case 'HOME':
        // Already on home screen
        break;
      case 'ABOUT US':
        // TODO: Navigate to About Us screen
        break;
      case 'SERVICES':
        // TODO: Navigate to Services screen
        break;
      case 'STAFF & DOCTORS':
        // TODO: Navigate to Staff & Doctors screen
        break;
      case 'CONTACT US':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ContactUsScreen()),
        );
        break;
    }
  }

  Widget _buildDesktopLayout(double screenWidth, double screenHeight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,

      children: [
        // Left Section - Services
        Expanded(
          flex: 3,
          child: Column(
            
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildServiceItem(
                'assets/images/ob-gyne.png',
                'OB - GYNE',
              ),
              const SizedBox(height: 30),
              _buildServiceItem(
                'assets/images/ultra sound.png',
                'ULTRA SOUND',
              ),
              const SizedBox(height: 30),
              _buildServiceItem(
                'assets/images/pediatrics.png',
                'PEDIATRICS',
              ),
            ],
          ),
        ),

        // Center Section - Illustration
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Image.asset(
                'assets/images/figure.png',
                height: screenHeight * 0.4,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),

        // Right Section - Sign In Form
        Expanded(
          flex: 3,
          child: _buildSignInCard(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(double screenWidth, double screenHeight) {
    return Column(
      children: [
        _buildSignInCard(),
        const SizedBox(height: 40),
        Image.asset(
          'assets/images/figure.png',
          height: screenHeight * 0.3,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 40),
        _buildServiceItem('assets/images/ob-gyne.png', 'OB - GYNE'),
        const SizedBox(height: 20),
        _buildServiceItem('assets/images/ultra sound.png', 'ULTRA SOUND'),
        const SizedBox(height: 20),
        _buildServiceItem('assets/images/pediatrics.png', 'PEDIATRICS'),
      ],
    );
  }

  Widget _buildServiceItem(String iconPath, String title) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: orangePallete,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(18),
          child: Image.asset(
            iconPath,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontFamily: 'Bold',
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSignInCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'WELCOME ',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Regular',
                  color: Colors.black,
                ),
              ),
              Icon(
                Icons.favorite_border,
                color: Colors.grey.shade700,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'BELOVE PATIENT',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontFamily: 'Bold',
              color: Colors.black,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 30),

          // Sign In Title
          Text(
            'SIGN IN',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'Bold',
              color: primary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 25),

          // Email Field
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Email address',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontFamily: 'Regular',
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
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
                borderSide: BorderSide(color: primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Password Field
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Password',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontFamily: 'Regular',
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
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
                borderSide: BorderSide(color: primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Forget Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Handle forget password
              },
              child: const Text(
                'Forget Password?',
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Regular',
                  fontSize: 13,
                ),
              ),
            ),
          ),

          // Remember Me Checkbox
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  activeColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Remember me',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Regular',
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sign In Button
          ElevatedButton(
            onPressed: () {
              // Handle sign in
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'SIGN IN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Bold',
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Create Account Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'New here? ',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Regular',
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Handle create account
                },
                child: Text(
                  'Create an Account',
                  style: TextStyle(
                    color: primary,
                    fontFamily: 'Medium',
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Admin Button
          OutlinedButton(
            onPressed: () {
              // Handle admin login
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: primary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'ADMIN',
              style: TextStyle(
                color: primary,
                fontSize: 14,
                fontFamily: 'Bold',
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, secondary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: const Text(
        'We care about your health\nand well - being',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontFamily: 'Bold',
          height: 1.3,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
