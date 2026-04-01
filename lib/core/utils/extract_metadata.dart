import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

Future<Map<String, dynamic>> extractMetadata(String url) async {
  final response = await http.get(Uri.parse(url));
  final document = parser.parse(response.body);

  final metadata = <String, dynamic>{};

  // Extract meta tags
  for (var element in document.getElementsByTagName('meta')) {
    final property = element.attributes['property'] ?? element.attributes['name'];
    final content = element.attributes['content'];
    if (property != null && content != null) {
      metadata[property] = content;
    }
  }

  // Extract JSON-LD
  final jsonLdElement = document.querySelector('script[type="application/ld+json"]');
  if (jsonLdElement != null) {
    metadata['jsonLd'] = jsonLdElement.text;
  }

  return metadata;
}
