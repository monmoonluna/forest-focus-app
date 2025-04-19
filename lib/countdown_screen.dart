import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'completion_screen.dart';
import 'data/services/planting_session_service.dart';
import 'package:intl/intl.dart';

class CountdownScreen extends StatefulWidget {
  final int totalMinutes;
  const CountdownScreen({super.key, required this.totalMinutes});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  late int remainingSeconds;
  Timer? timer;
  AudioPlayer audioPlayer = AudioPlayer();
  bool isSoundOn = false;
  final PlantingSessionService _sessionService = PlantingSessionService();

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.totalMinutes * 60;
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer.cancel();
        audioPlayer.stop();
        // Lưu session vào Firestore khi hoàn thành
        _sessionService.createPlantingSession(
          duration: widget.totalMinutes,
          status: "Thành công",
          date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
          pointsEarned: 200,
        );
        // Chuyển sang CompletionScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => CompletionScreen(
              treeImage: getTreeImage(0, widget.totalMinutes * 60),
            ),
          ),
        );
      }
    });
  }

  String formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String getTreeImage(int remaining, int total) {
    double progress = 1 - remaining / total;
    int totalMinutes = widget.totalMinutes;

    if (totalMinutes < 60) {
      return progress < 0.33
          ? 'assets/tree_stage_1.png'
          : progress < 0.66
          ? 'assets/tree_stage_2.png'
          : progress < 0.99
          ? 'assets/tree_stage_3.png'
          : 'assets/tree_stage_4.png';
    } else if (totalMinutes < 90) {
      return progress < 0.25
          ? 'assets/tree_stage_1.png'
          : progress < 0.5
          ? 'assets/tree_stage_2.png'
          : progress < 0.75
          ? 'assets/tree_stage_3.png'
          : progress < 0.99
          ? 'assets/tree_stage_4.png'
          : 'assets/tree_stage_5.png';
    } else if (totalMinutes < 120) {
      return progress < 0.2
          ? 'assets/tree_stage_1.png'
          : progress < 0.4
          ? 'assets/tree_stage_2.png'
          : progress < 0.6
          ? 'assets/tree_stage_3.png'
          : progress < 0.8
          ? 'assets/tree_stage_4.png'
          : progress < 0.99
          ? 'assets/tree_stage_5.png'
          : 'assets/tree_stage_6.png';
    } else {
      return progress < 0.16
          ? 'assets/tree_stage_1.png'
          : progress < 0.33
          ? 'assets/tree_stage_2.png'
          : progress < 0.5
          ? 'assets/tree_stage_3.png'
          : progress < 0.66
          ? 'assets/tree_stage_4.png'
          : progress < 0.83
          ? 'assets/tree_stage_5.png'
          : progress < 0.99
          ? 'assets/tree_stage_6.png'
          : 'assets/tree_stage_7.png';
    }
  }

  void toggleSound() async {
    if (isSoundOn) {
      await audioPlayer.stop();
    } else {
      await audioPlayer.setReleaseMode(ReleaseMode.loop);
      await audioPlayer.play(AssetSource('sound/nature.mp3'), volume: 0.5);
    }
    setState(() {
      isSoundOn = !isSoundOn;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalSeconds = widget.totalMinutes * 60;

    return Scaffold(
      backgroundColor: const Color(0xFF50B36A),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Stay focused and let your tree grow! 🌱',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Tree image with animation
              Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white38, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    switchInCurve: Curves.easeIn,
                    switchOutCurve: Curves.easeOut,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Image.asset(
                      getTreeImage(remainingSeconds, totalSeconds),
                      key: ValueKey(getTreeImage(remainingSeconds, totalSeconds)),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Countdown time
              Text(
                formatTime(remainingSeconds),
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
              ),

              const SizedBox(height: 20),

              // Sound toggle
              IconButton(
                onPressed: toggleSound,
                icon: Icon(
                  isSoundOn ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                  size: 32,
                ),
              ),

              const SizedBox(height: 12),

              // Give up button
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Give up?'),
                      content: const Text('Do you really want to give up growing your tree? 😢'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
                        TextButton(
                          onPressed: () {
                            audioPlayer.stop();
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 4,
                ),
                child: const Text(
                  "Give up",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}