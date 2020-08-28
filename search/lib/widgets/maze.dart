import 'package:flutter/material.dart';
import 'package:search/models/grid.dart';
import './mazeTile.dart';

class Maze extends StatefulWidget {
  Grid grid;
  Maze(this.grid);
  @override
  _MazeState createState() => _MazeState();
}

class _MazeState extends State<Maze> {
  //All the rows of the maze stored in a list of lists
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.grid.size,
        ),
        itemBuilder: (context, index) {
          return MazeTile(index, widget.grid);
        },
        itemCount: widget.grid.size * widget.grid.size,
      ),
    );
  }
}
