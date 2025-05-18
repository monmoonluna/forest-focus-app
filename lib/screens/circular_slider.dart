import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focus_app/services/user_provider.dart';

class CircularTimePicker extends StatefulWidget {
  final Function(int) onChanged;
  final Function(String, bool)? onTreeChanged;

  const CircularTimePicker({super.key, required this.onChanged, this.onTreeChanged});

  @override
  State<CircularTimePicker> createState() => _CircularTimePickerState();
}

class _CircularTimePickerState extends State<CircularTimePicker> with SingleTickerProviderStateMixin {
  double angle = 0;
  double thumbSize = 28;
  bool isDragging = false;
  late AnimationController _controller;

  int selectedMinutes = 10;
  String selectedTreeAsset = 'assets/images/tree_stage_4.png';
  bool isDefaultTree = true;

  final List<String> availableTreesCircular = [
    'assets/images/tree_stage_4.png',
    'assets/images/golden_tree_circle.png',
    'assets/images/tangerine_tree_circle.png',
    'assets/images/crystal_tree_circle.png',
    'assets/images/celestial_tree_circle.png',
    'assets/images/balloon_flower_circle.png',
    'assets/images/geraniums_flower_circle.png',
  ];

  final List<String> availableTreesSquare = [
    'assets/images/tree_stage_4_square.png',
    'assets/images/golden_tree.png',
    'assets/images/tangerine_tree.png',
    'assets/images/crystal_tree.png',
    'assets/images/celestial_tree.png',
    'assets/images/balloon_flower.png',
    'assets/images/geraniums_flower.png',
  ];

  final Map<String, String> treeToItemName = {
    'assets/images/tree_stage_4.png': 'Default Tree',
    'assets/images/golden_tree_circle.png': 'Golden Tree',
    'assets/images/tangerine_tree_circle.png': 'Tangerine Tree',
    'assets/images/crystal_tree_circle.png': 'Crystal Tree',
    'assets/images/celestial_tree_circle.png': 'Celestial Tree',
    'assets/images/balloon_flower_circle.png': 'Balloon Flower',
    'assets/images/geraniums_flower_circle.png': 'Geraniums Flower',
  };

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

    widget.onChanged(newMinutes);
  }

  String getTreeImage(int minutes) {
    if (minutes >= 120) return 'assets/images/tree_stage_7.png';
    if (minutes >= 90) return 'assets/images/tree_stage_6.png';
    if (minutes >= 60) return 'assets/images/tree_stage_5.png';
    return 'assets/images/tree_stage_4.png';
  }

  void showTreeSelectorDialog() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final screenHeight = MediaQuery.of(context).size.height;
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Select Tree", textAlign: TextAlign.center),
              content: SizedBox(
                width: double.maxFinite,
                height: screenHeight * 0.45,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: availableTreesSquare.length,
                  itemBuilder: (context, index) {
                    final treeSquare = availableTreesSquare[index];
                    final treeCircular = availableTreesCircular[index];
                    final isSelected = treeCircular == selectedTreeAsset;
                    final itemName = treeToItemName[treeCircular] ?? '';
                    final isPurchased = index == 0 || userProvider.purchasedItems.contains(itemName);
                    return GestureDetector(
                      onTap: isPurchased
                          ? () {
                        setState(() {
                          selectedTreeAsset = treeCircular;
                          isDefaultTree = (treeCircular == getTreeImage(selectedMinutes));
                          widget.onTreeChanged?.call(selectedTreeAsset, isDefaultTree);
                        });
                      }
                          : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("This tree has not been purchased yet!"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border.all(color: Colors.greenAccent, width: 3)
                              : Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ColorFiltered(
                                colorFilter: isPurchased
                                    ? const ColorFilter.mode(Colors.transparent, BlendMode.color)
                                    : const ColorFilter.matrix([
                                  0.33, 0.33, 0.33, 0, 0,
                                  0.33, 0.33, 0.33, 0, 0,
                                  0.33, 0.33, 0.33, 0, 0,
                                  0, 0, 0, 1, 0,
                                ]),
                                child: Image.asset(
                                  treeSquare,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              if (!isPurchased)
                                const Center(
                                  child: Icon(
                                    Icons.lock,
                                    color: Colors.white70,
                                    size: 30,
                                  ),
                                ),
                            ],
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