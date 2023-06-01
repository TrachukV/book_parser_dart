import 'dart:io';

import 'package:book_parser/models/textbook_model.dart';
import 'package:dio/dio.dart';

Future<void> downloadTextbooks(List<TextbookModel> textbooks, String baseUrl) async {
  final Directory directory = Directory('textbooks');
  if (!directory.existsSync()) {
    directory.createSync();
  }

  for (TextbookModel textbook in textbooks) {
    final List<String> fileUrls = textbook.fileUrls;
    for (String fileUrl in fileUrls) {
      final String id = textbook.id;
      final String extension = fileUrl.split('/').last.split('.').last;
      final String fileName = '$id.$extension';

      if (extension.toLowerCase() == 'pdf') {
        final Response response = await Dio().get(fileUrl);

        if (response.statusCode == 200) {
          final List<int> fileBytes = response.data;
          await File('${directory.path}/$fileName').writeAsBytes(fileBytes);
          print('PDF скачан: $fileName');
        } else {
          print('Ошибка при скачивании PDF: $fileUrl');
        }
      }
    }
  }
}