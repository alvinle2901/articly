import 'dart:io';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/article_repository_provider.dart';
import '../../../data/datasources/local/image_extractor_service.dart';
import '../../../data/datasources/local/search_service.dart';
import '../../home/providers/articles_provider.dart';

final addArticleProvider =
    AsyncNotifierProvider<AddArticleNotifier, Article?>(
  AddArticleNotifier.new,
);

class AddArticleNotifier extends AsyncNotifier<Article?> {
  final _imageExtractor = ImageExtractorService();
  final _searchService = SearchService();

  @override
  Article? build() => null;

  Future<void> saveFromUrl(String rawUrl, {List<String> tags = const []}) async {
    state = const AsyncLoading();

    final uri = Uri.tryParse(rawUrl);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      state = AsyncError('Please enter a valid URL', StackTrace.current);
      return;
    }

    String title = rawUrl;
    String? thumbnail, author, description;
    try {
      final meta = await AnyLinkPreview.getMetadata(link: rawUrl);
      title       = meta?.title ?? rawUrl;
      thumbnail   = meta?.image;
      // author      = meta?.author;
      description = meta?.desc;
    } catch (_) {}

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
    ref.invalidate(articlesProvider);
    state = AsyncData(article);
  }

  Future<void> saveFromImage(File imageFile, {List<String> tags = const []}) async {
  state = const AsyncLoading();

  final extraction = await _imageExtractor.extractFromImage(imageFile);
  if (extraction == null) {
    state = AsyncError('Could not read text from image', StackTrace.current);
    return;
  }

  // Try to find real URL
  String? url = await _searchService.findArticleUrl(
    extraction.title,
    extraction.author,
    extraction.publication,
  );

  // If not found, fall back to Google search URL for user to resolve manually
  final isResolved = url != null;
  url ??= _searchService.buildSearchUrl(
    extraction.title,
    extraction.author,
    extraction.publication,
  );

  String? thumbnail, description;
  try {
    if (isResolved) {
      final meta = await AnyLinkPreview.getMetadata(link: url);
      thumbnail   = meta?.image;
      description = meta?.desc;
    }
  } catch (_) {}

  final article = Article(
    id: const Uuid().v4(),
    url: url,
    title: extraction.title,
    author: extraction.author,
    thumbnailUrl: thumbnail,
    description: description,
    savedAt: DateTime.now(),
    tags: tags,
    isRead: false,
  );

  await ref.read(articleRepositoryProvider).save(article);
  ref.invalidate(articlesProvider);
  state = AsyncData(article);
}
}