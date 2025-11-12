// lib/services/native_nback.dart
import 'package:flutter/services.dart';

class NativeNBack {
  static const MethodChannel _channel = MethodChannel(
    'com.example.nback/native',
  );

  /// generate sequence of ints (1..combinations)
  static Future<List<int>> generateNBack({
    required int size,
    required int combinations,
    required int matchPercentage,
    required int nback,
  }) async {
    final args = {
      'size': size,
      'combinations': combinations,
      'matchPercentage': matchPercentage,
      'nback': nback,
    };
    final List<dynamic>? result = await _channel.invokeMethod(
      'generateNBack',
      args,
    );
    if (result == null) return [];
    return result.map((e) => (e as num).toInt()).toList();
  }
}
