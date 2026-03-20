import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/article_repository_provider.dart';
import '../../home/providers/articles_provider.dart';

final addArticleProvider =
    AsyncNotifierProvider<AddArticleNotifier, Article?>(
  AddArticleNotifier.new,
);

class AddArticleNotifier extends AsyncNotifier<Article?> {
  @override
  Article? build() => null;

  Future<void> saveFromUrl(String rawUrl, {List<String> tags = const []}) async {
    state = const AsyncLoading();

    // 1. Validate
    final uri = Uri.tryParse(rawUrl);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      state = AsyncError('Please enter a valid URL', StackTrace.current);
      return;
    }

    // 2. Fetch metadata — graceful fallback
    String title = rawUrl;
    String? thumbnail, author, description;
    try {
      final meta = await AnyLinkPreview.getMetadata(link: rawUrl);
      title       = meta?.title ?? rawUrl;
      thumbnail   = meta?.image;
      // author      = meta?.author;
      description = meta?.desc;
    } catch (_) {
      // no metadata available — save with URL as title
    }

    // 3. Build and save article
    final article = Article(
      id: const Uuid().v4(),
      url: rawUrl,
      title: title,
      thumbnailUrl: thumbnail,
      author: author,
      description: description,
      savedAt: DateTime.now(),
      tags: tags,
    );

    await ref.read(articleRepositoryProvider).save(article);

    // 4. Refresh home list
    ref.invalidate(articlesProvider);

    state = AsyncData(article);
  }
}