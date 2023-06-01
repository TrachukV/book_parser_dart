class TextbookModel {
  final String id;
  final String title;
  String imageUrl;
  final String author;
  final String description;
  final List<String> fileUrls;

  TextbookModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.author,
    required this.description,
    required this.fileUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'author': author,
      'description': description,
      'fileUrls': fileUrls,
    };
  }
}