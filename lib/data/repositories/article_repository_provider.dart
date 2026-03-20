import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'article_repository.dart';

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleRepository();
});