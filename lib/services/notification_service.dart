import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'third_party_config.dart';

class NotificationService {
  final http.Client _client;

  NotificationService({http.Client? client})
      : _client = client ?? http.Client();

  Future<bool> sendEmail({
    required String toEmail,
    required String subject,
    required String message,
    String? toName,
  }) async {
    try {
      final payload = {
        'service_id': ThirdPartyConfig.emailJsServiceId,
        'template_id': ThirdPartyConfig.emailJsTemplateId,
        'user_id': ThirdPartyConfig.emailJsPublicKey,
        'template_params': {
          'to_email': toEmail,
          'to_name': toName ?? '',
          'subject': subject,
          'message': message,
        },
      };

      final res = await _client.post(
        Uri.parse(ThirdPartyConfig.emailJsEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> sendSms({
    required String number,
    required String message,
  }) async {
    try {
      // Semaphore expects Philippine numbers in 09XXXXXXXXX format
      // The +63 international format is rejected by the API
      String formattedNumber = number.trim();
      
      // Remove any +63 or 63 prefix if present, keep the 0 prefix
      if (formattedNumber.startsWith('+63')) {
        formattedNumber = '0${formattedNumber.substring(3)}';
      } else if (formattedNumber.startsWith('63') && formattedNumber.length == 12) {
        formattedNumber = '0${formattedNumber.substring(2)}';
      }

      debugPrint('[SMS] Sending to: $formattedNumber');
      debugPrint('[SMS] Message: $message');
      debugPrint('[SMS] Sender: ${ThirdPartyConfig.semaphoreSenderName}');

      final res = await _client.post(
        Uri.parse(ThirdPartyConfig.semaphoreMessagesEndpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'apikey': ThirdPartyConfig.semaphoreApiKey,
          'number': formattedNumber,
          'message': message,
          'sendername': ThirdPartyConfig.semaphoreSenderName,
        },
      );

      debugPrint('[SMS] Status Code: ${res.statusCode}');
      debugPrint('[SMS] Response Body: ${res.body}');

      // Semaphore returns 200 on success, but let's check the response body too
      if (res.statusCode == 200) {
        try {
          final responseData = jsonDecode(res.body);
          if (responseData is List && responseData.isNotEmpty) {
            final firstMessage = responseData[0];
            debugPrint('[SMS] Message ID: ${firstMessage['message_id']}');
            debugPrint('[SMS] Status: ${firstMessage['status']}');
            return firstMessage['status'] == 'Pending' || firstMessage['status'] == 'Success';
          }
        } catch (_) {
          // If we can't parse JSON, just check status code
        }
        return true;
      }

      return false;
    } catch (e, stackTrace) {
      debugPrint('[SMS] Error: $e');
      debugPrint('[SMS] StackTrace: $stackTrace');
      return false;
    }
  }

  Future<void> sendToUser({
    required String subject,
    required String message,
    String? email,
    String? phone,
    String? name,
  }) async {
    // Send email if email is provided
    if ((email ?? '').isNotEmpty) {
      await sendEmail(
        toEmail: email!,
        subject: subject,
        message: message,
        toName: name,
      );
    }

    // Send SMS if phone is provided (independent of email)
    if ((phone ?? '').isNotEmpty) {
      await sendSms(number: phone!, message: message);
    }
  }

  Future<void> sendToClinic({
    required String subject,
    required String message,
  }) async {
    await sendToUser(
      subject: subject,
      message: message,
      email: ThirdPartyConfig.clinicNotificationEmail,
      phone: ThirdPartyConfig.clinicNotificationPhone,
      name: 'Clinic',
    );
  }
}
