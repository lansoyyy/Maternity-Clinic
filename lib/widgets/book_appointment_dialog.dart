import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';

class BookAppointmentDialog extends StatefulWidget {
  final String patientType;

  const BookAppointmentDialog({
    super.key,
    required this.patientType,
  });

  @override
  State<BookAppointmentDialog> createState() => _BookAppointmentDialogState();
}

class _BookAppointmentDialogState extends State<BookAppointmentDialog> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _selectedDay = 'Tuesday';
  String _selectedTime = '4:00 PM - 6:00 PM';
  String _appointmentType = 'Clinic';
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  final List<String> _weekdays = ['Tuesday', 'Wednesday', 'Friday'];
  final List<String> _saturdayTypes = ['Ultrasound', 'Clinic'];

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _getTimeSlot() {
    if (_selectedDay == 'Saturday') {
      if (_appointmentType == 'Ultrasound') {
        return '10:00 AM - 12:00 NN';
      } else {
        return '12:00 NN - 3:00 PM';
      }
    } else {
      return '4:00 PM - 6:00 PM';
    }
  }

  Future<void> _bookAppointment() async {
    if (_reasonController.text.trim().isEmpty) {
      _showErrorDialog('Please enter the reason for appointment');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Get user data
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String userName = userData['name'] ?? 'User';

        // Create appointment
        await _firestore.collection('appointments').add({
          'userId': user.uid,
          'userName': userName,
          'patientType': widget.patientType,
          'day': _selectedDay,
          'timeSlot': _getTimeSlot(),
          'appointmentType': _selectedDay == 'Saturday' ? _appointmentType : 'Clinic',
          'reason': _reasonController.text.trim(),
          'notes': _notesController.text.trim(),
          'status': 'Pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Appointment booked successfully!',
                style: TextStyle(fontFamily: 'Regular'),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Failed to book appointment. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Error',
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
        width: 600,
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

              // Title
              Text(
                'Book Appointment',
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
                'Schedule your ${widget.patientType.toLowerCase()} checkup',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Regular',
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),

              // Day Selection
              const Text(
                'Select Day',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Bold',
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ..._weekdays.map((day) => _buildDayChip(day)),
                  _buildDayChip('Saturday'),
                ],
              ),
              const SizedBox(height: 25),

              // Appointment Type (for Saturday)
              if (_selectedDay == 'Saturday') ...[
                const Text(
                  'Appointment Type',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Bold',
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: _saturdayTypes.map((type) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _buildTypeChip(type),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 25),
              ],

              // Time Slot Display
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: primary, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Time: ${_getTimeSlot()}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Bold',
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Reason Field
              TextField(
                controller: _reasonController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Reason for Appointment',
                  labelStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontFamily: 'Regular',
                    fontSize: 14,
                  ),
                  hintText: 'e.g., Regular checkup, Follow-up consultation',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontFamily: 'Regular',
                    fontSize: 14,
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
              const SizedBox(height: 20),

              // Notes Field
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  labelStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontFamily: 'Regular',
                    fontSize: 14,
                  ),
                  hintText: 'Any additional information...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontFamily: 'Regular',
                    fontSize: 14,
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
              const SizedBox(height: 30),

              // Book Button
              ElevatedButton(
                onPressed: _isLoading ? null : _bookAppointment,
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
                        'Book Appointment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Bold',
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayChip(String day) {
    final isSelected = _selectedDay == day;
    return FilterChip(
      label: Text(day),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedDay = day;
          if (day != 'Saturday') {
            _appointmentType = 'Clinic';
          }
        });
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: primary.withOpacity(0.2),
      checkmarkColor: primary,
      labelStyle: TextStyle(
        color: isSelected ? primary : Colors.black87,
        fontFamily: isSelected ? 'Bold' : 'Regular',
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? primary : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    final isSelected = _appointmentType == type;
    return FilterChip(
      label: Text(type),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _appointmentType = type;
        });
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: primary.withOpacity(0.2),
      checkmarkColor: primary,
      labelStyle: TextStyle(
        color: isSelected ? primary : Colors.black87,
        fontFamily: isSelected ? 'Bold' : 'Regular',
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? primary : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
    );
  }
}
