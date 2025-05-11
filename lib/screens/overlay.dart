import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';

void overlayMain() {
  runApp(const OverlayApp());
}

class OverlayApp extends StatelessWidget {
  const OverlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.6),
        body: Stack(
          children: [
            IgnorePointer(
              ignoring: true, // Chặn thao tác bên ngoài
              child: Container(
                color: Colors.transparent,
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, size: 100, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    'You left Focus Mode!',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () async {
                       await FlutterOverlayWindow.closeOverlay();
                       const intent = AndroidIntent(
                         action: 'android.intent.action.MAIN',
                         category: 'android.intent.category.LAUNCHER',
                         package: 'com.example.focus_app',
                         componentName: 'com.example.focus_app.MainActivity',
                       );
                       await intent.launch();
                    },
                    child: const Text('Return to Focus', style: TextStyle(fontSize: 18)),
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
