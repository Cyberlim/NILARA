import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// 1. Water Background (Floating Water Bubbles & Gentle Ripples)
class AnimatedWaterBackground extends StatefulWidget {
  const AnimatedWaterBackground({super.key});
  @override
  State<AnimatedWaterBackground> createState() => _AnimatedWaterBackgroundState();
}

class _AnimatedWaterBackgroundState extends State<AnimatedWaterBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: WaterBackgroundPainter(_controller.value),
          size: const Size(double.infinity, 250),
        );
      },
    );
  }
}

class WaterBackgroundPainter extends CustomPainter {
  final double animationValue;
  final math.Random random = math.Random(12);
  WaterBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..style = PaintingStyle.fill;

    // Draw floating water droplets
    for (int i = 0; i < 18; i++) {
      double x = (random.nextDouble() * size.width);
      double startY = size.height + 20;
      double endY = -20;
      double progress = (animationValue + i / 18) % 1.0;
      double currentY = startY - (startY - endY) * progress;
      double currentX = x + math.sin(progress * math.pi * 2) * 15;
      double radius = (i % 3 + 1) * 3.5;

      canvas.drawCircle(Offset(currentX, currentY), radius, paint);
    }

    // Draw soft wave lines
    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    Path wavePath = Path();
    wavePath.moveTo(0, size.height * 0.7);
    for (double x = 0; x <= size.width; x += 10) {
      double y = size.height * 0.7 + math.sin((x / size.width * 4 * math.pi) + (animationValue * 2 * math.pi)) * 8;
      wavePath.lineTo(x, y);
    }
    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


// 2. Oils Background (Golden Shimmer Droplets & Warm Glow)
class AnimatedOilsBackground extends StatefulWidget {
  const AnimatedOilsBackground({super.key});
  @override
  State<AnimatedOilsBackground> createState() => _AnimatedOilsBackgroundState();
}

class _AnimatedOilsBackgroundState extends State<AnimatedOilsBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: OilsBackgroundPainter(_controller.value),
          size: const Size(double.infinity, 250),
        );
      },
    );
  }
}

class OilsBackgroundPainter extends CustomPainter {
  final double animationValue;
  final math.Random random = math.Random(7);
  OilsBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final goldPaint = Paint()
      ..color = const Color(0xFFFFF176).withOpacity(0.25)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 15; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      double scale = 0.6 + 0.4 * math.sin((animationValue * math.pi * 2) + i);
      double radius = (random.nextDouble() * 12 + 6) * scale;

      canvas.drawCircle(Offset(x, y), radius, goldPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


// 3. All Background (Fizzy Rising Bubbles & Ice Sparkles)
class AnimatedAllBackground extends StatefulWidget {
  const AnimatedAllBackground({super.key});
  @override
  State<AnimatedAllBackground> createState() => _AnimatedAllBackgroundState();
}

class _AnimatedAllBackgroundState extends State<AnimatedAllBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: AllBackgroundPainter(_controller.value),
          size: const Size(double.infinity, 250),
        );
      },
    );
  }
}

class AllBackgroundPainter extends CustomPainter {
  final double animationValue;
  final math.Random random = math.Random(88);
  AllBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final bubblePaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 22; i++) {
      double x = random.nextDouble() * size.width;
      double startY = size.height;
      double endY = 0;
      double progress = (animationValue + i / 22) % 1.0;
      double currentY = startY - (startY - endY) * progress;
      double currentX = x + math.cos(progress * math.pi * 4) * 8;
      double radius = random.nextDouble() * 5 + 3;

      if (i % 2 == 0) {
        canvas.drawCircle(Offset(currentX, currentY), radius, bubblePaint);
      } else {
        canvas.drawCircle(Offset(currentX, currentY), radius * 0.7, fillPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


// 4. Dairy Background (Soft Milk Drops & Gentle White Clouds)
class AnimatedDairyBackground extends StatefulWidget {
  const AnimatedDairyBackground({super.key});
  @override
  State<AnimatedDairyBackground> createState() => _AnimatedDairyBackgroundState();
}

class _AnimatedDairyBackgroundState extends State<AnimatedDairyBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: DairyBackgroundPainter(_controller.value),
          size: const Size(double.infinity, 250),
        );
      },
    );
  }
}

