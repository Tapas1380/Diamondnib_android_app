import 'dart:convert';

import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class MetaTrackingService {
  MetaTrackingService._();

  static final MetaTrackingService instance = MetaTrackingService._();

  final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();

  String _generateEventId() {
    return const Uuid().v4();
  }

  Future<void> logCompleteRegistration({
    required String userId,
    String? email,
    String? phone,
  }) async {
    final eventId = _generateEventId();

    try {
      await _facebookAppEvents.logEvent(
        name: 'CompleteRegistration',
        parameters: {
          'event_id': eventId,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
        },
      );
    } catch (e) {
      printLog('MetaTrackingService CompleteRegistration app_event error => $e');
    }

    await _sendToServer(
      eventName: 'CompleteRegistration',
      eventId: eventId,
      userId: userId,
      email: email,
      phone: phone,
    );
  }

  Future<void> logPurchase({
    required String userId,
    String? email,
    String? phone,
    required String value,
    required String currency,
  }) async {
    final eventId = _generateEventId();

    try {
      await _facebookAppEvents.logPurchase(
        amount: double.tryParse(value) ?? 0,
        currency: currency,
        parameters: {
          'event_id': eventId,
        },
      );
    } catch (e) {
      printLog('MetaTrackingService Purchase app_event error => $e');
    }

    await _sendToServer(
      eventName: 'Purchase',
      eventId: eventId,
      userId: userId,
      email: email,
      phone: phone,
      value: value,
      currency: currency,
    );
  }

  Future<void> _sendToServer({
    required String eventName,
    required String eventId,
    required String userId,
    String? email,
    String? phone,
    String? value,
    String? currency,
  }) async {
    try {
      final url = Uri.parse('${Constant.baseurl}meta_capi/track');

      final payload = {
        'event_name': eventName,
        'event_id': eventId,
        'user_id': userId,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (value != null) 'value': value,
        if (currency != null) 'currency': currency,
      };

      final resp = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode != 200) {
        printLog(
            'MetaTrackingService server track failed => ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      printLog('MetaTrackingService server track error => $e');
    }
  }
}
