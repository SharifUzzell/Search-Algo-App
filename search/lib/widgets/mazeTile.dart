import 'package:flutter/material.dart';
import 'package:search/models/grid.dart';

class MazeTile extends StatelessWidget {
  int index;
  Grid g;
  Color color;
  ValueNotifier<Color> notifier;

  MazeTile(this.index, this.g);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: g.ColorMap[index ~/ g.size][index % g.size],
        builder: (BuildContext context, Color tileColor, Widget child) {
          return GridTile(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              height: 2,
              color: tileColor,
            ),
          );
        });
  }
}
