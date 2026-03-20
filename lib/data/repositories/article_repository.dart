import 'package:hive_flutter/hive_flutter.dart';
import '../models/article.dart';

class ArticleRepository {
  final Box<Article> _box = Hive.box<Article>('articles');

  List<Article> getAll() {
    return _box.values.toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
  }

  Article? getById(String id) {
    return _box.values.firstWhere((a) => a.id == id);
  }

  Future<void> save(Article article) async {
    await _box.put(article.id, article);
  }

  Future<void> markAsRead(String id) async {
    final article = getById(id);
    if (article != null) {
      article.isRead = true;
      await article.save();
    }
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  List<Article> getByTag(String tag) {
    return _box.values.where((a) => a.tags.contains(tag)).toList();
  }

  List<String> getAllTags() {
    return _box.values
        .expand((a) => a.tags)
        .toSet()
        .toList();
  }
}