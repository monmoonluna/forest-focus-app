import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'completion_screen.dart';
import 'giveup_screen.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../services/planting_session_service.dart';
import 'package:provider/provider.dart';
import '../services/user_provider.dart';

class CountdownScreen extends StatefulWidget {
  final int totalMinutes;
  final String tag;
  final Color tagColor;
  final bool isDeepFocus;
  final String selectedTreeAsset;
  final bool isDefaultTree;

  const CountdownScreen({
    super.key,
    required this.totalMinutes,
    required this.tag,
    required this.tagColor,
    required this.isDeepFocus,
    required this.selectedTreeAsset,
    required this.isDefaultTree,
  });

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> with WidgetsBindingObserver {
  late int remainingSeconds;
  Timer? timer;
  AudioPlayer audioPlayer = AudioPlayer();
  bool isSoundOn = false;
  final PlantingSessionService _sessionService = PlantingSessionService();

  int cancelCountdown = 10;
  bool isCancelable = true;
  late Timer cancelTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    remainingSeconds = widget.totalMinutes * 60;
    startTimer();
    startCancelTimer();
    _checkOverlayPermission();
  }

  void startCancelTimer() {
    cancelTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (cancelCountdown > 0) {
        setState(() {
          cancelCountdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          isCancelable = false;
        });
      }
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer.cancel();
        cancelTimer.cancel();
        audioPlayer.stop();
        // Calculate points earned: 100 coins per 10 minutes
        int pointsEarned = (widget.totalMinutes ~/ 10) * 100;
        // Save session when completed (Success)
        String? error = await _sessionService.createPlantingSession(
          duration: widget.totalMinutes,
          status: "Thành công",
          date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
          pointsEarned: pointsEarned,
          tag: widget.tag,
        );
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        } else {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          // Update coins
          userProvider.addCoins(pointsEarned);
          // Update achievements
          userProvider.updateProgress(1, 1); // Green Thumb: +1 tree planted
          userProvider.updateProgress(0, (widget.totalMinutes / 60).toInt()); // Novice Planter: +hours
        }
        // Navigate to CompletionScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => CompletionScreen(
              treeImage: widget.isDefaultTree
                  ? getTreeImage(0, widget.totalMinutes * 60)
                  : getNonDefaultTreeImage(widget.selectedTreeAsset, 0, widget.totalMinutes * 60),
              tag: widget.tag,
              totalMinutes: widget.totalMinutes,
              tagColor: widget.tagColor,
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
          ? 'assets/images/tree_stage_1.png'
          : progress < 0.66
          ? 'assets/images/tree_stage_2.png'
          : progress < 0.99
          ? 'assets/images/tree_stage_3.png'
          : 'assets/images/tree_stage_4.png';
    } else if (totalMinutes < 90) {
      return progress < 0.25
          ? 'assets/images/tree_stage_1.png'
          : progress < 0.5
          ? 'assets/images/tree_stage_2.png'
          : progress < 0.75
          ? 'assets/images/tree_stage_3.png'
          : progress < 0.99
          ? 'assets/images/tree_stage_4.png'
          : 'assets/images/tree_stage_5.png';
    } else if (totalMinutes < 120) {
      return progress < 0.2
          ? 'assets/images/tree_stage_1.png'
          : progress < 0.4
          ? 'assets/images/tree_stage_2.png'
          : progress < 0.6
          ? 'assets/images/tree_stage_3.png'
          : progress < 0.8
          ? 'assets/images/tree_stage_4.png'
          : progress < 0.99
          ? 'assets/images/tree_stage_5.png'
          : 'assets/images/tree_stage_6.png';
    } else {
      return progress < 0.16
          ? 'assets/images/tree_stage_1.png'
          : progress < 0.33
          ? 'assets/images/tree_stage_2.png'
          : progress < 0.5
          ? 'assets/images/tree_stage_3.png'
          : progress < 0.66
          ? 'assets/images/tree_stage_4.png'
          : progress < 0.83
          ? 'assets/images/tree_stage_5.png'
          : progress < 0.99
          ? 'assets/images/tree_stage_6.png'
          : 'assets/images/tree_stage_7.png';
    }
  }

  String getNonDefaultTreeImage(String treeAsset, int remaining, int total) {
    double progress = 1 - remaining / total;
    String baseName = treeAsset.replaceAll('.png', '');

    return progress < 0.45
        ? 'assets/images/tree_stage_1.png'
        : progress < 0.95
        ? 'assets/images/tree_stage_2.png'
        : '$baseName.png';
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
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    cancelTimer.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _checkOverlayPermission() async {
    if (!await FlutterOverlayWindow.isPermissionGranted()) {
      bool? granted = await FlutterOverlayWindow.requestPermission();
      if (granted != true) {
        print("Quyền overlay bị từ chối");
      }
    }
  }

  void handleCancel() {
    audioPlayer.stop();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void handleGiveUp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Bỏ cuộc?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bạn có thực sự muốn từ bỏ việc trồng cây này? 😢',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Hủy'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () async {
                  timer?.cancel();
                  cancelTimer.cancel();
                  audioPlayer.stop();
                  // Lưu phiên trồng cây khi bỏ cuộc (Thất bại)
                  String? error = await _sessionService.createPlantingSession(
                    duration: widget.totalMinutes - (remainingSeconds ~/ 60),
                    status: "Thất bại",
                    date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                    pointsEarned: 0,
                    tag: widget.tag,
                  );
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error)),
                    );
                  }
                  Navigator.pop(context);
                  // Chuyển đến GiveUpScreen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GiveUpScreen(
                        witheredTreeImage: 'assets/images/withered_tree.png',
                        tag: widget.tag,
                        tagColor: widget.tagColor,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF5350),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Bỏ cuộc'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.isDeepFocus) return;

    if (state == AppLifecycleState.paused) {
      _showOverlay();
    } else if (state == AppLifecycleState.resumed) {
      _closeOverlay();
    }
  }

  Future<void> _closeOverlay() async {
    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.closeOverlay();
    }
  }

  Future<void> _showOverlay() async {
    if (await FlutterOverlayWindow.isPermissionGranted()) {
      final screenWidth = (ui.window.physicalSize.width / 1).round();
      final screenHeight = (ui.window.physicalSize.height /0.6).round();
      await FlutterOverlayWindow.showOverlay(
        height: screenHeight,
        width: screenWidth,
        //alignment: OverlayAlignment.center,
        flag: OverlayFlag.defaultFlag,
        visibility: NotificationVisibility.visibilityPublic,
        enableDrag: false,// Căn giữa overlay
      );
    } else {
      await FlutterOverlayWindow.requestPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalSeconds = widget.totalMinutes * 60;

    return WillPopScope(
      onWillPop: () async {
        if (isCancelable) {
          handleCancel();
          return false;
        } else {
          handleGiveUp();
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF46AE71),
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Hãy tập trung và để cây của bạn lớn lên! 🌱',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: 280,
                      height: 280,
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
                            widget.isDefaultTree
                                ? getTreeImage(remainingSeconds, totalSeconds)
                                : getNonDefaultTreeImage(widget.selectedTreeAsset, remainingSeconds, totalSeconds),
                            key: ValueKey(widget.isDefaultTree
                                ? getTreeImage(remainingSeconds, totalSeconds)
                                : getNonDefaultTreeImage(widget.selectedTreeAsset, remainingSeconds, totalSeconds)),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
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
                    Text(
                      formatTime(remainingSeconds),
                      style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        isCancelable ? handleCancel() : handleGiveUp();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCancelable ? Colors.orangeAccent : Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 4,
                      ),
                      child: Text(
                        isCancelable ? 'Hủy (${cancelCountdown}s)' : 'Bỏ cuộc',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  onPressed: toggleSound,
                  icon: Icon(
                    isSoundOn ? Icons.volume_up : Icons.volume_off,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}