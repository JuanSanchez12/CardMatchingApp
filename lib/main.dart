import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      home: const MyHomePage(title: 'Card Matching Game'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: gameState.cards.length,
            itemBuilder: (context, index) {
              final card = gameState.cards[index];
              return ElevatedButton(
                onPressed: () {
                  gameState.flipCard(index);
                },
                child: Text(
                  card.isFaceUp ? card.frontDesign : card.backDesign,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class GameState with ChangeNotifier {
  List<CardModel> cards = [];

  GameState() {
    List<String> designs = ['1', '2', '3', '4', '5', '6', '7', '8'];
    designs = [...designs, ...designs];
    designs.shuffle();
    cards = designs.map((design) => CardModel(design)).toList();
  }

  void flipCard(int index) {
    cards[index].isFaceUp = !cards[index].isFaceUp;
    notifyListeners();
  }
}

class CardModel {
  final String frontDesign;
  final String backDesign = "?";
  bool isFaceUp = false;

  CardModel(this.frontDesign);

  @override
  String toString() {
    return 'CardModel(frontDesign: $frontDesign, isFaceUp: $isFaceUp)';
  }
}