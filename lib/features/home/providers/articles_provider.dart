import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/article_repository_provider.dart';

// All articles
final articlesProvider = NotifierProvider<ArticlesNotifier, List<Article>>(
  ArticlesNotifier.new,
);

class ArticlesNotifier extends Notifier<List<Article>> {
  @override
  List<Article> build() {
    return ref.read(articleRepositoryProvider).getAll();
  }

  Future<void> save(Article article) async {
    await ref.read(articleRepositoryProvider).save(article);
    state = ref.read(articleRepositoryProvider).getAll();
  }

  Future<void> markAsRead(String id) async {
    await ref.read(articleRepositoryProvider).markAsRead(id);
    state = ref.read(articleRepositoryProvider).getAll();
  }

  Future<void> delete(String id) async {
    await ref.read(articleRepositoryProvider).delete(id);
    state = ref.read(articleRepositoryProvider).getAll();
  }
}

// Filtered: unread only
final unreadArticlesProvider = Provider<List<Article>>((ref) {
  return ref.watch(articlesProvider).where((a) => !a.isRead).toList();
});

// Filtered: by tag
final articlesByTagProvider = Provider.family<List<Article>, String>((ref, tag) {
  return ref.watch(articlesProvider).where((a) => a.tags.contains(tag)).toList();
});

// All tags across all articles
final allTagsProvider = Provider<List<String>>((ref) {
  return ref.watch(articlesProvider)
      .expand((a) => a.tags)
      .toSet()
      .toList();
});