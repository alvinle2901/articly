import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

class SearchService {
  Future<String?> findArticleUrl(
    String title,
    String? author,
    String? publication,
  ) async {
    final query = [
      '$title',
      if (author != null) author,
      // if (publication != null) publication,
    ].join(' ');

    print('🔍 Searching: $query');

    final uri = Uri.parse(
      'https://api.search.brave.com/res/v1/web/search',
    ).replace(queryParameters: {
      'q': query,
    });

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Accept-Encoding': 'gzip',
      'X-Subscription-Token': ApiConstants.braveApiKey,
    });

    print('📡 Status: ${response.statusCode}');
    print('📡 Body: ${response.body}');

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    final results = data['web']?['results'] as List?;
    if (results == null || results.isEmpty) return null;

    for (final result in results) {
      final url = result['url'] as String? ?? '';
      if (url.contains('medium.com') || url.contains('substack.com')) {
        print('✅ Found: $url');
        return url;
      }
    }

    final fallback = results[0]['url'] as String?;
    print('⚠️ Fallback: $fallback');
    return fallback;
  }

  String buildSearchUrl(String title, String? author, String? publication) {
    final query = [
      title,
      if (author != null) author,
      if (publication != null) publication,
      'medium OR substack',
    ].join(' ');
    return 'https://www.google.com/search?q=${Uri.encodeComponent(query)}';
  }
}