class DairyBackgroundPainter extends CustomPainter {
  final double animationValue;
  final math.Random random = math.Random(42);
  DairyBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..color = const Color(0xFF0083B0).withOpacity(0.08)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 10; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      double radius = (random.nextDouble() * 25 + 15) * (0.8 + 0.2 * math.sin(animationValue * math.pi * 2));

      canvas.drawCircle(Offset(x, y), radius, cloudPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


// 5. Grocery Background (Fresh Harvest Leaves & Particles)
class AnimatedGroceryBackground extends StatefulWidget {
  const AnimatedGroceryBackground({super.key});
  @override
  State<AnimatedGroceryBackground> createState() => _AnimatedGroceryBackgroundState();
}

class _AnimatedGroceryBackgroundState extends State<AnimatedGroceryBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: GroceryBackgroundPainter(_controller.value),
          size: const Size(double.infinity, 250),
        );
      },
    );
  }
}

class GroceryBackgroundPainter extends CustomPainter {
  final double animationValue;
  final math.Random random = math.Random(99);
  GroceryBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final leafPaint = Paint()
      ..color = Colors.lightGreenAccent.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 14; i++) {
      double startX = random.nextDouble() * size.width;
      double progress = (animationValue + i / 14) % 1.0;
      double currentY = progress * (size.height + 40) - 20;
      double currentX = startX + math.sin(progress * math.pi * 3) * 20;
      double rotation = progress * math.pi * 2;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(rotation);

      Path leaf = Path();
      leaf.moveTo(0, -8);
      leaf.quadraticBezierTo(8, 0, 0, 8);
      leaf.quadraticBezierTo(-8, 0, 0, -8);
      canvas.drawPath(leaf, leafPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


// Scalloped / Curved Divider Painter
class ScallopedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, 30);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, 45);
    path.quadraticBezierTo(size.width * 0.75, 0, size.width, 30);

    final paint1 = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, paint1);

    final path2 = Path();
    path2.moveTo(0, 34);
    path2.quadraticBezierTo(size.width * 0.25, 4, size.width * 0.5, 49);
    path2.quadraticBezierTo(size.width * 0.75, 4, size.width, 34);

    final paint2 = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


// Auto-scroll Nilara Carousel
class AutoScrollDiwaliCarousel extends StatefulWidget {
  const AutoScrollDiwaliCarousel({Key? key}) : super(key: key);

  @override
  State<AutoScrollDiwaliCarousel> createState() => _AutoScrollDiwaliCarouselState();
}

class _AutoScrollDiwaliCarouselState extends State<AutoScrollDiwaliCarousel> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;

  final List<Map<String, String>> items = [
    {"title": "Nilara 20L Can", "image": 'assets/images/qb1.png'},
    {"title": "Kachi Ghani Oil", "image": 'assets/images/qb2.jpg'},
    {"title": "Chilled Beverage", "image": 'assets/images/soda.png'},
    {"title": "Farm Milk 1L", "image": 'assets/images/milk.png'},
    {"title": "Basmati Rice 5kg", "image": 'assets/images/pcard3.webp'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _animationController.addListener(() {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _animationController.value * maxScroll;
        _scrollController.jumpTo(currentScroll);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: items.length * 3,
        itemBuilder: (context, index) {
          final item = items[index % items.length];
          return Container(
            width: 110,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    item["image"]!,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: Colors.blue.shade50,
                      child: const Icon(Icons.local_drink, color: Colors.blue, size: 40),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.85),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item["title"]!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
