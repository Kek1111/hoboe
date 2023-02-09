import 'dart:collection';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FavModel extends ChangeNotifier {
  Database? _db;

  FavModel() {
    WidgetsFlutterBinding.ensureInitialized();
    loadFavs();
  }

  List<Fav> _items = <Fav>[];
  // UnmodifiableListView<String> get items => UnmodifiableListView(_items);
  UnmodifiableListView<Fav> get items => UnmodifiableListView(_items);

  // void add(String item) {
  //   _items.add(item);
  //   notifyListeners();
  //   saveFavs();
  // }

  Future<void> add(Fav fav) async {
    await _db!.insert(
      'favs',
      fav.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _items.add(fav);
    notifyListeners();
  }

  Future<void> remove(String name) async {
    int index = _items.indexWhere((element) => element.name == name);
    if (index >= 0) {
      _items.removeAt(index);
      await _db!.delete(
        'favs',
        where: 'name = ?',
        whereArgs: [name],
      );
      notifyListeners();
    }
  }

  bool hasItem(String name) {
    return _items.where((element) => element.name == name).isNotEmpty;
  }

  // Future<bool> saveFavs() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.setStringList('favs', _items);
  // }

  void loadFavs() async {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    _db = await openDatabase(
      join(await getDatabasesPath(), 'favs.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE favs(name TEXT PRIMARY KEY, url TEXT)',
        );
      },
      version: 1,
    );

    // List<String>? tmp = prefs.getStringList('favs');
    // return tmp ?? <String>[];

    final List<Map<String, dynamic>> maps = await _db!.query('favs');

    _items = List.generate(maps.length, (i) {
      return Fav(
        name: maps[i]['name'],
        url: maps[i]['url'],
      );
    });

    notifyListeners();
  }
}

class Fav {
  String name;
  String url;

  Fav({
    required this.name,
    required this.url,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
    };
  }
}
