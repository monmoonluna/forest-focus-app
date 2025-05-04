import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class CompletionScreen extends StatefulWidget {
  final String treeImage;
  final String tag;
  final int totalMinutes;
  final Color tagColor;

  const CompletionScreen({
    super.key,
    required this.treeImage,
    required this.tag,
    required this.totalMinutes,
    required this.tagColor,
  });

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen> with TickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  final List<Leaf> _leaves = [];
  late AnimationController _leafController;
  final Random _random = Random();
  bool _showDialog = true;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _showCompletionDialog());
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

  void _showCompletionDialog() {
    int gold = 0;
    if (widget.totalMinutes >= 120) {
      gold = 100;
    } else if (widget.totalMinutes >= 90) {
      gold = 75;
    } else if (widget.totalMinutes >= 60) {
      gold = 50;
    } else {
      gold = 25;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('🎉 Congratulations!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(widget.treeImage, width: 200, height: 200),
              const SizedBox(height: 16),
              Text('You earned $gold gold! 💰'),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF50B36A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],

        );
      },
    );
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
      backgroundColor: const Color(0xFF46AE71),
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
                const SizedBox(height: 30),
                  Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.tagColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 2)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fiber_manual_record, color: widget.tagColor, size: 14),
                      const SizedBox(width: 6),
                      Text(widget.tag, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
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
