import 'dart:collection';
import 'dart:math';
//import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:search/models/customStack.dart';
import 'package:collection/collection.dart';

// void main() {
//   Grid g = new Grid(20);
//   g.generateMaze();

//   for (var i = 0; i < g.size; i++) {
//     for (var j = 0; j < g.size; j++) {
//       if (g.array[j][i]) {
//         stdout.write('◼◼◼◼◼');
//       } else {
//         stdout.write('◻◻◻◻◻');
//       }
//     }
//     print('');
//   }
// }

class Grid {
  var array;
  int size;
  var ColorMap = HashMap<int, HashMap<int, ValueNotifier<Color>>>();
  final Color wall = Colors.black;
  final Color path = Colors.cyan;
  final Color searchedBFS = Colors.purple;
  final Color searchedDFS = Colors.orange;
  final Color searchedAStar = Colors.pink;
  final Color answer = Colors.green;
  final Color start = Colors.yellow;
  final Color end = Colors.red;
  List<int> startCell = new List<int>(2);
  List<int> endCell = new List<int>(2);

  Grid(this.size) {
    array = List<List>();
    for (var i = 0; i < size; i++) {
      var column = List.filled(size, true, growable: true);
      array.add(column);
    }

    generateMaze();
    for (var i = 0; i < size; i++) {
      ColorMap[i] = HashMap<int, ValueNotifier<Color>>();
      for (var j = 0; j < size; j++) {
        ColorMap[i][j] = new ValueNotifier<Color>(array[i][j] ? wall : path);
      }
    }
    setStartCell();
    setEndCell();
  }

  // true means blocked, false means open
  void setCell(x, y, val) {
    if (isLegal(x, y)) {
      array[x][y] = val;
    }
  }

  bool isBlocked(x, y) {
    return array[x][y];
  }

  bool isLegal(x, y) {
    return x > 0 && x < size - 1 && y > 0 && y < size - 1;
  }

  //Turns the cell in between both cells into a passage cell
  void connect(x1, y1, x2, y2) {
    int x = x1 - x2;
    int y = y1 - y2;

    if (x == -2 && y == 0 && isLegal(x1 - 1, y1)) {
      setCell(x1 - 1, y1, false);
    }
    if (x == 2 && y == 0 && isLegal(x1 + 1, y1)) {
      setCell(x1 + 1, y1, false);
    }
    if (x == 0 && y == 2 && isLegal(x1, y1 + 1)) {
      setCell(x1, y1 + 1, false);
    }
    if (x == 0 && y == -2 && isLegal(x1, y1 - 1)) {
      setCell(x1, y1 - 1, false);
    }
  }

  List frontierGenerator(x1, y1) {
    List<List<int>> frontier = new List<List<int>>();
    List<List<int>> neighbors = [
      [-2, 0],
      [2, 0],
      [0, 2],
      [0, -2]
    ];
    for (var neighbor in neighbors) {
      int fx = x1 + neighbor[0];
      int fy = y1 + neighbor[1];
      //if neighbor is valid and a wall it's in the frontier
      if (isLegal(fx, fy) && array[fx][fy] == true) {
        frontier.add([fx, fy]);
      }
    }
    return frontier;
  }

  List neighborGenerator(x1, y1) {
    List<List<int>> frontier = new List<List<int>>();
    List<List<int>> neighbors = [
      [-2, 0],
      [2, 0],
      [0, 2],
      [0, -2]
    ];
    for (var neighbor in neighbors) {
      int fx = x1 + neighbor[0];
      int fy = y1 + neighbor[1];
      //if neighbor is valid and a wall it's in the frontier
      if (isLegal(fx, fy) && array[fx][fy] == false) {
        frontier.add([fx, fy]);
      }
    }
    return frontier;
  }

  void setStartCell() {
    var rng = new Random();
    int x = rng.nextInt(size);
    int y = rng.nextInt(size);
    while (array[x][y] || (x == endCell[0] && y == endCell[1])) {
      x = rng.nextInt(size);
      y = rng.nextInt(size);
    }
    startCell[0] = x;
    startCell[1] = y;
    ColorMap[x][y].value = start;
  }

  void setEndCell() {
    var rng = new Random();
    int x = rng.nextInt(size);
    int y = rng.nextInt(size);
    while (array[x][y] || (x == startCell[0] && y == startCell[1])) {
      x = rng.nextInt(size);
      y = rng.nextInt(size);
    }
    endCell[0] = x;
    endCell[1] = y;
    ColorMap[x][y].value = end;
  }

  void generateMaze() {
    var frontier = List();
    //to generate random ints from 1 to
    var rng = new Random();
    var first = [rng.nextInt(size), rng.nextInt(size)];
    setCell(first[0], first[1], false);
    frontier = frontierGenerator(first[0], first[1]);

    while (frontier.isNotEmpty) {
      //choose random cell from frontier
      var index = rng.nextInt(frontier.length);
      var popped = frontier[index];
      frontier.removeAt(index);
      setCell(popped[0], popped[1], false);
      frontier.addAll(frontierGenerator(popped[0], popped[1]));
      //print(frontier);

      //choose random neighbor of frontier
      var neighbors = neighborGenerator(popped[0], popped[1]);
      if (neighbors.isNotEmpty) {
        var pickedNeighbor = rng.nextInt(neighbors.length);
        var neighbor = neighbors[pickedNeighbor];

        //open the in-between of popped and neighbor
        connect(popped[0], popped[1], neighbor[0], neighbor[1]);
      }
    }
  }

