import 'dart:math';
import 'package:flutter/material.dart';

class CircularTimePicker extends StatefulWidget {
  final Function(int) onChanged;

  const CircularTimePicker({super.key, required this.onChanged});

  @override
  State<CircularTimePicker> createState() => _CircularTimePickerState();
}

class _CircularTimePickerState extends State<CircularTimePicker> with SingleTickerProviderStateMixin {
  double angle = 0;
  double thumbSize = 28;
  bool isDragging = false;
  late AnimationController _controller;

  int selectedMinutes = 10;
  String treeAsset = 'assets/tree_stage_4.png';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      lowerBound: 1.0,
      upperBound: 1.5,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset polarToCartesian(double radius, double angle, Offset center) {
    return Offset(
      center.dx + radius * cos(angle - pi / 2),
      center.dy + radius * sin(angle - pi / 2),
    );
  }

  void updateAngle(Offset local, Offset center) {
    double dx = local.dx - center.dx;
    double dy = local.dy - center.dy;

    double rawAngle = atan2(dy, dx) + pi / 2;
    if (rawAngle < 0) rawAngle += 2 * pi;

    double newAngle = rawAngle;
    int newMinutes = (10 + (newAngle / (2 * pi) * 110)).round().clamp(10, 120);

    int currentMinutes = (10 + (angle / (2 * pi) * 110)).round();
    bool isClockwise = (newAngle - angle) <= 0 && (newAngle - angle).abs() > pi / 4;
    bool isCounterClockwise = (newAngle - angle) >= 0 && (angle - newAngle).abs() > pi / 4;

    if ((currentMinutes == 10 && isCounterClockwise) ||
        (currentMinutes == 120 && isClockwise)) return;

    setState(() {
      angle = newAngle;
      selectedMinutes = newMinutes;
      treeAsset = getTreeImage(newMinutes);
    });

    widget.onChanged(newMinutes);
  }

  String getTreeImage(int minutes) {
    if (minutes >= 120) return 'assets/tree_stage_7.png';
    if (minutes >= 90) return 'assets/tree_stage_6.png';
    if (minutes >= 60) return 'assets/tree_stage_5.png';
    return 'assets/tree_stage_4.png';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double size = constraints.maxWidth * 0.7;
        double radius = size / 2.2 + 10;
        Offset center = Offset(size / 2 + 15, size / 2 + 15);
        Offset knobPos = polarToCartesian(radius, angle, center);

        return GestureDetector(
          onPanStart: (_) {
            _controller.forward();
            setState(() => isDragging = true);
          },
          onPanUpdate: (details) {
            RenderBox box = context.findRenderObject() as RenderBox;
            Offset local = box.globalToLocal(details.globalPosition);
            updateAngle(local, center);
          },
          onPanEnd: (_) {
            _controller.reverse();
            setState(() => isDragging = false);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size + 30,
                height: size + 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white24,
                ),
              ),
              // Hiệu ứng chuyển cảnh giữa ảnh cây
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Image.asset(
                  treeAsset,
                  key: ValueKey(treeAsset),
                  width: size * 0.95,
                  height: size * 0.95,
                  fit: BoxFit.cover,
                ),
              ),
              CustomPaint(
                size: Size(size, size),
                painter: _ArcPainter(angle: angle),
              ),
              Positioned(
                left: knobPos.dx - thumbSize / 2,
                top: knobPos.dy - thumbSize / 2,
                child: ScaleTransition(
                  scale: _controller,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: Colors.lightGreenAccent,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double angle;

  _ArcPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    Paint arcPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;

    double startAngle = -pi / 2;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2),
      startAngle,
      angle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
