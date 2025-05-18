import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:android_intent_plus/android_intent.dart';
void overlayMain() {
  runApp(const OverlayApp());
}

class OverlayApp extends StatelessWidget {
  const OverlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    final size = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // Đặt nền trong suốt để overlay phủ toàn màn hình
        backgroundColor: Colors.black.withOpacity(0.6),
        body: SizedBox(
          // Đảm bảo chiếm toàn bộ kích thước màn hình
          // width: size.width,
          // height: size.height,
          child: Stack(
            children: [
              // Chặn tương tác với các phần tử bên ngoài
              IgnorePointer(
                ignoring: true,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
              // Nội dung chính của overlay
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
      ),
    );
  }
}