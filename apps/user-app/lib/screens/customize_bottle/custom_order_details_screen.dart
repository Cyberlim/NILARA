import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bulk_orders/bulk_delivery_details_screen.dart';
import '../../services/settings_service.dart';

class CustomOrderDetailsScreen extends StatefulWidget {
  final String bottleType;
  final Map<String, dynamic> designData;

  const CustomOrderDetailsScreen({
    super.key,
    required this.bottleType,
    required this.designData,
  });

  @override
  State<CustomOrderDetailsScreen> createState() => _CustomOrderDetailsScreenState();
}

class _CustomOrderDetailsScreenState extends State<CustomOrderDetailsScreen> {
  final TextEditingController _instructionsController = TextEditingController();

  String _deliveryTime = "Morning";
  String _selectedQuantity = "500";
  String _capColor = "Blue";
  String _labelFinish = "Matte";
  String _printingType = "Front Only";

  final List<Map<String, dynamic>> _uploadedFiles = [
    {"name": "wedding_invite.pdf", "size": "1.2 MB"},
  ];

  List<String> _quantities = ["100", "250", "500", "1000", "2000+"];
  
  final List<Map<String, dynamic>> _capColors = [
    {"name": "White", "color": Colors.white},
    {"name": "Blue", "color": const Color(0xFF1E3A8A)},
    {"name": "Black", "color": const Color(0xFF111827)},
    {"name": "Gold", "color": const Color(0xFFD4AF37)},
    {"name": "Silver", "color": const Color(0xFF94A3B8)},
  ];

  bool _isLoadingSettings = true;
  double _customDesignSurcharge = 10;
  int _customDesignMinOrder = 100;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    final settings = await SettingsService().fetchSettings();
    if (settings != null) {
      if (mounted) {
        setState(() {
          _customDesignSurcharge = (settings['customDesignSurcharge'] ?? 10).toDouble();
          _customDesignMinOrder = settings['customDesignMinOrder'] ?? 100;
          _selectedQuantity = _customDesignMinOrder.toString();
          
          // Generate quantities based on min order
          _quantities = [
            _customDesignMinOrder.toString(),
            (_customDesignMinOrder * 2).toString(),
            (_customDesignMinOrder * 5).toString(),
            (_customDesignMinOrder * 10).toString(),
            "${_customDesignMinOrder * 20}+"
          ];
          _isLoadingSettings = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingSettings = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _instructionsController.dispose();
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
              "Custom Order Details",
              style: GoogleFonts.outfit(
                color: const Color(0xFF1E3A8A),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Text(
              "Help us understand your printing requirements",
              style: GoogleFonts.outfit(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
                fontSize: 11,
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
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  if (_isLoadingSettings)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    _buildQuantitySection(),
                    const SizedBox(height: 24),
                    _buildCapColorSection(),
                    const SizedBox(height: 24),
                    _buildLabelFinishSection(),
                    const SizedBox(height: 24),
                    _buildPrintingTypeSection(),
                    const SizedBox(height: 24),
                    _buildUploadReferences(),
                    const SizedBox(height: 24),
                    _buildSpecialInstructions(),
                    const SizedBox(height: 24),
                    _buildApprovalNotice(),
                  ],
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
    final steps = ["Occasion", "Bottle", "Upload", "Details", "Preview", "Payment"];
    final currentStep = 3; // Details

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



  Widget _buildQuantitySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quantity",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _quantities.map((q) {
              final isSelected = _selectedQuantity == q;
              return GestureDetector(
                onTap: () => setState(() => _selectedQuantity = q),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade300),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ] : null,
                  ),
                  child: Text(
                    q,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedQuantity == "2000+") ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Need a larger quantity? Our sales team will assist you.",
                      style: GoogleFonts.outfit(fontSize: 13, color: Colors.orange.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildCapColorSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bottle Cap Color",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _capColors.map((cap) {
              final isSelected = _capColor == cap["name"];
              return GestureDetector(
                onTap: () => setState(() => _capColor = cap["name"]),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: cap["color"],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: cap["color"] == Colors.white ? Colors.grey.shade300 : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (cap["color"] as Color).withOpacity(0.3),
                              blurRadius: isSelected ? 12 : 4,
                              spreadRadius: isSelected ? 2 : 0,
                            )
                          ],
                        ),
                        child: isSelected 
                            ? Icon(Icons.check, color: cap["name"] == "White" ? Colors.black : Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cap["name"],
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
        ],
      ),
    );
  }

  Widget _buildLabelFinishSection() {
    return _buildSegmentedSection(
      title: "Label Finish",
      options: ["Matte", "Glossy", "Waterproof"],
      selectedValue: _labelFinish,
      onSelect: (val) => setState(() => _labelFinish = val),
    );
  }

  Widget _buildPrintingTypeSection() {
    return _buildSegmentedSection(
      title: "Printing Type",
      options: ["Front Label Only", "Front & Back Label", "Neck Label Included"],
      selectedValue: _printingType,
      onSelect: (val) => setState(() => _printingType = val),
    );
  }

  Widget _buildSegmentedSection({
    required String title,
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onSelect,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: options.map((opt) {
                final isSelected = selectedValue == opt;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onSelect(opt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ] : null,
                      ),
                      child: Text(
                        opt,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade600,
                        ),
                      ),
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

  Widget _buildUploadReferences() {
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
              "Upload References (Optional)",
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "e.g. Invitation Card, Company Logo, Reference Image",
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 16),
            
            // Uploaded Files
            ..._uploadedFiles.map((file) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description, color: Color(0xFF3B82F6)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file["name"],
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          file["size"],
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 12),
                  const Icon(Icons.close, size: 18, color: Colors.red),
                ],
              ),
            )).toList(),
            
            // Upload Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3), style: BorderStyle.solid), // Dashed in real impl
              ),
              child: Column(
                children: [
                  const Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF3B82F6)),
                  const SizedBox(height: 8),
                  Text(
                    "Tap to upload more references",
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialInstructions() {
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
              "Special Instructions",
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _instructionsController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Example:\n• Place logo in the center.\n• Use gold text.\n• Add QR code on the back.",
                hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalNotice() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.design_services, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Design Approval Process",
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Our professional design team will create a high-quality bottle label using your uploaded artwork and order details. Before printing begins, you will receive a digital mockup for approval.",
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: const Color(0xFF1E293B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
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
              int qty = int.tryParse(_selectedQuantity.replaceAll('+', '')) ?? _customDesignMinOrder;
              
              // Base price can be assumed for bottle types. 
              // 500ml -> 499 per 100 = ~5 per bottle. Let's just use 5 + surcharge.
              double pricePerBottle = 5.0 + _customDesignSurcharge;
              double totalPrice = qty * pricePerBottle;

              final fullCustomDesignData = {
                ...widget.designData,
                'bottleType': widget.bottleType,
                'capColor': _capColor,
                'labelFinish': _labelFinish,
                'printingType': _printingType,
                'specialInstructions': _instructionsController.text,
                'isCustom': true,
              };

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BulkDeliveryDetailsScreen(
                    productName: "Custom Design - ${widget.bottleType}",
                    quantity: qty,
                    totalPrice: totalPrice,
                    customDesign: fullCustomDesignData,
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
                  "Continue to Checkout",
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
