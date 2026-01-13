class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isImportant;
  final String? author;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isImportant = false,
    this.author,
  });
}
