import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'upload_design_screen.dart';

class ChooseBottleTypeScreen extends StatefulWidget {
  const ChooseBottleTypeScreen({super.key});

  @override
  State<ChooseBottleTypeScreen> createState() => _ChooseBottleTypeScreenState();
}

class _ChooseBottleTypeScreenState extends State<ChooseBottleTypeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 1; // Default to 500ml

  late AnimationController _heroAnimController;
  late Animation<double> _heroAnimation;

  final List<Map<String, dynamic>> _bottleTypes = [
    {
      "title": "250 ml Bottle",
      "packSize": "100 Bottles",
      "price": "₹349",
      "image": "assets/images/Nilara 250ml botle.png",
      "isPopular": false,
      "features": [
        "Perfect for Quick Refreshment",
        "Easy to Carry",
        "Compact Label Design",
        "Ideal for Large Gatherings"
      ],
      "labelArea": "Small (10x5 cm)"
    },
    {
      "title": "500 ml Bottle",
      "packSize": "100 Bottles",
      "price": "₹499",
      "image": "assets/images/500 ml.png",
      "isPopular": true,
      "features": [
        "Perfect for Weddings",
        "Easy to Carry",
        "Premium Label Finish",
        "Most Ordered",
        "Great for Events"
      ],
      "labelArea": "Medium (15x7 cm)"
    },
    {
      "title": "1 Litre Bottle",
      "packSize": "50 Bottles",
      "price": "₹549",
      "image": "assets/images/1L.png",
      "isPopular": false,
      "features": [
        "Great for Dining",
        "Large Label Space",
        "Sturdy Build",
        "Premium Look"
      ],
      "labelArea": "Large (20x10 cm)"
    },
    {
      "title": "2 Litre Bottle",
      "packSize": "25 Bottles",
      "price": "₹599",
      "image": "assets/images/2L.png",
      "isPopular": false,
      "features": [
        "Family Size",
        "Maximum Hydration",
        "Extra Large Label Area"
      ],
      "labelArea": "Extra Large (25x12 cm)"
    },
    {
      "title": "Premium Carton",
      "description": "12 Bottles\nAvailable in 250ml, 500ml, 1L",
      "price": "Starts from ₹1499",
      "image": "assets/images/bulk_carton_splash.png",
      "isPopular": false,
      "features": [
        "Bulk Storage",
        "Custom Box Branding",
        "Safe Transportation"
      ],
      "labelArea": "Box Wrap (30x20 cm)"
    },
    {
      "title": "20 Litre Jar",
      "description": "Ideal for Office, Hotel, Home, Corporate",
      "price": "₹199",
      "image": "assets/images/20L daily bulk .png",
      "isPopular": false,
      "features": [
        "Long Lasting",
        "Office Favorite",
        "Custom Jar Wrap"
      ],
      "labelArea": "Jar Wrap (40x25 cm)"
    },
  ];

  @override
  void initState() {
    super.initState();
    _heroAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _heroAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _heroAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _heroAnimController.dispose();
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
        title: Column(
          children: [
            Text(
              "Choose Bottle Type",
              style: GoogleFonts.outfit(
                color: const Color(0xFF1E3A8A),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Text(
              "Select the bottle you want to customize",
              style: GoogleFonts.outfit(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 140), // Space for live preview strip
              child: Column(
                children: [
                  _buildHeroCard(),
                  const SizedBox(height: 24),
                  _buildBottleOptions(),
                  const SizedBox(height: 24),
                  _buildComparisonSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildLivePreviewAndCTA(),
    );
  }

  Widget _buildProgressIndicator() {
    final steps = ["Design", "Bottle", "Customize", "Quantity", "Payment"];
    final currentStep = 1; // Bottle

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index % 2 != 0) {
            return Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey.shade400);
          }
          final stepIndex = index ~/ 2;
          final isCurrent = stepIndex == currentStep;
          final isCompleted = stepIndex < currentStep;

          return Row(
            children: [
              if (isCompleted) ...[
                const Icon(Icons.check_circle, size: 14, color: Color(0xFF3B82F6)),
                const SizedBox(width: 4),
              ],
              Text(
                steps[stepIndex],
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: isCurrent || isCompleted ? FontWeight.bold : FontWeight.w500,
                  color: isCurrent 
                      ? const Color(0xFF1E3A8A) 
                      : (isCompleted ? const Color(0xFF3B82F6) : Colors.grey.shade400),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Left Text Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Choose Your\nBottle",
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E3A8A),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Select the perfect\nbottle for your event.",
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            // Right Floating Bottle
            Positioned(
              right: 20,
              bottom: -10, // Let it slightly peek out
              top: 10,
              child: AnimatedBuilder(
                animation: _heroAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -_heroAnimation.value),
                    child: child,
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF3B82F6).withOpacity(0.05),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.1),
                            blurRadius: 30,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/images/500 ml.png', // Main hero bottle
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottleOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: List.generate(_bottleTypes.length, (index) {
          final item = _bottleTypes[index];
          final isSelected = _selectedIndex == index;

          return AnimatedScale(
            scale: isSelected ? 1.02 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.03) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected 
                          ? const Color(0xFF3B82F6).withOpacity(0.15) 
                          : Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Bottle Image
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isSelected)
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3B82F6).withOpacity(0.2),
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        Container(
                          width: 70,
                          height: 90,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.asset(
                            item["image"],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.water_drop, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item["title"],
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1E3A8A),
                                ),
                              ),
                              if (item["isPopular"]) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "Most Popular",
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (item.containsKey("packSize")) ...[
                            Text(
                              "Pack Size",
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              item["packSize"],
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: const Color(0xFF334155),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ] else if (item.containsKey("description")) ...[
                            Text(
                              item["description"],
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: const Color(0xFF334155),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            item["price"],
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Animated Radio
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade300,
                          width: isSelected ? 0 : 2,
                        ),
                        color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ] : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildComparisonSection() {
    final currentItem = _bottleTypes[_selectedIndex];
    final features = currentItem["features"] as List<String>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.blue.shade50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Why choose this bottle?",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 16),
            ...features.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 14, color: Color(0xFF3B82F6)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePreviewAndCTA() {
    final currentItem = _bottleTypes[_selectedIndex];
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Live Preview Strip
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFBFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Image.asset(
                        currentItem["image"],
                        key: ValueKey(currentItem["image"]),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Selected Product",
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            "${currentItem["title"]} • ${currentItem.containsKey('packSize') ? currentItem['packSize'] : 'Pack of 1'}",
                            key: ValueKey(currentItem["title"]),
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E3A8A),
                            ),
                          ),
                        ),
                        Text(
                          "Estimated Label: ${currentItem["labelArea"]}",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: const Color(0xFF3B82F6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UploadDesignScreen(
                          bottleType: currentItem["title"],
                          bottleImage: currentItem["image"],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6), // Bright blue
                    foregroundColor: Colors.white,
                    elevation: 10,
                    shadowColor: const Color(0xFF3B82F6).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Continue",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
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
