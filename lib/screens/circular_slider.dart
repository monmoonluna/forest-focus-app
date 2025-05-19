import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class CircularTimePicker extends StatefulWidget {
  final Function(int) onChanged;
  final Function(String, bool)? onTreeChanged;
  final String? sessionId; // Thêm sessionId để đồng bộ với phiên Plant together

  const CircularTimePicker({
    super.key,
    required this.onChanged,
    this.onTreeChanged,
    this.sessionId,
  });

  @override
  State<CircularTimePicker> createState() => _CircularTimePickerState();
}

class _CircularTimePickerState extends State<CircularTimePicker> with SingleTickerProviderStateMixin {
  double angle = 0;
  double thumbSize = 28;
  bool isDragging = false;
  late AnimationController _controller;
  late DatabaseReference _sessionRef;

  int selectedMinutes = 10;
  String selectedTreeAsset = 'assets/images/tree_stage_4.png';
  bool isDefaultTree = true;

  final List<String> availableTreesCircular = [
    'assets/images/tree_stage_4.png',
    'assets/images/balloon_flower_circle.png',
    'assets/images/celestial_tree_circle.png',
    'assets/images/crystal_tree_circle.png',
    'assets/images/geraniums_flower_circle.png',
    'assets/images/golden_tree_circle.png',
  ];

  final List<String> availableTreesSquare = [
    'assets/images/tree_stage_4_square.png',
    'assets/images/balloon_flower.png',
    'assets/images/celestial_tree.png',
    'assets/images/crystal_tree.png',
    'assets/images/geraniums_flower.png',
    'assets/images/golden_tree.png',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      lowerBound: 1.0,
      upperBound: 1.5,
    );

    // Nếu có sessionId, đồng bộ với Realtime Database
    if (widget.sessionId != null) {
      _sessionRef = FirebaseDatabase.instance.ref().child('focus_sessions/${widget.sessionId}/session_details');
      _sessionRef.onValue.listen((event) {
        final data = event.snapshot.value as Map?;
        if (data != null) {
          setState(() {
            selectedMinutes = (data['duration_minutes'] ?? selectedMinutes);
            selectedTreeAsset = data['tree_asset'] ?? selectedTreeAsset;
            // Cập nhật angle dựa trên selectedMinutes
            angle = (selectedMinutes - 10) / 110 * 2 * pi;
            if (angle < 0) angle += 2 * pi;
          });
        }
      });
    }
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

    int currentMinutes = (10 + (angle / (2 * pi) * 110)).round().clamp(10, 120);

    bool isClockwise = (newAngle - angle) <= 0 && (newAngle - angle).abs() > pi;
    bool isCounterClockwise = (newAngle - angle) >= 0 && (angle - newAngle).abs() > pi;

    if ((currentMinutes == 10 && isCounterClockwise) ||
        (currentMinutes == 120 && isClockwise)) return;

    setState(() {
      angle = newAngle;
      selectedMinutes = newMinutes;
      if (isDefaultTree) {
        selectedTreeAsset = getTreeImage(newMinutes);
        widget.onTreeChanged?.call(selectedTreeAsset, isDefaultTree);
      }
    });

    // Cập nhật Realtime Database nếu có sessionId
    if (widget.sessionId != null) {
      _sessionRef.update({
        'duration_minutes': selectedMinutes,
        'tree_asset': selectedTreeAsset,
      });
    }

    widget.onChanged(newMinutes);
  }

  String getTreeImage(int minutes) {
    if (minutes >= 120) return 'assets/images/tree_stage_7.png';
    if (minutes >= 90) return 'assets/images/tree_stage_6.png';
    if (minutes >= 60) return 'assets/images/tree_stage_5.png';
    return 'assets/images/tree_stage_4.png';
  }

  void showTreeSelectorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Select Tree", textAlign: TextAlign.center),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: availableTreesSquare.length,
                  itemBuilder: (context, index) {
                    final treeSquare = availableTreesSquare[index];
                    final treeCircular = availableTreesCircular[index];
                    final isSelected = treeCircular == selectedTreeAsset;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTreeAsset = treeCircular;
                          isDefaultTree = (treeCircular == getTreeImage(selectedMinutes));
                          widget.onTreeChanged?.call(selectedTreeAsset, isDefaultTree);

                          // Cập nhật Realtime Database nếu có sessionId
                          if (widget.sessionId != null) {
                            _sessionRef.update({
                              'tree_asset': selectedTreeAsset,
                            });
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border.all(color: Colors.greenAccent, width: 3)
                              : Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            treeSquare,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
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
          onPanStart: (details) {
            RenderBox box = context.findRenderObject() as RenderBox;
            Offset local = box.globalToLocal(details.globalPosition);

            if ((local - knobPos).distance <= thumbSize) {
              _controller.forward();
              setState(() => isDragging = true);
            } else {
              showTreeSelectorDialog();
            }
          },
          onPanUpdate: (details) {
            if (!isDragging) return;
            RenderBox box = context.findRenderObject() as RenderBox;
            Offset local = box.globalToLocal(details.globalPosition);
            updateAngle(local, center);
          },
          onPanEnd: (_) {
            if (!isDragging) return;
            _controller.reverse();
            setState(() => isDragging = false);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size + 30,
                height: size + 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white24,
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: showTreeSelectorDialog,
                child: ClipOval(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Image.asset(
                      selectedTreeAsset,
                      key: ValueKey(selectedTreeAsset),
                      width: size * 0.95,
                      height: size * 0.95,
                      fit: BoxFit.cover,
                    ),
                  ),
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