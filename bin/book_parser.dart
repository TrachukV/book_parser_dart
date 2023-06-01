import 'dart:convert';
import 'dart:io';
import 'package:book_parser/download_images_parse_page.dart';
import 'package:book_parser/models/download_text_books.dart';
import 'package:book_parser/models/textbook_model.dart';


void main() async {
  final String baseUrl = 'https://lib.imzo.gov.ua';
  final String url = '$baseUrl/yelektronn-vers-pdruchnikv/1-klas/1-ukranska-mova-bukvar-1-klas/';

  try {
    final List<TextbookModel> textbooks = await downloadImagesAndParsePage(url, baseUrl);

    await downloadTextbooks(textbooks, baseUrl);

    final List<Map<String, dynamic>> jsonData = textbooks.map((textbook) => textbook.toJson()).toList();
    final String jsonString = jsonEncode(jsonData);
    final File jsonFile = File('textbooks.json');
    jsonFile.writeAsStringSync(jsonString);
    print('JSON-файл успешно создан: ${jsonFile.path}');
  } catch (e) {
    print('Произошла ошибка: $e');
  }
}
