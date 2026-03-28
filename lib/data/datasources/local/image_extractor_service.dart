import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

class ImageExtractorService {
  Future<ArticleExtraction?> extractFromImage(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    print('🖼️ Sending image to Google Vision...');

    final response = await http.post(
      Uri.parse(
        '${ApiConstants.googleVisionUrl}?key=${ApiConstants.googleApiKey}',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'requests': [
          {
            'image': {'content': base64Image},
            'features': [
              {'type': 'TEXT_DETECTION', 'maxResults': 1},
            ],
          }
        ],
      }),
    );

    print('📡 Status: ${response.statusCode}');
    print('📡 Body: ${response.body}');

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    final annotations = data['responses']?[0]?['textAnnotations'] as List?;
    if (annotations == null || annotations.isEmpty) return null;

    // First annotation is the full text block
    final fullText = annotations[0]['description'] as String? ?? '';
    print('📄 Full extracted text:\n$fullText');

    return _parseExtraction(fullText);
  }

  ArticleExtraction? _parseExtraction(String text) {
  final lines = text
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();

  if (lines.isEmpty) return null;

  print('📝 Lines: $lines');

  // Find publication — short ALL CAPS line near the top
  String? publication;
  int publicationIndex = -1;
  for (int i = 0; i < lines.length && i < 5; i++) {
    final line = lines[i];
    if (line.length < 40 &&
        line == line.toUpperCase() &&
        RegExp(r'^[A-Z\s]+$').hasMatch(line)) {
      publication = _toTitleCase(line);
      publicationIndex = i;
      break;
    }
  }

  // Title = first long line AFTER the publication name
  String? title;
  int titleIndex = publicationIndex + 1;
  for (int i = titleIndex; i < lines.length; i++) {
    if (lines[i].length > 15 && !_looksLikeMetadata(lines[i])) {
      title = lines[i];
      titleIndex = i;
      break;
    }
  }

  if (title == null) return null;

  // Merge next lines if they continue the title
  for (int i = titleIndex + 1; i < lines.length; i++) {
    final next = lines[i];
    if (next.length > 10 &&
        !_looksLikeMetadata(next) &&
        next != next.toUpperCase()) {
      title = '$title $next';
    } else {
      break;
    }
  }

  // Author — ALL CAPS short line after title
  String? author;
  for (int i = titleIndex + 1; i < lines.length; i++) {
    final line = lines[i];
    if (line.toLowerCase().startsWith('by ') && line.length < 50) {
      author = line.replaceFirst(RegExp(r'^by ', caseSensitive: false), '').trim();
      break;
    }
    if (line.length < 40 &&
        line == line.toUpperCase() &&
        RegExp(r'^[A-Z\s]+$').hasMatch(line) &&
        !_looksLikeMetadata(line)) {
      author = _toTitleCase(line);
      break;
    }
  }

  print('✅ Publication: $publication');
  print('✅ Title: $title');
  print('✅ Author: $author');

  return ArticleExtraction(
    title: title!,
    author: author,
    publication: publication,
  );
}

  bool _looksLikeMetadata(String line) {
    // Dates, times, read times, like counts
    return RegExp(
      r'\d{1,2}\s+(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)',
      caseSensitive: false,
    ).hasMatch(line) ||
    RegExp(r'\d+:\d+').hasMatch(line) ||
    RegExp(r'\d+\s+min read', caseSensitive: false).hasMatch(line) ||
    RegExp(r'^\d+[\.,]?\d*$').hasMatch(line);
  }

  String _toTitleCase(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

class ArticleExtraction {
  final String title;
  final String? author;
  final String? publication;

  ArticleExtraction({
    required this.title,
    this.author,
    this.publication,
  });
}