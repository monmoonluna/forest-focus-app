import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class CompletionScreen extends StatefulWidget {
  final String treeImage;
  const CompletionScreen({super.key, required this.treeImage});

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen> with TickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  final List<Leaf> _leaves = [];
  late AnimationController _leafController;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _playSuccessSound();
    _leafController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startFallingLeaves();
  }

  void _playSuccessSound() async {
    await _player.play(AssetSource('sound/success.mp3'));
  }

  void _startFallingLeaves() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    for (int i = 0; i < 20; i++) {
      _leaves.add(Leaf(
        left: _random.nextDouble() * screenWidth,
        top: -_random.nextDouble() * screenHeight,
        size: 20.0 + _random.nextDouble() * 20.0,
        fallSpeed: 1.0 + _random.nextDouble() * 2.0,
        sway: _random.nextDouble() * 2 - 1,
      ));
    }
  }

  @override
  void dispose() {
    _leafController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF50B36A),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'You’ve grown a beautiful tree! 🌳',
                  style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Image.asset(widget.treeImage, width: 250, height: 250),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF50B36A),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _leafController,
            builder: (_, __) {
              return Stack(
                children: _leaves.map((leaf) {
                  double newTop = leaf.top + _leafController.value * leaf.fallSpeed * 200;
                  double swayOffset = sin(_leafController.value * 2 * pi) * 10 * leaf.sway;
                  return Positioned(
                    left: leaf.left + swayOffset,
                    top: newTop % MediaQuery.of(context).size.height,
                    child: Opacity(
                      opacity: 0.8,
                      child: Icon(Icons.spa, size: leaf.size, color: Colors.white),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class Leaf {
  double left;
  double top;
  double size;
  double fallSpeed;
  double sway;

  Leaf({
    required this.left,
    required this.top,
    required this.size,
    required this.fallSpeed,
    required this.sway,
  });
}
