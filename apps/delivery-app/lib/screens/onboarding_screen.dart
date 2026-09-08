import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../services/user_service.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _kycFormKey = GlobalKey<FormState>();
  final _bankFormKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  int _currentStep = 0; // 0 = KYC & Vehicle, 1 = Bank & Payouts

  // Step 1: Vehicle & KYC
  String _vehicleType = 'Bike';
  final TextEditingController _vehicleNumberController = TextEditingController();
  final TextEditingController _aadharNumberController = TextEditingController();
  final TextEditingController _drivingLicenseController = TextEditingController();

  XFile? _aadharImage;
  XFile? _drivingLicenseImage;
  XFile? _vehicleFrontImage;
  XFile? _vehicleBackImage;
  XFile? _profileImage;
  XFile? _rcImage;

  // Step 2: Bank & Payout Details
  final TextEditingController _accountHolderController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _upiController = TextEditingController();
  String _accountType = 'Savings Account';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = UserService().currentUser.value;
    if (user != null && user.name.isNotEmpty) {
      _accountHolderController.text = user.name;
    }

    // Real-time preview listeners for the hero bank card
    _bankNameController.addListener(() => setState(() {}));
    _accountNumberController.addListener(() => setState(() {}));
    _upiController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _vehicleNumberController.dispose();
    _aadharNumberController.dispose();
    _drivingLicenseController.dispose();
    _accountHolderController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(int type) async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          switch (type) {
            case 1:
              _aadharImage = pickedFile;
              break;
            case 2:
              _drivingLicenseImage = pickedFile;
              break;
            case 3:
              _vehicleFrontImage = pickedFile;
              break;
            case 4:
              _vehicleBackImage = pickedFile;
              break;
            case 5:
              _profileImage = pickedFile;
              break;
            case 6:
              _rcImage = pickedFile;
              break;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error picking image: $e")),
        );
      }
    }
  }

  void _goToBankStep() {
    if (!_kycFormKey.currentState!.validate()) return;

    if (_profileImage == null) {
      _showWarning('Please upload your profile photo.');
      return;
    }
    if (_vehicleType != 'Cycle' && _rcImage == null) {
      _showWarning('Please upload Registration Certificate (RC) photo.');
      return;
    }
    if (_vehicleFrontImage == null || _vehicleBackImage == null) {
      _showWarning('Please upload vehicle front and back photos.');
      return;
    }
    if (_aadharImage == null) {
      _showWarning('Please upload Aadhar card photo.');
      return;
    }
    if (_drivingLicenseImage == null) {
      _showWarning('Please upload Driving License photo.');
      return;
    }

    setState(() {
      _currentStep = 1;
    });

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getMaskedAccountNumber(String full) {
    if (full.isEmpty) return "•••• •••• •••• ••••";
    if (full.length <= 4) return full;
    final lastFour = full.substring(full.length - 4);
    return "•••• •••• •••• $lastFour";
  }

  Future<void> _submitOnboarding() async {
    if (!_bankFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final token = UserService().token.value;
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:5000/api/v1/delivery/onboarding'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Step 1 fields
      request.fields['vehicleType'] = _vehicleType;
      request.fields['vehicleNumber'] = _vehicleNumberController.text.trim().toUpperCase();
      request.fields['aadharNumber'] = _aadharNumberController.text.trim();
      request.fields['drivingLicenseNumber'] = _drivingLicenseController.text.trim().toUpperCase();

      // Step 2 fields
      request.fields['accountHolderName'] = _accountHolderController.text.trim();
      request.fields['bankName'] = _bankNameController.text.trim();
      request.fields['accountNumber'] = _accountNumberController.text.trim();
      request.fields['ifscCode'] = _ifscController.text.trim().toUpperCase();
      request.fields['accountType'] = _accountType;
      request.fields['upiId'] = _upiController.text.trim().toLowerCase();

      // Files
      request.files.add(http.MultipartFile.fromBytes('aadharImage', await _aadharImage!.readAsBytes(), filename: _aadharImage!.name));
      request.files.add(http.MultipartFile.fromBytes('drivingLicenseImage', await _drivingLicenseImage!.readAsBytes(), filename: _drivingLicenseImage!.name));
      request.files.add(http.MultipartFile.fromBytes('vehicleFrontImage', await _vehicleFrontImage!.readAsBytes(), filename: _vehicleFrontImage!.name));
      request.files.add(http.MultipartFile.fromBytes('vehicleBackImage', await _vehicleBackImage!.readAsBytes(), filename: _vehicleBackImage!.name));
      request.files.add(http.MultipartFile.fromBytes('profileImage', await _profileImage!.readAsBytes(), filename: _profileImage!.name));
      if (_rcImage != null) {
        request.files.add(http.MultipartFile.fromBytes('rcImage', await _rcImage!.readAsBytes(), filename: _rcImage!.name));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Update local state and reload profile with newly saved bank details
        final user = UserService().currentUser.value;
        if (user != null) {
          user.onboardingComplete = true;
        }
        await UserService().refreshProfile();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('KYC & Bank details submitted successfully!', style: GoogleFonts.outfit(color: Colors.white)),
              backgroundColor: const Color(0xFF1E9C1C),
              behavior: SnackBarBehavior.floating,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit details. Please check all fields.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 8, bottom: 8),
          child: Container(
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () {
                if (_currentStep == 1) {
                  setState(() => _currentStep = 0);
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(0);
                  }
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentStep == 0 ? "Complete KYC" : "Bank & Payout Details",
              style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              _currentStep == 0
                  ? "Step 1 of 2: Identity & Vehicle Verification"
                  : "Step 2 of 2: Payout & Settlement Setup",
              style: GoogleFonts.outfit(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
              child: Icon(
                _currentStep == 0 ? Icons.verified_user : Icons.account_balance,
                color: const Color(0xFF1E9C1C),
                size: 24,
              ),
            ),
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF1E9C1C)),
                  const SizedBox(height: 16),
                  Text(
                    "Submitting KYC & Bank Details...",
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step Indicator Bar
                  _buildStepIndicator(),
                  const SizedBox(height: 20),

                  // Step 1: KYC & Vehicle Form
                  if (_currentStep == 0) _buildKycStep(),

                  // Step 2: Bank & Payout Details Form
                  if (_currentStep == 1) _buildBankStep(),
                ],
              ),
            ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildStepPill(
                stepIndex: 0,
                title: "1. Identity & Vehicle",
                isActive: _currentStep == 0,
                isDone: _currentStep > 0,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: _currentStep > 0 ? const Color(0xFF1E9C1C) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildStepPill(
                stepIndex: 1,
                title: "2. Bank & Payouts",
                isActive: _currentStep == 1,
                isDone: false,
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: _currentStep == 0 ? 0.5 : 1.0,
            backgroundColor: Colors.grey.shade100,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E9C1C)),
            minHeight: 4,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildStepPill({
    required int stepIndex,
    required String title,
    required bool isActive,
    required bool isDone,
  }) {
    return InkWell(
      onTap: () {
        if (stepIndex == 0 && _currentStep == 1) {
          setState(() => _currentStep = 0);
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isDone
                  ? const Color(0xFF1E9C1C)
                  : (isActive ? const Color(0xFF1E9C1C) : Colors.grey.shade200),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(
                      "${stepIndex + 1}",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive
                  ? const Color(0xFF1E9C1C)
                  : (isDone ? Colors.black87 : Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycStep() {
    return Form(
      key: _kycFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            icon: Icons.person,
            title: "Your Photo",
            subtitle: "Upload your clear profile photo",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImagePickerRow(
                  title: "Profile Photo",
                  imageFile: _profileImage,
                  onTap: () => _pickImage(5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildSectionCard(
            icon: Icons.directions_car,
            title: "Vehicle Details",
            subtitle: "Provide your vehicle information",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Vehicle Type", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _vehicleType,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                  items: ['Bike', 'Scooter', 'Cycle', 'Auto'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type, style: GoogleFonts.outfit()));
                  }).toList(),
                  onChanged: (val) => setState(() => _vehicleType = val!),
                ),
                const SizedBox(height: 16),

                Text("Vehicle Number", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _vehicleNumberController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Vehicle Number (e.g. DL01AB1234)',
                    hintStyle: GoogleFonts.outfit(color: Colors.black38),
                    prefixIcon: const Icon(Icons.directions_car_outlined, color: Colors.black54),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                Text("Registration Certificate (RC) Image", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                _buildImagePickerRow(
                  title: "Registration Certificate (RC)",
                  imageFile: _rcImage,
                  onTap: () => _pickImage(6),
                ),
                const SizedBox(height: 16),

                Text("Vehicle Front Image", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                _buildImagePickerRow(
                  title: "Vehicle Front Image",
                  imageFile: _vehicleFrontImage,
                  onTap: () => _pickImage(3),
                ),
                const SizedBox(height: 16),

                Text("Vehicle Back Image", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                _buildImagePickerRow(
                  title: "Vehicle Back Image",
                  imageFile: _vehicleBackImage,
                  onTap: () => _pickImage(4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildSectionCard(
            icon: Icons.badge_outlined,
            title: "Identity Verification",
            subtitle: "Verify your identity documents",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Aadhar Number", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _aadharNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Aadhar Number',
                    hintStyle: GoogleFonts.outfit(color: Colors.black38),
                    prefixIcon: const Icon(Icons.badge_outlined, color: Colors.black54),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildImagePickerRow(
                  title: "Aadhar Card Image",
                  imageFile: _aadharImage,
                  onTap: () => _pickImage(1),
                ),
                const SizedBox(height: 24),

                Text("Driving License Number", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _drivingLicenseController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Driving License Number (e.g. DL-1420110012345)',
                    hintStyle: GoogleFonts.outfit(color: Colors.black38),
                    prefixIcon: const Icon(Icons.badge_outlined, color: Colors.black54),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildImagePickerRow(
                  title: "Driving License Image",
                  imageFile: _drivingLicenseImage,
                  onTap: () => _pickImage(2),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _goToBankStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E9C1C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Next: Bank & Payout Details", style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBankStep() {
    final currentBankName = _bankNameController.text.trim();
    final currentAccNum = _accountNumberController.text.trim();
    final currentUpi = _upiController.text.trim();

    return Form(
      key: _bankFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Bank Payout Card Preview
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        color: Color(0xFF4ADE80),
                        size: 26,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E9C1C).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF4ADE80).withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            "Payout Ready",
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF4ADE80),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  currentBankName.isNotEmpty ? currentBankName : "Bank Name",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentAccNum.isNotEmpty
                      ? _getMaskedAccountNumber(currentAccNum)
                      : "•••• •••• •••• ••••",
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "SETTLEMENT CYCLE",
                            style: GoogleFonts.outfit(
                              color: Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Daily Auto (11:59 PM)",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "PRIMARY UPI",
                            style: GoogleFonts.outfit(
                              color: Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentUpi.isNotEmpty ? currentUpi : "Not set",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Primary Bank Account Card
          _buildSectionCard(
            icon: Icons.account_balance,
            title: "Primary Bank Account",
            subtitle: "Enter your bank account to receive earnings",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Account Holder Name", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _accountHolderController,
                  decoration: InputDecoration(
                    hintText: 'Full Name as per Bank Account',
                    hintStyle: GoogleFonts.outfit(color: Colors.black38),
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.black54),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Account holder name is required' : null,
                ),
                const SizedBox(height: 16),

                Text("Bank Name", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bankNameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. State Bank of India, HDFC Bank, ICICI Bank',
                    hintStyle: GoogleFonts.outfit(color: Colors.black38),
                    prefixIcon: const Icon(Icons.account_balance_outlined, color: Colors.black54),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Bank name is required' : null,
                ),
                const SizedBox(height: 16),

                Text("Bank Account Number", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _accountNumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Enter Account Number',
                    hintStyle: GoogleFonts.outfit(color: Colors.black38),
                    prefixIcon: const Icon(Icons.credit_card_outlined, color: Colors.black54),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Account number is required';
                    if (val.trim().length < 8) return 'Enter a valid account number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Text("IFSC Code", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _ifscController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'e.g. HDFC0001234',
                    hintStyle: GoogleFonts.outfit(color: Colors.black38),
                    prefixIcon: const Icon(Icons.qr_code_2_outlined, color: Colors.black54),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'IFSC code is required';
                    if (val.trim().length != 11) return 'IFSC code must be 11 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Text("Account Type", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _accountType,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                  items: ['Savings Account', 'Current Account'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type, style: GoogleFonts.outfit()));
                  }).toList(),
                  onChanged: (val) => setState(() => _accountType = val!),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Instant UPI Transfer Card
          _buildSectionCard(
            icon: Icons.bolt_outlined,
            title: "Instant UPI Transfer",
            subtitle: "Optional instant payout method",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("UPI VPA ID", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _upiController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'e.g. mobile@upi or name@okhdfcbank',
                    hintStyle: GoogleFonts.outfit(color: Colors.black38),
                    prefixIcon: const Icon(Icons.bolt_outlined, color: Colors.black54),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    suffixIcon: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Fast Transfer",
                        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF1E9C1C)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Security Encryption Disclaimer
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.security, color: Color(0xFF1E9C1C), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Your account details are secured with 256-bit bank-grade encryption and will strictly be used to credit delivery earnings and daily tips.",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Navigation buttons (Back + Submit)
          Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _currentStep = 0);
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(0);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      "Back",
                      style: GoogleFonts.outfit(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submitOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E9C1C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Submit Details",
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required IconData icon, required String title, required String subtitle, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                child: Icon(icon, color: const Color(0xFF1E9C1C), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text(subtitle, style: GoogleFonts.outfit(fontSize: 13, color: Colors.black54)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildImagePickerRow({required String title, XFile? imageFile, required VoidCallback onTap}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1E9C1C).withValues(alpha: 0.3)),
            ),
            child: Icon(imageFile == null ? Icons.image_outlined : Icons.check_circle, color: const Color(0xFF1E9C1C), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: GoogleFonts.outfit(fontSize: 14, color: Colors.black54))),
          ElevatedButton.icon(
            onPressed: onTap,
            icon: Icon(imageFile == null ? Icons.upload_file : Icons.check, color: Colors.white, size: 16),
            label: Text(imageFile == null ? "Upload" : "Done", style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: imageFile == null ? const Color(0xFF4285F4) : const Color(0xFF1E9C1C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
