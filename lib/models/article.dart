class Article {
  final String title;
  final String link;
  final String description;
  final DateTime? pubDate;
  final String category;
  const Article({required this.title, required this.link, required this.description, this.pubDate, this.category = 'GUIDE'});

  Article copyWith({String? link}) =>
      Article(title: title, link: link ?? this.link, description: description, pubDate: pubDate, category: category);

  factory Article.fromJson(Map<String, dynamic> json) => Article(
    title: json['title'] as String? ?? '',
    link: json['link'] as String? ?? '',
    description: json['description'] as String? ?? '',
    category: json['category'] as String? ?? 'GUIDE',
    pubDate: json['pubDate'] == null ? null : DateTime.tryParse(json['pubDate'] as String),
  );

  Map<String, dynamic> toJson() => {'title': title, 'link': link, 'description': description, 'category': category, 'pubDate': pubDate?.toIso8601String()};
}
