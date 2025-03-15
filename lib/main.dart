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
              return GestureDetector(
                onTap: () {
                  // Prevent taps during animation or delay
                  if (!gameState.isProcessing && !card.isFaceUp) {
                    gameState.flipCard(index);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  transform: Matrix4.identity()
                    ..rotateY(card.isFaceUp ? 3.141592653589793 : 0), // Flip animation
                  transformAlignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: card.isFaceUp ? Colors.blue : Colors.red,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateY(card.isFaceUp ? 3.141592653589793 : 0), // Un-mirror the text
                      child: Text(
                        card.isFaceUp ? card.frontDesign : card.backDesign,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CardModel {
  final String frontDesign; // The design on the front of the card (e.g., a number)
  final String backDesign = "?"; // The design on the back of the card (always "?")
  bool isFaceUp = false; // Whether the card is currently face-up or face-down
  bool isMatched = false; // Whether the card has been matched

  CardModel(this.frontDesign);

  @override
  String toString() {
    return 'CardModel(frontDesign: $frontDesign, isFaceUp: $isFaceUp, isMatched: $isMatched)';
  }
}

class GameState with ChangeNotifier {
  List<CardModel> cards = [];
  List<int> faceUpIndices = []; // Tracks indices of currently face-up cards
  bool isProcessing = false; // Prevents taps during animation or delay

  GameState() {
    // Initialize the cards with pairs of numbers
    List<String> designs = ['1', '2', '3', '4', '5', '6', '7', '8'];
    designs = [...designs, ...designs]; // Duplicate to create pairs
    designs.shuffle(); // Shuffle the cards

    // Convert the shuffled designs into CardModel objects
    cards = designs.map((design) => CardModel(design)).toList();
  }

  void flipCard(int index) async {
    // Prevent flipping if already processing or card is matched
    if (isProcessing || cards[index].isMatched) return;

    // Flip the card
    cards[index].isFaceUp = !cards[index].isFaceUp;
    notifyListeners();

    if (cards[index].isFaceUp) {
      faceUpIndices.add(index);

      // Check if two cards are face-up
      if (faceUpIndices.length == 2) {
        isProcessing = true;
        notifyListeners();

        // Check for a match
        final firstCard = cards[faceUpIndices[0]];
        final secondCard = cards[faceUpIndices[1]];

        if (firstCard.frontDesign == secondCard.frontDesign) {
          // Match found: mark cards as matched
          firstCard.isMatched = true;
          secondCard.isMatched = true;
        } else {
          // No match: flip cards back after a delay
          await Future.delayed(const Duration(milliseconds: 1000));
          firstCard.isFaceUp = false;
          secondCard.isFaceUp = false;
        }

        // Reset face-up cards and allow further taps
        faceUpIndices.clear();
        isProcessing = false;
        notifyListeners();
      }
    } else {
      faceUpIndices.remove(index);
    }
  }
}