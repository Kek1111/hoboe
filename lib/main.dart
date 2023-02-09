import 'package:hobo/models/favs_model.dart';
import 'package:hobo/pages/top_page.dart';
import 'package:hobo/pages/favourites_page.dart';
import 'package:hobo/theme_data.dart';
import 'package:html/parser.dart' show parse;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => FavModel())],
      child: const HoboApp(),
    ),
  );
}

class HoboApp extends StatelessWidget {
  const HoboApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hobo hobo',
      theme: HoboThemeData.lightThemeData.copyWith(
        platform: TargetPlatform.android,
      ),
      darkTheme: HoboThemeData.darkThemeData.copyWith(
        platform: TargetPlatform.android,
      ),
      home: const MyHomePage(title: 'Что новенького?'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _bottomBarSelectedIndex = 0;
  final TopPage _topPage = const TopPage();
  final Favourites _favPage = Favourites();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavModel>(
      builder: (context, favs, child) {
        return Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
              backgroundColor: Colors.black,
              shadowColor: Colors.purple,
              elevation: 5,
            ),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.black54,
              elevation: 15,
              selectedItemColor: Colors.amberAccent,
              currentIndex: _bottomBarSelectedIndex,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: 'Топ',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.star),
                  label: 'Выбранное',
                )
              ],
              onTap: (index) {
                setState(() {
                  _bottomBarSelectedIndex = index;
                });
              },
            ),
            // body: _bottomBarSelectedIndex == 0 ? _topPage : _favPage,
            body: IndexedStack(
              index: _bottomBarSelectedIndex,
              children: [_topPage, _favPage],
            ));
      },
    );
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
}
