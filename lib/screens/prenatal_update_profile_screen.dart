import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/colors.dart';

class PrenatalUpdateProfileScreen extends StatefulWidget {
  const PrenatalUpdateProfileScreen({super.key});

  @override
  State<PrenatalUpdateProfileScreen> createState() =>
      _PrenatalUpdateProfileScreenState();
}

class _PrenatalUpdateProfileScreenState
    extends State<PrenatalUpdateProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  bool _isSaving = false;

  // Basic info
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();

  DateTime? _dob;
  int? _computedAge;

  // Address
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _barangayController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  // Civil status & emergency contact
  final TextEditingController _civilStatusController = TextEditingController();
  final TextEditingController _emergencyNameController =
      TextEditingController();
  final TextEditingController _emergencyNumberController =
      TextEditingController();

  // Pregnancy details
  DateTime? _lmpDate;
  final TextEditingController _gravidaController = TextEditingController();
  final TextEditingController _paraController = TextEditingController();
  final TextEditingController _miscarriagesController = TextEditingController();

  // Derived from LMP (for display only)
  DateTime? _estimatedDueDate;
  int? _gestationalWeeks;

  // View-only clinical fields that staff/admin may update later
  String? _height;
  String? _weight;
  String? _bloodPressure;
  DateTime? _confirmedEdd;
  int? _confirmedGestationWeeks;
  String? _pregnancyStatus;
  String? _specificComplication;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _contactNumberController.dispose();
    _houseNoController.dispose();
    _streetController.dispose();
    _barangayController.dispose();
    _cityController.dispose();
    _civilStatusController.dispose();
    _emergencyNameController.dispose();
    _emergencyNumberController.dispose();
    _gravidaController.dispose();
    _paraController.dispose();
    _miscarriagesController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        _fullNameController.text = (data['name'] ?? '').toString();
        _emailController.text = (data['email'] ?? user.email ?? '').toString();
        _contactNumberController.text =
            (data['contactNumber'] ?? '').toString();

        if (data['dob'] is Timestamp) {
          _dob = (data['dob'] as Timestamp).toDate();
        }

        _houseNoController.text = (data['addressHouseNo'] ?? '').toString();
        _streetController.text = (data['addressStreet'] ?? '').toString();
        _barangayController.text = (data['addressBarangay'] ?? '').toString();
        _cityController.text = (data['addressCity'] ?? '').toString();

        _civilStatusController.text = (data['civilStatus'] ?? '').toString();
        _emergencyNameController.text =
            (data['emergencyContactName'] ?? '').toString();
        _emergencyNumberController.text =
            (data['emergencyContactNumber'] ?? '').toString();

        if (data['lmpDate'] is Timestamp) {
          _lmpDate = (data['lmpDate'] as Timestamp).toDate();
        }

        _gravidaController.text = data['gravida']?.toString() ?? '';
        _paraController.text = data['para']?.toString() ?? '';
        _miscarriagesController.text = data['miscarriages']?.toString() ?? '';

        // View-only clinical fields
        _height = data['height']?.toString();
        _weight = data['weight']?.toString();
        _bloodPressure = data['bloodPressure']?.toString();
        if (data['confirmedEdd'] is Timestamp) {
          _confirmedEdd = (data['confirmedEdd'] as Timestamp).toDate();
        }
        if (data['confirmedGestationWeeks'] != null) {
          _confirmedGestationWeeks =
              int.tryParse(data['confirmedGestationWeeks'].toString());
        }
        _pregnancyStatus = data['pregnancyStatus']?.toString();
        _specificComplication = data['specificComplication']?.toString();

        _recomputeDerivedValues();
      }
    } catch (_) {
      // On error we just stop loading; UI will show empty fields
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _recomputeDerivedValues() {
    final now = DateTime.now();

    if (_dob != null) {
      int age = now.year - _dob!.year;
      final birthdayThisYear = DateTime(now.year, _dob!.month, _dob!.day);
      if (now.isBefore(birthdayThisYear)) {
        age -= 1;
      }
      _computedAge = age;
    }

    if (_lmpDate != null) {
      _estimatedDueDate = _lmpDate!.add(const Duration(days: 280));
      final days = now.difference(_lmpDate!).inDays;
      if (days >= 0) {
        _gestationalWeeks = days ~/ 7;
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    if (_fullNameController.text.trim().isEmpty) {
      _showError('Please enter your full name');
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      _showError('Please enter your email address');
      return;
    }
    if (_contactNumberController.text.trim().isEmpty) {
      _showError('Please enter your contact number');
      return;
    }
    if (_houseNoController.text.trim().isEmpty ||
        _streetController.text.trim().isEmpty ||
        _barangayController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty) {
      _showError('Please enter your complete address');
      return;
    }
    if (_civilStatusController.text.trim().isEmpty) {
      _showError('Please enter your civil status');
      return;
    }
    if (_emergencyNameController.text.trim().isEmpty ||
        _emergencyNumberController.text.trim().isEmpty) {
      _showError('Please enter your emergency contact details');
      return;
    }
    if (_lmpDate == null) {
      _showError('Please select your Last Menstrual Period (LMP) date');
      return;
    }
    final gravida = int.tryParse(_gravidaController.text.trim().isEmpty
        ? '0'
        : _gravidaController.text.trim());
    final para = int.tryParse(_paraController.text.trim().isEmpty
        ? '0'
        : _paraController.text.trim());
    final miscarriages = int.tryParse(
        _miscarriagesController.text.trim().isEmpty
            ? '0'
            : _miscarriagesController.text.trim());

    if (gravida == null || para == null || miscarriages == null) {
      _showError('Please enter valid numbers for pregnancy history');
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      _showError('User is not logged in');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      _recomputeDerivedValues();

      final fullAddress = '${_houseNoController.text.trim()}, '
          '${_streetController.text.trim()}, '
          '${_barangayController.text.trim()}, '
          '${_cityController.text.trim()}';

      int? ageToStore = _computedAge;
      if (ageToStore == null && _dob != null) {
        final now = DateTime.now();
        int age = now.year - _dob!.year;
        final birthdayThisYear = DateTime(now.year, _dob!.month, _dob!.day);
        if (now.isBefore(birthdayThisYear)) {
          age -= 1;
        }
        ageToStore = age;
      }

      final Map<String, dynamic> updateData = {
        'name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'contactNumber': _contactNumberController.text.trim(),
        'addressHouseNo': _houseNoController.text.trim(),
        'addressStreet': _streetController.text.trim(),
        'addressBarangay': _barangayController.text.trim(),
        'addressCity': _cityController.text.trim(),
        'address': fullAddress,
        'civilStatus': _civilStatusController.text.trim(),
        'emergencyContactName': _emergencyNameController.text.trim(),
        'emergencyContactNumber': _emergencyNumberController.text.trim(),
        'lmpDate': Timestamp.fromDate(_lmpDate!),
        'gravida': gravida,
        'para': para,
        'miscarriages': miscarriages,
        'profileCompleted': true,
      };

      if (_dob != null) {
        updateData['dob'] = Timestamp.fromDate(_dob!);
      }
      if (ageToStore != null) {
        updateData['age'] = ageToStore;
      }

      await _firestore.collection('users').doc(user.uid).update(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Profile updated successfully',
              style: TextStyle(fontFamily: 'Regular'),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to update profile. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Regular'),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text(
          'Update Profile',
          style: TextStyle(fontFamily: 'Bold'),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: const Text(
                      'Before you can book an appointment, you need to complete your profile information below.',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Regular',
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  _buildBasicInfoSection(),
                  const SizedBox(height: 24),
                  _buildRequiredProfileSection(),
                  const SizedBox(height: 24),
                  _buildDerivedInfoSection(),
                  const SizedBox(height: 24),
                  _buildClinicalViewOnlySection(),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Bold',
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Bold',
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Full Name',
            controller: _fullNameController,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildReadOnlyField(
                  label: 'Age (years)',
                  value:
                      _computedAge?.toString() ?? 'Will be calculated from DOB',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDobPicker(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Email Address',
            controller: _emailController,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Contact Number',
            controller: _contactNumberController,
          ),
        ],
      ),
    );
  }

  Widget _buildDobPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Birth (DOB)',
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Regular',
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final now = DateTime.now();
            final initial = _dob ?? DateTime(now.year - 25, now.month, now.day);
            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(now.year - 60),
              lastDate: now,
            );
            if (picked != null) {
              setState(() {
                _dob = picked;
                _recomputeDerivedValues();
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: primary),
                const SizedBox(width: 8),
                Text(
                  _dob == null
                      ? 'Select Date of Birth'
                      : '${_dob!.month.toString().padLeft(2, '0')}/${_dob!.day.toString().padLeft(2, '0')}/${_dob!.year}',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Regular',
                    color: _dob == null ? Colors.grey.shade600 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequiredProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Required Profile Information (for booking appointments)',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Bold',
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Complete Address',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Bold',
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'House No.',
                  controller: _houseNoController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'Street',
                  controller: _streetController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Barangay',
                  controller: _barangayController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'City',
                  controller: _cityController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Civil Status (e.g., Single, Married, Live-in Partner)',
            controller: _civilStatusController,
          ),
          const SizedBox(height: 16),
          const Text(
            'Emergency Contact',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Bold',
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            label: 'Emergency Contact Name',
            controller: _emergencyNameController,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Emergency Contact Number',
            controller: _emergencyNumberController,
          ),
          const SizedBox(height: 16),
          const Text(
            'Pregnancy Details',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Bold',
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildLmpPicker(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Number of Previous Pregnancies (Gravida)',
                  controller: _gravidaController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'Number of Living Children (Para)',
                  controller: _paraController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Number of Miscarriages / Abortions',
            controller: _miscarriagesController,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildLmpPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Last Menstrual Period (LMP)',
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Regular',
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final now = DateTime.now();
            final initial = _lmpDate ?? now.subtract(const Duration(days: 28));
            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: now.subtract(const Duration(days: 280)),
              lastDate: now,
            );
            if (picked != null) {
              setState(() {
                _lmpDate = picked;
                _recomputeDerivedValues();
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: primary),
                const SizedBox(width: 8),
                Text(
                  _lmpDate == null
                      ? 'Select LMP Date'
                      : '${_lmpDate!.month.toString().padLeft(2, '0')}/${_lmpDate!.day.toString().padLeft(2, '0')}/${_lmpDate!.year}',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Regular',
                    color: _lmpDate == null
                        ? Colors.grey.shade600
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDerivedInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Calculations (based on LMP)',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Bold',
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildReadOnlyField(
            label: 'Estimated Due Date (EDD)',
            value: _estimatedDueDate == null
                ? 'Will be calculated after you set LMP'
                : '${_estimatedDueDate!.month.toString().padLeft(2, '0')}/${_estimatedDueDate!.day.toString().padLeft(2, '0')}/${_estimatedDueDate!.year}',
          ),
          const SizedBox(height: 12),
          _buildReadOnlyField(
            label: 'Age of Gestation (weeks)',
            value: _gestationalWeeks == null
                ? 'Will be calculated after you set LMP'
                : '${_gestationalWeeks.toString()} weeks',
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalViewOnlySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clinical Information (updated by staff/admin)',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Bold',
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildReadOnlyField(
            label: 'Height',
            value: _height ?? 'Not yet recorded',
          ),
          const SizedBox(height: 8),
          _buildReadOnlyField(
            label: 'Weight',
            value: _weight ?? 'Not yet recorded',
          ),
          const SizedBox(height: 8),
          _buildReadOnlyField(
            label: 'Blood Pressure',
            value: _bloodPressure ?? 'Not yet recorded',
          ),
          const SizedBox(height: 8),
          _buildReadOnlyField(
            label: 'Confirmed EDD',
            value: _confirmedEdd == null
                ? 'Not yet recorded'
                : '${_confirmedEdd!.month.toString().padLeft(2, '0')}/${_confirmedEdd!.day.toString().padLeft(2, '0')}/${_confirmedEdd!.year}',
          ),
          const SizedBox(height: 8),
          _buildReadOnlyField(
            label: 'Age of Gestation (confirmed)',
            value: _confirmedGestationWeeks == null
                ? 'Not yet recorded'
                : '${_confirmedGestationWeeks.toString()} weeks',
          ),
          const SizedBox(height: 8),
          _buildReadOnlyField(
            label: 'Pregnancy Status',
            value: _pregnancyStatus ?? 'Not yet recorded',
          ),
          const SizedBox(height: 8),
          _buildReadOnlyField(
            label: 'Specific Complication',
            value: _specificComplication ?? 'Not yet recorded',
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Regular',
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Regular',
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Regular',
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }
}
