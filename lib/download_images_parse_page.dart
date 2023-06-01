import 'dart:io';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:uuid/uuid.dart';
import 'package:html/parser.dart' as parser;

import 'models/textbook_model.dart';

Future<List<TextbookModel>> downloadImagesAndParsePage(String url, String baseUrl) async {
  final List<TextbookModel> textbooks = [];

  final Directory directory = Directory('images');
  if (!directory.existsSync()) {
    directory.createSync();
  }

  try {
    final Response response = await Dio().get(url);

    if (response.statusCode == 200) {
      final Document document = parser.parse(response.data);

      final List<Element> articles = document.querySelectorAll('div.product');

      for (Element article in articles) {
        final Element? titleElement = article.querySelector('.product_name a');
        final String? linkElement = titleElement?.attributes['href'];
        final String? title = titleElement?.text.trim();

        final Element? descriptionElement = article.querySelector('.description');
        final String? description = descriptionElement?.text.trim();

        final Element? imageElement = article.querySelector('.img_middle_in img');
        print(imageElement?.attributes);
        final String? imageUrl = imageElement?.attributes['src'];
        String author = '';

        final String id = Uuid().v4();

        final TextbookModel textbook = TextbookModel(
          id: id,
          title: title ?? '',
          imageUrl: '',
          author: author,
          description: description ?? '',
          fileUrls: [],
        );

        final String linkUrl = '$baseUrl$imageUrl';
        final Response linkResponse = await Dio().get(linkUrl);

        if (linkResponse.statusCode == 200) {
          final Document linkDocument = parser.parse(linkResponse.data);

          final Element? authorElement = linkDocument.querySelector('meta[name="Description"]');
          final String? authorContent = authorElement?.attributes['content'];
          if (authorContent != null) {
            final RegExp regex = RegExp(r'Воскресенська Н\. О\., Цепова І\. В\.');
            final Match? match = regex.firstMatch(authorContent);
            if (match != null) {
              author = match.group(0)!;
            }
          }

          final List<Element> fileElements = linkDocument.querySelectorAll('div#pp_home a');
          for (Element fileElement in fileElements) {
            final String? fileUrl = fileElement.attributes['href'];
            textbook.fileUrls.add(fileUrl!);
          }
        }

        textbooks.add(textbook);

        if (imageUrl != null && imageUrl.isNotEmpty) {
          final String extension = imageUrl.split('.').last;
          final String fileName = '$id.$extension';
          final Response response = await Dio().download('$baseUrl$imageUrl', '${directory.path}/$fileName');

          if (response.statusCode == 200) {
            textbook.imageUrl = '${directory.path}/$fileName';
          } else {
            print('Ошибка при скачивании картинки для учебника: $imageUrl');
          }
        }
      }
    } else {
      throw Exception('Ошибка при получении страницы: ${response.statusCode}');
    }
  } catch (e) {
    print('Произошла ошибка: $e');
  }

  return textbooks;
}