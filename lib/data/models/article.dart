import 'package:hive/hive.dart';

part 'article.g.dart';

@HiveType(typeId: 0)
class Article extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String url;

  @HiveField(2)
  late String title;

  @HiveField(3)
  String? description;

  @HiveField(4)
  String? thumbnailUrl;

  @HiveField(5)
  String? author;

  @HiveField(6)
  late DateTime savedAt;

  @HiveField(7)
  bool isRead;

  @HiveField(8)
  List<String> tags;

  Article({
    required this.id,
    required this.url,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.author,
    required this.savedAt,
    this.isRead = false,
    this.tags = const [],
  });
}