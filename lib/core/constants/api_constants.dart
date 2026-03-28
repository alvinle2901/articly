import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Google Vision
  static const googleVisionUrl =
      'https://vision.googleapis.com/v1/images:annotate';

  static String get googleApiKey => _requiredEnv('GOOGLE_API_KEY');
  static String get braveApiKey => _requiredEnv('BRAVE_API_KEY');

  static String _requiredEnv(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError('Missing required environment variable: $key');
    }
    return value;
  }
}