  List<List<int>> getSearchNeighbors(List<int> curr, List<List<bool>> visited) {
    List<List<int>> result = new List<List<int>>();
    List<List<int>> neighbors = [
      [-1, 0],
      [1, 0],
      [0, 1],
      [0, -1]
    ];
    int x = curr[0];
    int y = curr[1];
    for (var neighbor in neighbors) {
      int fx = x + neighbor[0];
      int fy = y + neighbor[1];
      //if neighbor is valid and a wall it's in the frontier
      if (isLegal(fx, fy) && array[fx][fy] == false && !visited[fx][fy]) {
        result.add([fx, fy]);
      }
    }
    return result;
  }

  //Should backtrack through the map and set correct path to answer color
  void foundEnd(foundFromMap) {
    // List<int> curr = foundFromMap[endCell[0]][endCell[1]];
    // List<List<int>> solutionPath = new List();
    // while ((foundFromMap[curr[0]][curr[1]])[0] != startCell[0] &&
    //     (foundFromMap[curr[0]][curr[1]])[1] != startCell[1]) {
    //   print(curr);
    //   solutionPath.add(curr);
    //   curr = foundFromMap[curr[0]][curr[1]];
    // }
    // for (List<int> i in solutionPath.reversed) {
    //   ColorMap[i[0]][i[1]].value = answer;
    // }
  }

  void breadthFirstSearch() {
    var foundFrom = HashMap<int, HashMap<int, List<int>>>();
    for (var i = 0; i < size; i++) {
      foundFrom[i] = new HashMap<int, List<int>>();
    }
    Queue<List<int>> q = new Queue<List<int>>();
    List<List<bool>> visited = new List<List<bool>>();
    for (var i = 0; i < size; i++) {
      var column = List.filled(size, false, growable: true);
      visited.add(column);
    }

    q.add(startCell);
    int delay = 700;
    while (q.isNotEmpty) {
      print("running loop");
      print(q);
      var current = q.removeFirst();
      if (current[0] == endCell[0] && current[1] == endCell[1]) {
        delay += 20;
        Future.delayed(Duration(milliseconds: delay), () {
          foundEnd(foundFrom);
        });
        return;
      }
      visited[current[0]][current[1]] = true;
      var neighbors = getSearchNeighbors(current, visited);
      q.addAll(neighbors);

      for (List n in neighbors) {
        foundFrom[n[0]][n[1]] = current;
      }
      if (ColorMap[current[0]][current[1]].value != start) {
        Future.delayed(Duration(milliseconds: delay), () {
          ColorMap[current[0]][current[1]].value = searchedBFS;
        });
      }
      delay += 4;
    }
    print("no solution");
  }

  void depthFirstSearch() {
    var foundFrom = HashMap<int, HashMap<int, List<int>>>();
    for (var i = 0; i < size; i++) {
      foundFrom[i] = new HashMap<int, List<int>>();
    }
    CustomStack<List<int>> q = new CustomStack<List<int>>();
    List<List<bool>> visited = new List<List<bool>>();
    for (var i = 0; i < size; i++) {
      var column = List.filled(size, false, growable: true);
      visited.add(column);
    }

    q.push(startCell);
    int delay = 700;
    while (q.isNotEmpty()) {
      print("running loop");
      print(q);
      var current = q.pop();
      if (current[0] == endCell[0] && current[1] == endCell[1]) {
        delay += 20;
        Future.delayed(Duration(milliseconds: delay), () {
          foundEnd(foundFrom);
        });
        return;
      }
      visited[current[0]][current[1]] = true;
      var neighbors = getSearchNeighbors(current, visited);
      q.addAll(neighbors);

      for (List n in neighbors) {
        foundFrom[n[0]][n[1]] = current;
      }
      if (ColorMap[current[0]][current[1]].value != start) {
        Future.delayed(Duration(milliseconds: delay), () {
          ColorMap[current[0]][current[1]].value = searchedDFS;
        });
      }
      delay += 50;
    }
    print("no solution");
  }

  double euclideanDistance(List<int> current, List<int> end) {
    return sqrt(pow((current[0] - end[0]), 2) + pow((current[1] - end[1]), 2));
  }

  void aStarSearch() {
    var foundFrom = HashMap<int, HashMap<int, List<int>>>();
    for (var i = 0; i < size; i++) {
      foundFrom[i] = new HashMap<int, List<int>>();
    }
    PriorityQueue q = new PriorityQueue((a, b) {
      return (euclideanDistance(a, endCell) - euclideanDistance(b, endCell))
          .ceil();
    });
    List<List<bool>> visited = new List<List<bool>>();
    for (var i = 0; i < size; i++) {
      var column = List.filled(size, false, growable: true);
      visited.add(column);
    }

    q.add(startCell);
    int delay = 700;
    while (q.length != 0) {
      print("running loop");
      print(q);
      var current = q.removeFirst();
      if (current[0] == endCell[0] && current[1] == endCell[1]) {
        delay += 20;
        Future.delayed(Duration(milliseconds: delay), () {
          foundEnd(foundFrom);
        });
        return;
      }
      visited[current[0]][current[1]] = true;
      var neighbors = getSearchNeighbors(current, visited);
      q.addAll(neighbors);
      for (List n in neighbors) {
        foundFrom[n[0]][n[1]] = current;
      }
      if (ColorMap[current[0]][current[1]].value != start) {
        Future.delayed(Duration(milliseconds: delay), () {
          ColorMap[current[0]][current[1]].value = searchedAStar;
        });
      }
      delay += 50;
    }
    print("no solution");
  }
}
