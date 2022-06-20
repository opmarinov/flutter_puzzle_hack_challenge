import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:responsive_builder/responsive_builder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puzzle hack',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<int> blocks = List.empty(growable: true);
  List<int> sorted = List.empty(growable: true);

  // starting index
  var transparentBlockIndex = 0;

  var allowedIndexes = [];

  var range = 3 * 3;
  var rows = 3;

  var sortedColor = Colors.blueGrey;
  var blockColor = Colors.blueAccent;
  var transparentColor = Colors.transparent;

  var moves = 0;

  var isOver = false;

  var listComparator = const ListEquality();

  var dropdownValue = '3x3';

  @override
  void initState() {
    initGame();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if (listComparator.equals(blocks, sorted)) {
      isOver = true;
    }

    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {

          double screenSize = MediaQuery.of(context).size.width;
          double boxSize = screenSize * 0.2;

          if(orientation == Orientation.landscape) {
            screenSize = MediaQuery.of(context).size.height;
            boxSize = screenSize * 0.8;
          }

          return ResponsiveBuilder(
            builder: (context, sizingInformation) {
              if (sizingInformation.deviceScreenType ==
                  DeviceScreenType.desktop) {
                boxSize = screenSize * 0.4;
              }

              if (sizingInformation.deviceScreenType ==
                  DeviceScreenType.tablet) {
                boxSize = screenSize * 0.6;
              }

              if (sizingInformation.deviceScreenType ==
                  DeviceScreenType.mobile) {
                boxSize = screenSize * 0.8;
              }

              return _buildBody(boxSize);
            },
          );
        },
      ),
    );
  }

  Widget card({color = Color, text = String, index = int}) {
    var transparent = index == transparentBlockIndex;

    return GestureDetector(
      onTap: isOver
          ? null
          : () {
              setState(
                () {
                  if (allowedIndexes.contains(index)) {
                    move(index);
                  }
                },
              );
            },
      child: Opacity(
        opacity: transparent ? 0 : 1,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 2,
          color: color,
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 50,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void move(newIndex) {
    var oldBlock = blocks[transparentBlockIndex];
    var newBlock = blocks[newIndex];

    blocks[transparentBlockIndex] = newBlock;
    blocks[newIndex] = oldBlock;

    transparentBlockIndex = newIndex;

    indexAllowedIndexes();

    moves++;
  }

  void indexAllowedIndexes() {
    var up = transparentBlockIndex + rows;
    var down = transparentBlockIndex - rows;
    var right = (transparentBlockIndex + 1) % rows == 0
        ? -1
        : transparentBlockIndex + 1;
    var left = transparentBlockIndex - 1;

    allowedIndexes = [
      up,
      down,
      right,
      left,
    ];
  }

  void initGame() {
    blocks = [];
    sorted = [];

    moves = 0;

    transparentBlockIndex = 0;

    for (var i = 1; i < range; i++) {
      blocks.add(i);
      sorted.add(i);
    }

    blocks.shuffle();

    // insert zero at start
    blocks.insert(0, 0);

    // insert zero at end
    sorted.add(0);

    indexAllowedIndexes();
  }

  _buildShuffleButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.refresh),
      label: const Text("Shuffle"),
      onPressed: () {
        setState(() {
          initGame();

          isOver = false;
        });
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
      ),
    );
  }

  _buildBody(double boxSize) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
          ),
        ),

        Positioned(
          bottom: MediaQuery.of(context).size.height - 250,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Puzzle\nChallenge',
                  style: TextStyle(fontSize: 40),
                ),
                const SizedBox(
                  height: 10,
                ),
                _buildMoveInfoText(),
                const SizedBox(
                  height: 20,
                ),
                _buildShuffleButton(),
              ],
            ),
          ),
        ),
        Positioned(
          right: 50,
          child: _buildPuzzleModeButtons(),
        ),
        Center(
          child: _buildPuzzleBlocks(boxSize),
        ),
      ],
    );
  }

  _buildMoveInfoText() {
    return Text(
      'Moves: $moves  |  Tiles $range',
      style: TextStyle(color: blockColor, fontSize: 20),
    );
  }

  _buildPuzzleBlocks(boxSize) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
      ),
      width: boxSize,
      height: boxSize,
      child: GridView.count(
        crossAxisCount: rows,
        children: blocks.map((block) {
          var index = blocks.indexOf(block);

          if (isOver) {
            return card(
              color: block == 0 ? transparentColor : sortedColor,
              text: '$block',
              index: index,
            );
          }

          return card(
            color: block == 0 ? transparentColor : blockColor,
            text: '$block',
            index: index,
          );
        }).toList(),
      ),
    );
  }

  _buildPuzzleModeButtons() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
            ),
            onPressed: () {
              setState(() {
                range = 3 * 3;
                rows = 3;

                isOver = false;
                initGame();
              });
            },
            child: const Text("3x3"),
          ),
          const SizedBox(
            width: 5,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
            ),
            onPressed: () {
              setState(() {
                range = 4 * 4;
                rows = 4;

                isOver = false;
                initGame();
              });
            },
            child: const Text("4x4"),
          ),
          const SizedBox(
            width: 5,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
            ),
            onPressed: () {
              setState(() {
                range = 5 * 5;
                rows = 5;

                isOver = false;
                initGame();
              });
            },
            child: const Text("5x5"),
          ),
        ],
      ),
    );
  }
}
