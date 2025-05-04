import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class GiveUpScreen extends StatefulWidget {
  final String witheredTreeImage;
  final String tag;
  final Color tagColor;

  const GiveUpScreen({
    super.key,
    required this.witheredTreeImage,
    required this.tag,
    required this.tagColor,
  });

  @override
  State<GiveUpScreen> createState() => _GiveUpScreenState();
}

class _GiveUpScreenState extends State<GiveUpScreen> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playFailSound();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showFailureDialog());
  }

  void _playFailSound() async {
    await _player.play(AssetSource('sound/failure.mp3'));
  }

  void _showFailureDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🌧 Oops...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(widget.witheredTreeImage, width: 200, height: 200),
            const SizedBox(height: 16),
            const Text('Your tree didn’t make it this time. Don’t give up! 🌱'),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF46AE71),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'The tree has withered... 💔',
              style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Image.asset(widget.witheredTreeImage, width: 250, height: 250),
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
                foregroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
