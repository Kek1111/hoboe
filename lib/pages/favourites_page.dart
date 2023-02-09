import 'package:flutter/material.dart';
import 'package:hobo/decorations/ay_box_decoration.dart';
import 'package:hobo/pages/details_page.dart';
import 'package:hobo/models/favs_model.dart';
import 'package:hobo/theme_data.dart';
import 'package:provider/provider.dart';

class Favourites extends StatefulWidget {
  Favourites({Key? key}) : super(key: key);
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  @override
  FavouritesState createState() => FavouritesState();
}

class FavouritesState extends State<Favourites> {
  final GlobalKey<AnimatedListState> _key = GlobalKey();

  // // Add a new item to the list
  // // This is trigger when the floating button is pressed
  // void _addItem() {
  //   _items.insert(0, "Item ${_items.length + 1}");
  //   _key.currentState!.insertItem(0, duration: const Duration(seconds: 1));
  // }

  // Remove an item
  // This is trigger when an item is tapped
  void _removeItem(int index, BuildContext context, String text) {
    AnimatedList.of(context).removeItem(index, (_, animation) {
      return FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: ayBoxDecoration(context),
            child: Row(children: [
              Expanded(
                flex: 9,
                child: InkWell(
                  child: Text(text,
                      style:
                          HoboThemeData.darkThemeData.textTheme.headlineSmall),
                ),
              ),
              const Expanded(flex: 1, child: InkWell(child: Icon(Icons.star)))
            ]),
          ),
        ),
      );
    }, duration: const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavModel>(builder: (context, favs, child) {
      return AnimatedList(
        key: GlobalKey(),
        initialItemCount: favs.items.length,
        itemBuilder: (context, index, animation) {
          return Visibility(
            visible: index < favs.items.length,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: ayBoxDecoration(context),
              child: Row(children: [
                Expanded(
                  flex: 9,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Details(
                                    url: favs.items.elementAt(index).url,
                                    name: favs.items.elementAt(index).name,
                                  )));
                    },
                    child: Text(
                      favs.items.elementAt(index).name,
                      style:
                          HoboThemeData.darkThemeData.textTheme.headlineSmall,
                    ),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: InkWell(
                      child: const Icon(Icons.star),
                      onTap: () {
                        _removeItem(
                            index, context, favs.items.elementAt(index).name);
                        favs.remove(favs.items.elementAt(index).name);
                      },
                    ))
              ]),
            ),
          );
        },
      );
    });
  }
}
