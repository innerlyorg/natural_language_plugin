import 'package:flutter/services.dart';

class NaturalLanguagePlugin {
  static const MethodChannel _channel = MethodChannel(
    'natural_language_plugin',
  );

  static Future<bool> isEnglish(String text) async {
    final result = await _channel.invokeMethod<bool>('isEnglish', {
      'text': text,
    });
    return result ?? false;
  }

  static Future<double?> analyzeSentiment(String text) async {
    final result = await _channel.invokeMethod<double?>('analyzeSentiment', {
      'text': text,
    });
    return result;
  }

  static Future<List<Map<String, String>>> extractEntities(String text) async {
    final result = await _channel.invokeMethod<List<dynamic>>(
      'extractEntities',
      {'text': text},
    );

    // Perform explicit type conversion
    if (result == null) return [];

    return result.map<Map<String, String>>((dynamic item) {
      // Convert each dynamic map to a Map<String, String>
      final Map<dynamic, dynamic> dynamicMap = item as Map<dynamic, dynamic>;
      return dynamicMap.map<String, String>((dynamic key, dynamic value) {
        return MapEntry<String, String>(key.toString(), value.toString());
      });
    }).toList();
  }
}
