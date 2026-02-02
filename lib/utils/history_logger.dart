import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryLogger {
  static Future<void> log({
    required String role,
    required String userName,
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final payload = <String, dynamic>{
        'role': role,
        'userName': userName,
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (metadata != null && metadata.isNotEmpty) {
        payload['metadata'] = metadata;
      }

      await FirebaseFirestore.instance.collection('historyLogs').add(payload);
    } catch (_) {
    }
  }
}
