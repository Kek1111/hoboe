import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hobo/decorations/ay_box_decoration.dart';
import 'package:hobo/pages/details_page.dart';
import 'package:hobo/models/favs_model.dart';
import 'package:hobo/theme_data.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class TopPage extends StatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  TopPageState createState() => TopPageState();
}

class TopPageState extends State<TopPage> {
  List<String> _body = [];
  List<List<List<List>>> _topContents = [];
  final Map<int, bool> _expTileStates = <int, bool>{};
  final IndicatorController _indiController =
      IndicatorController(refreshEnabled: true);
  bool _isFetchSuccessful = false;
  String _fetchError = '';

  @override
  void initState() {
    super.initState();
    fetchTop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavModel>(builder: (context, favs, child) {
      return RefreshIndicator(
        color: Colors.amberAccent,
        strokeWidth: 4,
        onRefresh: () async {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Container(
              alignment: Alignment.center,
              child: const Text(
                'Обновление...',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
            backgroundColor: Colors.amberAccent,
            elevation: 10,
            duration: const Duration(seconds: 2),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ));
          fetchTop();
        },
        child: !_isFetchSuccessful
            ? Text(_fetchError)
            : ListView.builder(
                itemCount: _body.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: const EdgeInsets.all(1),
                    decoration: ayBoxDecoration(context), //BoxDecoration
                    child: ExpansionTile(
                        key: Key(_body[index]),
                        onExpansionChanged: (value) => setState(() {
                              _expTileStates.update(index, (x) => value,
                                  ifAbsent: () => value);
                            }),
                        title: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _body[index],
                                style: HoboThemeData
                                    .darkThemeData.textTheme.headlineSmall,
                              ),
                            )),
                        childrenPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        backgroundColor: Colors.white10,
                        tilePadding: const EdgeInsets.only(bottom: 4, right: 8),
                        children: _topContents[index].map((x) {
                          return Column(
                            children: x.map(
                              (y) {
                                return Container(
                                    padding: const EdgeInsets.all(8),
                                    alignment: Alignment.topLeft,
                                    child: Visibility(
                                      visible: y[1].text.trim() != "Название",
                                      child: Row(children: [
                                        Expanded(
                                          flex: 9,
                                          child: SelectableText(
                                            y[1].text.trim(),
                                            textAlign: TextAlign.start,
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Details(
                                                            url: getUrl(y),
                                                            name: y[1]
                                                                .text
                                                                .trim(),
                                                          )));
                                            },
                                            style: HoboThemeData.darkThemeData
                                                .textTheme.labelSmall,
                                          ),
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: InkWell(
                                              child: favs
                                                      .hasItem(y[1].text.trim())
                                                  ? const Icon(
                                                      Icons.star,
                                                      color: Colors.yellow,
                                                    )
                                                  : const Icon(Icons
                                                      .star_border_outlined),
                                              onTap: () {
                                                var it = y[1].text.trim();
                                                if (favs.hasItem(it)) {
                                                  favs.remove(it);
                                                } else {
                                                  favs.add(Fav(
                                                      name: it,
                                                      url: getUrl(y)));
                                                }
                                              },
                                            )),
                                      ]),
                                    ));
                              },
                            ).toList(),
                          );
                        }).toList()),
                  );
                }),
      );
    });
  }

  void fetchTop() async {
    // final content = await fetchFile();
    String content = '';
    try {
      content = await fetchURL();
    } catch (e) {
      setState(() {
        _isFetchSuccessful = false;
        _fetchError = e.toString();
      });
    }

    if (content.isNotEmpty) {
      var doc = parse(content);
      var topAll = doc.getElementsByTagName('h2');
      var titles = topAll
          .map((x) =>
              x.text.replaceAll('Самые популярные торренты в категории ', ''))
          .toList();
      var topContents = doc.getElementsByTagName('table');
      topContents.removeAt(0);
      var ll = topContents
          .map((x) => x.children
              .map((e) => e.children.map((q) => q.children).toList())
              .toList())
          .toList();

      setState(() {
        _body = titles;
        _topContents = ll;
        _isFetchSuccessful = true;
        _fetchError = '';
      });
    }
  }

  String getUrl(dynamic q) {
    final res = parse(q[1].innerHtml)
        .nodes[0]
        .nodes[1]
        .nodes[3]
        .attributes
        .values
        .first;
    return 'http://rutor.info$res';
  }

  static Future<String> fetchFile() async {
    return await rootBundle.loadString('assets/content');
  }

  static Future<String> fetchURL() async {
    final response = await http.get(Uri.parse('http://rutor.info/top/'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return response.statusCode.toString();
    }
  }
}
