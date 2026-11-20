import 'dart:convert';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Memindahkan seluruh proses jsonDecode() dari respons HTTP Dio atau payload JSON
/// aset lokal berukuran >= 10 KB ke Background Isolate secara otomatis agar
/// Main UI Thread tidak pernah freeze saat membuka halaman/daftar data besar.
class IsolateJsonTransformer extends BackgroundTransformer {
  static const int isolateThresholdBytes = 10240;

  IsolateJsonTransformer() : super() {
    jsonDecodeCallback = parseJsonInBackground;
  }

  static Future<dynamic> parseJsonInBackground(String rawJson) async {
    if (rawJson.length < isolateThresholdBytes || kIsWeb) {
      return jsonDecode(rawJson);
    }
    return Isolate.run(() => jsonDecode(rawJson));
  }
}
