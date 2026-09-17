import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_order_details_screen.dart';
import 'dart:math' as math;

class UploadDesignScreen extends StatefulWidget {
  final String bottleType;
  final String bottleImage;

  const UploadDesignScreen({
    super.key,
    required this.bottleType,
    required this.bottleImage,
  });

  @override
  State<UploadDesignScreen> createState() => _UploadDesignScreenState();
}

class _UploadDesignScreenState extends State<UploadDesignScreen> with TickerProviderStateMixin {
  late AnimationController _heroAnimController;
  late Animation<double> _heroAnimation;
  
  bool _isUploaded = false;
  String _selectedTheme = "White";
  double _bottleRotation = 0.0;
  double _bottleZoom = 1.0;
  
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _taglineController = TextEditingController();

  final List<Map<String, dynamic>> _colorThemes = [
    {"name": "White", "color": Colors.white},
    {"name": "Blue", "color": const Color(0xFF1E3A8A)},
    {"name": "Gold", "color": const Color(0xFFD4AF37)},
    {"name": "Black", "color": const Color(0xFF111827)},
    {"name": "Green", "color": const Color(0xFF166534)},
    {"name": "Silver", "color": const Color(0xFF94A3B8)},
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
    _eventNameController.dispose();
    _eventDateController.dispose();
    _taglineController.dispose();
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
              "Upload Your Design",
              style: GoogleFonts.outfit(
                color: const Color(0xFF1E3A8A),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Text(
              "Customize your ${widget.bottleType}",
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
              padding: const EdgeInsets.only(bottom: 120), // For bottom CTA
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCard(),
                  const SizedBox(height: 24),
                  _buildUploadCard(),
                  if (!_isUploaded) _buildSupportedFormats(),
                  const SizedBox(height: 24),
                  _buildAdditionalUploads(),
                  const SizedBox(height: 24),
                  _buildEventInformation(),
                  const SizedBox(height: 24),
                  _buildColorSelection(),
                  const SizedBox(height: 24),
                  _buildLivePreview(),
                  const SizedBox(height: 24),
                  _buildDesignGuidelines(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomCTA(),
    );
  }

  Widget _buildProgressIndicator() {
    final steps = ["Occasion", "Bottle", "Upload Design", "Customize", "Quantity", "Payment"];
    final currentStep = 2; // Upload Design

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(steps.length * 2 - 1, (index) {
            if (index % 2 != 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.arrow_forward_ios, size: 8, color: Colors.grey.shade300),
              );
            }
            final stepIndex = index ~/ 2;
            final isCurrent = stepIndex == currentStep;
            final isCompleted = stepIndex < currentStep;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCompleted) ...[
                  const Icon(Icons.check_circle, size: 14, color: Color(0xFF3B82F6)),
                  const SizedBox(width: 4),
                ],
                if (isCurrent) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                  ),
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
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Upload Your\nArtwork",
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E3A8A),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: Text(
                      "Upload your logo, wedding artwork, business branding or custom label design.",
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Positioned(
              right: 20,
              bottom: 10,
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
                      widget.bottleImage,
                      height: 130,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.water_drop, color: Colors.blue),
                    ),
                    Positioned(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          "BLANK\nLABEL",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey.shade400,
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
      ),
    );
  }

  Widget _buildUploadCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isUploaded 
            ? _buildSuccessFileCard() 
            : _buildDragAndDropArea(),
      ),
    );
  }

  Widget _buildDragAndDropArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3), width: 2, style: BorderStyle.solid), // Should ideally be dashed, using solid for simplicity
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_upload_outlined, size: 48, color: Color(0xFF3B82F6)),
          ),
          const SizedBox(height: 16),
          Text(
            "Drag & Drop your artwork here",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "or",
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Simulate upload
              setState(() {
                _isUploaded = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Browse Files",
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessFileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.green.shade100, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image, color: Color(0xFF3B82F6), size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "wedding_monogram.png",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "2.4 MB",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          "Upload Success",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade100),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text("Preview"),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isUploaded = false;
                  });
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Replace"),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isUploaded = false;
                  });
                },
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                label: const Text("Remove", style: TextStyle(color: Colors.red)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSupportedFormats() {
    final formats = ["PNG", "JPG", "JPEG", "PDF", "SVG", "AI", "EPS"];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Supported Formats",
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                "Max Size: 50 MB",
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: formats.map((f) => Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  f,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
              )).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAdditionalUploads() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_photo_alternate, color: Colors.purple),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Upload Logo (Optional)",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    "Brand Logo, School Logo, etc.",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildEventInformation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Event Information",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 16),
            _buildInputField(
              label: "Event Name",
              hint: "e.g. Harshit & Samiksha Wedding",
              controller: _eventNameController,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              label: "Event Date",
              hint: "Select Date",
              icon: Icons.calendar_today,
              controller: _eventDateController,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              label: "Tagline (Optional)",
              hint: "e.g. Pure Water • Made Special For You",
              controller: _taglineController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, required String hint, IconData? icon, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 14),
            suffixIcon: icon != null ? Icon(icon, color: Colors.grey.shade400, size: 20) : null,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Choose Label Theme",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _colorThemes.map((theme) {
                final isSelected = _selectedTheme == theme["name"];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTheme = theme["name"];
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme["color"],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme["color"] == Colors.white ? Colors.grey.shade300 : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (theme["color"] as Color).withOpacity(0.3),
                                blurRadius: isSelected ? 12 : 4,
                                spreadRadius: isSelected ? 2 : 0,
                              )
                            ],
                          ),
                          child: isSelected 
                              ? Icon(Icons.check, color: theme["name"] == "White" ? Colors.black : Colors.white)
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          theme["name"],
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivePreview() {
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
          children: [
            Text(
              "Live Bottle Preview",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 24),
            // Simulated 3D Bottle
            SizedBox(
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFAFBFF),
                      boxShadow: [
                        BoxShadow(
                          color: _colorThemes.firstWhere((t) => t["name"] == _selectedTheme)["color"].withOpacity(0.1),
                          blurRadius: 40,
                          spreadRadius: 10,
                        )
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    transform: Matrix4.identity()
                      ..scale(_bottleZoom)
                      ..rotateY(_bottleRotation),
                    transformAlignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          widget.bottleImage,
                          height: 220,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.water_drop, size: 100, color: Colors.blue),
                        ),
                        if (_isUploaded)
                          Positioned(
                            child: Container(
                              width: 60,
                              height: 80,
                              decoration: BoxDecoration(
                                color: _colorThemes.firstWhere((t) => t["name"] == _selectedTheme)["color"],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white.withOpacity(0.5)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                  )
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.image, 
                                  color: _selectedTheme == "White" ? Colors.blue.shade200 : Colors.white.withOpacity(0.5),
                                  size: 30,
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(Icons.rotate_left, "Left", () {
                  setState(() { _bottleRotation -= math.pi / 4; });
                }),
                const SizedBox(width: 12),
                _buildControlButton(Icons.rotate_right, "Right", () {
                  setState(() { _bottleRotation += math.pi / 4; });
                }),
                const SizedBox(width: 12),
                _buildControlButton(Icons.zoom_in, "Zoom In", () {
                  setState(() { _bottleZoom = math.min(_bottleZoom + 0.2, 2.0); });
                }),
                const SizedBox(width: 12),
                _buildControlButton(Icons.zoom_out, "Zoom Out", () {
                  setState(() { _bottleZoom = math.max(_bottleZoom - 0.2, 0.5); });
                }),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  _bottleRotation = 0.0;
                  _bottleZoom = 1.0;
                });
              },
              child: Text(
                "Reset View",
                style: GoogleFonts.outfit(color: Colors.grey.shade500),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF1E3A8A)),
      ),
    );
  }

  Widget _buildDesignGuidelines() {
    final guidelines = [
      "Upload high-resolution artwork",
      "Transparent PNG recommended",
      "Minimum 300 DPI",
      "Avoid very small text",
      "Keep important content inside safe area"
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A8A),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  "Best Printing Results",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...guidelines.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  const Icon(Icons.check, color: Color(0xFF60A5FA), size: 16),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      g,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.blue.shade50,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCTA() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
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
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomOrderDetailsScreen(
                    bottleType: widget.bottleType,
                    designData: {
                      'eventName': _eventNameController.text,
                      'eventDate': _eventDateController.text,
                      'tagline': _taglineController.text,
                      'theme': _selectedTheme,
                      'isUploaded': _isUploaded,
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
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
      ),
    );
  }
}
