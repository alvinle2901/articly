import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/article.dart';
import '../../home/providers/articles_provider.dart';

class ArticleDetailScreen extends ConsumerWidget {
  final Article article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Mark as read toggle
          IconButton(
            icon: Icon(
              article.isRead
                  ? Icons.bookmark
                  : Icons.bookmark_border_rounded,
              color: article.isRead
                  ? const Color(0xFF1D9E75)
                  : const Color(0xFF1A1A1A),
            ),
            onPressed: () {
              ref
                  .read(articlesProvider.notifier)
                  .markAsRead(article.id);
              Navigator.pop(context);
            },
          ),
          // Delete
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFE24B4A)),
            onPressed: () {
              ref
                  .read(articlesProvider.notifier)
                  .delete(article.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            if (article.thumbnailUrl != null)
              SizedBox(
                width: double.infinity,
                height: 220,
                child: Image.network(
                  article.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  if (article.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      children: article.tags
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1EFE8),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFE8E6E0),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF5F5E5A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Title
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Author + date row
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Color(0xFFB4B2A9),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          [
                            if (article.author != null) article.author!,
                            _formatDate(article.savedAt),
                          ].join(' · '),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFB4B2A9),
                          ),
                        ),
                      ),
                      // Read status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: article.isRead
                              ? const Color(0xFFE1F5EE)
                              : const Color(0xFFF1EFE8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          article.isRead ? 'Read' : 'Unread',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: article.isRead
                                ? const Color(0xFF0F6E56)
                                : const Color(0xFF888780),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFE8E6E0), thickness: 0.5),
                  const SizedBox(height: 20),

                  // Description
                  if (article.description != null) ...[
                    Text(
                      article.description!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF5F5E5A),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // URL preview
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFE8E6E0),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.link_rounded,
                          size: 14,
                          color: Color(0xFFB4B2A9),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            article.url,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFB4B2A9),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Open article button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openArticle(context, ref),
                      icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                      label: const Text(
                        'Read article',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A1A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Mark as read button
                  if (!article.isRead)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref
                              .read(articlesProvider.notifier)
                              .markAsRead(article.id);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text(
                          'Mark as read',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1A1A1A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(
                            color: Color(0xFFE8E6E0),
                            width: 0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openArticle(BuildContext context, WidgetRef ref) async {
    try {
      await launchUrl(
        Uri.parse(article.url),
        customTabsOptions: CustomTabsOptions(
          colorSchemes: CustomTabsColorSchemes.defaults(
            toolbarColor: const Color(0xFF1A1A1A),
          ),
          showTitle: true,
          urlBarHidingEnabled: true,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open article')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}