import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hobo/models/favs_model.dart';
import 'package:hobo/theme_data.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:provider/provider.dart';

class Details extends StatefulWidget {
  final String url;
  final String name;
  const Details({super.key, required this.url, required this.name});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  String? _imageUrl = 'http://andersen.renoworks.com/images/_loading.gif';
  String _description = 'Загрузка ...';

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  void getDetails() async {
    final details = await fetchURL(widget.url);
    var doc = parse(details);
    var imageUrl =
        'https://media.istockphoto.com/vectors/no-image-available-icon-vector-id1216251206?k=6&m=1216251206&s=612x612&w=0&h=G8kmMKxZlh7WyeYtlIHJDxP5XRGm9ZXyLprtVJKxd-o=';
    try {
      imageUrl = doc
          .getElementById('details')!
          .getElementsByTagName('img')
          .where((element) => !element.attributes.keys.contains('alt'))
          .where((element) => !element.outerHtml.contains('gif'))
          .first
          .attributes['src']
          .toString();
    } finally {}

    var allText =
        doc.getElementById('details')!.children.map((x) => x.text).toList();
    String resText = '';
    const int numOfChapters = 3;

    var allTextLines = allText[0].split('\n');

    List<List<String>> chapters = [];
    List<String> currentChapter = [];

    bool isPrevLineEmpty = false;

    for (String tex in allTextLines) {
      if (tex.trim().isEmpty) {
        if (isPrevLineEmpty) {
          if (currentChapter.isNotEmpty) {
            chapters.add(currentChapter);
            currentChapter = [];
          }
        }
      } else {
        currentChapter.add(tex.trim().replaceAll('<br />', ' '));
      }
      isPrevLineEmpty = tex.trim().isEmpty ? true : false;
    }

    for (int i = 0; i < numOfChapters; i++) {
      resText += chapters[i].join('\n\n');
    }

    var description = resText;

    setState(() {
      _imageUrl = imageUrl;
      _description = description;
    });
  }

  Future<String> fetchFile() async {
    return await rootBundle.loadString('assets/details');
  }

  Future<String> fetchURL(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return response.statusCode.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Информация о раздаче'),
        actions: [
          Consumer<FavModel>(builder: (context, favs, child) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                child: Icon(favs.hasItem(widget.name)
                    ? Icons.star
                    : Icons.star_border_outlined),
                onTap: () {
                  if (favs.hasItem(widget.name)) {
                    favs.remove(widget.name);
                  } else {
                    favs.add(Fav(name: widget.name, url: widget.url));
                  }
                },
              ),
            );
          })
        ],
      ),
      body: ListView(children: [
        Image.network(
          _imageUrl!,
          errorBuilder: (c, e, st) {
            return Image.asset('assets/images/no-image.png',
                width: 300, height: 200, fit: BoxFit.contain);
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _description,
            softWrap: true,
            style: HoboThemeData.darkThemeData.textTheme.bodyLarge,
          ),
        )
      ]),
    );
  }
}
