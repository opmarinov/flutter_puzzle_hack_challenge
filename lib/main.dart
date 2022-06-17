import 'dart:html';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

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
    var boxSize = MediaQuery.of(context).size.width * 0.3;

    if (listComparator.equals(blocks, sorted)) {
      isOver = true;
    }

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: boxSize,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  _buildShuffleButton(),
                  const SizedBox(
                    width: 20.0,
                  ),
                  _buildDropdown(dropdownValue),
                ],
              ),
              const SizedBox(
                height: 60.0,
              ),
              Text(
                'Moves: $moves | Tiles: $range',
                style: TextStyle(color: blockColor, fontSize: 30),
              ),
              const SizedBox(
                height: 60.0,
              ),
              SizedBox(
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
              ),
            ],
          ),
        ),
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
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 70,
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

  _buildDropdown(String dropdownValue) {
    return Container(
      width: 150,
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
        isExpanded: true,
        value: dropdownValue,
        icon: Icon(
          Icons.arrow_drop_down_outlined,
          color: blockColor,
        ),
        style: TextStyle(
          color: blockColor,
        ),
        onChanged: (String? newValue) {
          setState(() {
            dropdownValue = newValue!;

            var split = dropdownValue.split("x");
            var number = int.parse(split[0]);

            range = number * number;
            rows = number;

            isOver = false;
            initGame();
          });
        },
        items: <String>['3x3', '4x4', '5x5']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
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
        padding: const EdgeInsets.all(20.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
      ),
    );
  }
}
