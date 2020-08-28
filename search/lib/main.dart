import 'package:flutter/material.dart';
import './widgets/maze.dart';
import './models/grid.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  //Has to be even for some reason
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Grid g = new Grid(30);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Algorithms Visualizer"),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: g.size * 14.0,
              child: Maze(g),
            ),
            Container(
              color: Colors.black,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        FloatingActionButton.extended(
                          onPressed: () {
                            g.breadthFirstSearch();
                          },
                          label: Text("BFS"),
                          backgroundColor: Colors.purple,
                        ),
                        FloatingActionButton.extended(
                          onPressed: () {
                            g.depthFirstSearch();
                          },
                          label: Text("DFS"),
                          backgroundColor: Colors.orange,
                        ),
                        FloatingActionButton.extended(
                          onPressed: () {
                            g.aStarSearch();
                          },
                          label: Text(" A* "),
                          backgroundColor: Colors.pink,
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FloatingActionButton.extended(
                          onPressed: () {
                            setState(() {
                              g = new Grid(30);
                            });
                          },
                          label: Text("New Maze"),
                          backgroundColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
