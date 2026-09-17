import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'choose_bottle_type_screen.dart';

class CustomizeBottleScreen extends StatefulWidget {
  const CustomizeBottleScreen({super.key});

  @override
  State<CustomizeBottleScreen> createState() => _CustomizeBottleScreenState();
}

class _CustomizeBottleScreenState extends State<CustomizeBottleScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bottleAnimController;
  late Animation<double> _bottleAnimation;

  @override
  void initState() {
    super.initState();
    _bottleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _bottleAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _bottleAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bottleAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E3A8A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Customize Bottle",
          style: GoogleFonts.outfit(
            color: const Color(0xFF1E3A8A),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Color(0xFF3B82F6), size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background soft particles/gradients could go here
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // Space for CTA
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(),
                const SizedBox(height: 32),
                _buildSectionTitle("Choose Occasion"),
                const SizedBox(height: 16),
                _buildOccasionGrid(),
                const SizedBox(height: 16),
                _buildCustomDesignCard(),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle("Recent Designs"),
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Text(
                        "View all >",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF3B82F6),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRecentDesignsCarousel(),
              ],
            ),
          ),
          
          // Bottom CTA
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -10),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChooseBottleTypeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Continue",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 220,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Make Your Event",
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E3A8A),
                        height: 1.2,
                      ),
                    ),
                    Text(
                      "Memorable",
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF3B82F6),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Create your own premium water\nbottle design.",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(flex: 2, child: SizedBox()), // Space for bottle
            ],
          ),
          
          // Animated Bottle
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _bottleAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_bottleAnimation.value),
                  child: child,
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Soft glow behind bottle
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.15),
                          blurRadius: 40,
                          spreadRadius: 20,
                        )
                      ],
                    ),
                  ),
                  // Bottle image mockup
                  Image.asset(
                    'assets/images/500 ml.png',
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                  // Placeholder text on bottle
                  Positioned(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "YOUR\nDESIGN\nHERE",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E3A8A),
        ),
      ),
    );
  }

  Widget _buildOccasionGrid() {
    final occasions = [
      {"icon": Icons.volunteer_activism, "title": "Wedding", "color": Colors.orange},
      {"icon": Icons.cake, "title": "Birthday", "color": Colors.red},
      {"icon": Icons.business_center, "title": "Corporate", "color": Colors.blue},
      {"icon": Icons.hotel, "title": "Hotel", "color": Colors.blue.shade700},
      {"icon": Icons.restaurant, "title": "Restaurant", "color": Colors.blue.shade800},
      {"icon": Icons.school, "title": "School", "color": Colors.blue.shade900},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.9,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: occasions.length,
        itemBuilder: (context, index) {
          final item = occasions[index];
          return _buildOccasionCard(
            icon: item["icon"] as IconData,
            title: item["title"] as String,
            color: item["color"] as Color,
          );
        },
      ),
    );
  }

  Widget _buildOccasionCard({required IconData icon, required String title, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChooseBottleTypeScreen(),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDesignCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChooseBottleTypeScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.note_add_outlined, color: Color(0xFF3B82F6), size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Custom Design",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E3A8A),
                        ),
                      ),
                      Text(
                        "Start from scratch",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentDesignsCarousel() {
    final designs = [
      {"name": "Rahul & Priya", "image": "assets/images/1L.png"},
      {"name": "Aarav's 5th", "image": "assets/images/500 ml.png"},
      {"name": "Nilara Event", "image": "assets/images/1L.png"},
    ];

    return SizedBox(
      height: 140,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: designs.length,
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/bulk_carton_splash.png',
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.2),
                    ),
                  ),
                  Image.asset(
                    designs[index]["image"]!,
                    height: 100,
                    fit: BoxFit.contain,
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
