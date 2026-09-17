import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_service.dart';
import '../services/subscription_service.dart';
import '../services/settings_service.dart';
import '../services/product_service.dart';
import '../services/address_service.dart';
import '../services/marketing_service.dart';
import '../models/product_model.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> with TickerProviderStateMixin {
  bool _isSubscribed = false; 
  int _currentStep = 1;

  // Onboarding Form Data
  String _selectedPlan = "Daily Delivery";
  String _planPrice = "₹799 / Month";
  
  String _subscriberName = "";
  String _mobileNumber = "";
  String _email = "";
  String _addressType = "Home";
  
  String _preferredProduct = "Nilara 20L Water Jar";
  int _quantity = 1;

  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  String _preferredTimeSlot = "Morning (6:00 AM - 9:00 AM)";
  String _deliveryTime = "7:30 AM";
  String _frequency = "Daily";

  String _paymentMethod = "UPI";
  bool _isCouponApplied = false;
  List<dynamic> _availableCoupons = [];
  Map<String, dynamic>? _selectedCoupon;
  final TextEditingController _couponController = TextEditingController();

  late AnimationController _fadeController;
  
  bool _isLoading = true;
  bool _isUpgrading = false;
  List<dynamic> _subscriptionPlans = [];
  List<dynamic> _mySubscriptions = [];
  List<ProductModel> _waterProducts = [];
  
  final _settingsService = SettingsService();
  final _subscriptionService = SubscriptionService();
  final _productService = ProductService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    
    // Prefill user data
    final profile = UserService().profile.value;
    _nameController.text = profile.name != "Loading..." && profile.name != "Guest" ? profile.name : "";
    _phoneController.text = profile.phone;
    _emailController.text = profile.email;

    UserService().profile.addListener(_onProfileChanged);
    
    // Prefill address data
    AddressService().addresses.addListener(_onAddressChanged);
    _onAddressChanged();

    _loadData();
  }

  void _onProfileChanged() {
    final profile = UserService().profile.value;
    if (mounted) {
      if (_nameController.text.isEmpty || _nameController.text == "Loading..." || _nameController.text == "Guest") {
        _nameController.text = profile.name != "Loading..." && profile.name != "Guest" ? profile.name : "";
      }
      if (_phoneController.text.isEmpty) _phoneController.text = profile.phone;
      if (_emailController.text.isEmpty) _emailController.text = profile.email;
    }
  }

  void _onAddressChanged() {
    final addresses = AddressService().addresses.value;
    if (mounted && addresses.isNotEmpty) {
      final defaultAddr = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
      if (_streetController.text.isEmpty) {
        _streetController.text = defaultAddr.addressLine1;
        // The API only has addressLine1, city, state, postalCode in Address model
        // We will just put everything in streetController or parse it if we can.
        // For now, let's just use addressLine1.
        _apartmentController.text = ""; 
        _floorController.text = "";
        _landmarkController.text = "${defaultAddr.city}, ${defaultAddr.state} ${defaultAddr.postalCode}";
        setState(() {
          _addressType = defaultAddr.title == 'Office' ? 'Office' : 'Home';
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    UserService().profile.removeListener(_onProfileChanged);
    AddressService().addresses.removeListener(_onAddressChanged);
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _streetController.dispose();
    _apartmentController.dispose();
    _floorController.dispose();
    _landmarkController.dispose();
    _notesController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final settings = await _settingsService.fetchSettings();
      if (settings != null && settings['subscriptionPlans'] != null) {
        _subscriptionPlans = List<dynamic>.from(settings['subscriptionPlans'])
            .where((p) => p['isActive'] != false)
            .toList();
      }

      // Safe fallback: new users will NEVER see an empty screen
      if (_subscriptionPlans.isEmpty) {
        _subscriptionPlans = List<dynamic>.from(SettingsService.defaultSubscriptionPlans);
      }

      if (_subscriptionPlans.isNotEmpty) {
        _selectedPlan = _subscriptionPlans[0]['name'] ?? "Daily Essentials";
        _planPrice = "₹${_subscriptionPlans[0]['price']} / Month";
        _frequency = _subscriptionPlans[0]['frequency'] ?? "Daily";
      }

      final products = await _productService.getProducts();
      _waterProducts = products.where((p) => p.categorySlug == 'water').toList();
      if (_waterProducts.isEmpty) {
        _waterProducts = [
          ProductModel(
            id: 'default_20l',
            name: 'Nilara 20L Water Jar',
            slug: 'nilara-20l-water-jar',
            description: 'Purified drinking water in 20L jar',
            images: ['assets/images/20L daily bulk .png'],
            variants: [
              ProductVariant(
                id: 'v_20l',
                sku: 'NIL-20L',
                pricePaise: 8000,
                discountPricePaise: 8000,
                stockQuantity: 100,
                unit: '20 Litre',
                weightOrVolume: 20,
              ),
            ],
            isActive: true,
            categoryName: 'Water',
            categorySlug: 'water',
          ),
          ProductModel(
            id: 'default_10l',
            name: 'Nilara 10L Water Jar',
            slug: 'nilara-10l-water-jar',
            description: 'Purified drinking water in 10L jar',
            images: ['assets/images/water_can_10l.png'],
            variants: [
              ProductVariant(
                id: 'v_10l',
                sku: 'NIL-10L',
                pricePaise: 5000,
                discountPricePaise: 5000,
                stockQuantity: 100,
                unit: '10 Litre',
                weightOrVolume: 10,
              ),
            ],
            isActive: true,
            categoryName: 'Water',
            categorySlug: 'water',
          ),
        ];
      }
      if (_waterProducts.isNotEmpty) {
        _preferredProduct = _waterProducts.first.name;
      }
      
      final couponsRes = await MarketingService().fetchActiveCoupons();
      _availableCoupons = couponsRes;

      final subs = await _subscriptionService.getMySubscriptions();
      setState(() {
        _mySubscriptions = subs;
        if (_mySubscriptions.isNotEmpty) {
          _isSubscribed = true;
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading subscriptions: $e");
      if (_subscriptionPlans.isEmpty) {
        _subscriptionPlans = List<dynamic>.from(SettingsService.defaultSubscriptionPlans);
        if (_subscriptionPlans.isNotEmpty) {
          _selectedPlan = _subscriptionPlans[0]['name'] ?? "Daily Essentials";
          _planPrice = "₹${_subscriptionPlans[0]['price']} / Month";
          _frequency = _subscriptionPlans[0]['frequency'] ?? "Daily";
        }
      }
      setState(() => _isLoading = false);
    }
  }

  void _resetOnboarding() {
    setState(() {
      _currentStep = 1;
      _isSubscribed = false;
      _selectedPlan = _subscriptionPlans.isNotEmpty ? _subscriptionPlans[0]['name'] : "Standard";
      _frequency = "Daily";
      _quantity = 1;
      _preferredTimeSlot = "Morning (6:00 AM - 9:00 AM)";
      _deliveryTime = "7:30 AM";
      _isCouponApplied = false;
      _selectedCoupon = null;
      _couponController.clear();
      _fadeController.reset();
      _fadeController.forward();
    });
  }

  void _handleUpgradePlan() {
    if (_mySubscriptions.isNotEmpty) {
      final activeSub = _mySubscriptions.first;
      if (activeSub.remainingDays > 2) {
        _isUpgrading = true;
      } else {
        _isUpgrading = false;
      }
      _resetOnboarding();
      _prefillFromSubscription(activeSub);
    } else {
      _isUpgrading = false;
      _resetOnboarding();
    }
  }

  void _prefillFromSubscription(dynamic sub) {
    setState(() {
      _preferredProduct = sub.productName ?? _preferredProduct;
      _quantity = sub.quantity ?? _quantity;
      _frequency = sub.frequency ?? _frequency;
      
      if (sub.contact != null) {
        if (sub.contact['name'] != null && sub.contact['name'].toString().isNotEmpty) _nameController.text = sub.contact['name'];
        if (sub.contact['phone'] != null && sub.contact['phone'].toString().isNotEmpty) _phoneController.text = sub.contact['phone'];
        if (sub.contact['email'] != null && sub.contact['email'].toString().isNotEmpty) _emailController.text = sub.contact['email'];
      }
      
      if (sub.address != null) {
        if (sub.address['street'] != null && sub.address['street'].toString().isNotEmpty) _streetController.text = sub.address['street'];
        if (sub.address['apartment'] != null) _apartmentController.text = sub.address['apartment'] ?? '';
        if (sub.address['floor'] != null) _floorController.text = sub.address['floor'] ?? '';
        if (sub.address['landmark'] != null) _landmarkController.text = sub.address['landmark'] ?? '';
        if (sub.address['type'] != null && sub.address['type'].toString().isNotEmpty) _addressType = sub.address['type'];
      }
    });
  }

  // Duplicate dispose removed

  void _nextStep() async {
    if (_currentStep == 2) {
      if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all contact details.')));
        return;
      }
    }
    
    if (_currentStep == 3) {
      if (_streetController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your delivery address.')));
        return;
      }
    }

    if (_currentStep == 5) {
      // Submitting the subscription
      setState(() => _isLoading = true);
      try {
        double parsedPrice = double.tryParse(_planPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        double finalPrice = parsedPrice;
        
        if (_selectedCoupon != null) {
          double discount = (_selectedCoupon!['discountPercent'] as num?)?.toDouble() ?? 0;
          if (discount > 0) {
            double discountAmount = (parsedPrice * discount) / 100;
            double maxDiscount = (_selectedCoupon!['maxDiscountAmount'] as num?)?.toDouble() ?? 0;
            if (maxDiscount > 0 && discountAmount > maxDiscount) {
              discountAmount = maxDiscount;
            }
            finalPrice = parsedPrice - discountAmount;
          }
        }
        
        final payload = {
          "planName": _selectedPlan,
          "frequency": _frequency,
          "productName": _preferredProduct,
          "quantity": _quantity,
          "price": parsedPrice,
          "discountedPrice": finalPrice,
          "deliveryTime": _deliveryTime,
          "startDate": _startDate.toIso8601String(),
          "address": {
            "type": _addressType,
            "street": _streetController.text,
            "apartment": _apartmentController.text,
            "floor": _floorController.text,
            "landmark": _landmarkController.text,
            "notes": _notesController.text
          },
          "paymentMethod": _paymentMethod,
          "specialInstructions": _notesController.text
        };
        
        final res = await _subscriptionService.createSubscription(payload);
        if (res['success'] == true) {
          // reload subscriptions
          final subs = await _subscriptionService.getMySubscriptions();
          setState(() {
            _mySubscriptions = subs;
            _isLoading = false;
            _currentStep = 6;
          });
          _fadeController.reset();
          _fadeController.forward();
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Error creating subscription')));
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error submitting subscription')));
      }
      return;
    }

    if (_currentStep < 6) {
      _fadeController.reset();
      setState(() {
        _currentStep++;
      });
      _fadeController.forward();
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      _fadeController.reset();
      setState(() {
        _currentStep--;
      });
      _fadeController.forward();
    }
  }

  void _finishOnboarding() {
    _fadeController.reset();
    setState(() {
      _isSubscribed = true;
      _currentStep = 1; // reset step back to 1 for new plans
    });
    _fadeController.forward();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: _isSubscribed
            ? null
            : (_currentStep > 1
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18),
                    onPressed: _prevStep,
                  )
                : (_mySubscriptions.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.black87, size: 22),
                        onPressed: () {
                          setState(() {
                            _isSubscribed = true;
                            _isUpgrading = false;
                          });
                        },
                      )
                    : null)),
        title: Row(
          children: [
            const Icon(Icons.water_drop, color: Color(0xFF0288D1), size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _isSubscribed ? "My Subscriptions" : "Water Subscription",
                style: GoogleFonts.outfit(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            ),
          ],
        ),
        actions: const [],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : FadeTransition(
            opacity: _fadeController,
            child: _isSubscribed && _mySubscriptions.isNotEmpty ? _buildDashboard() : _buildOnboardingFlow(),
          ),
    );
  }

  // Multi-Step Onboarding Flow Container
  Widget _buildOnboardingFlow() {
    return Column(
      children: [
        // Progress Header Bar
        _buildProgressBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
            child: _buildCurrentStepWidget(),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Step $_currentStep of 6",
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0288D1),
                ),
              ),
              Text(
                "${((_currentStep / 6) * 100).round()}% Completed",
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _currentStep / 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0288D1)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepWidget() {
    switch (_currentStep) {
      case 1:
        return _buildStep1ChoosePlan();
      case 2:
        return _buildStep2BasicDetails();
      case 3:
        return _buildStep3DeliveryAddress();
      case 4:
        return _buildStep4DeliverySchedule();
      case 5:
        return _buildStep5Payment();
      case 6:
        return _buildStep6Success();
      default:
        return _buildStep1ChoosePlan();
    }
  }

  // --- STEP 1: CHOOSE SUBSCRIPTION PLAN ---
  Widget _buildStep1ChoosePlan() {
    List<dynamic> displayedPlans = List.from(_subscriptionPlans);
    String currentPlanName = "";
    if (_mySubscriptions.isNotEmpty) {
      currentPlanName = _mySubscriptions.first.planName ?? "";
    }

    if (currentPlanName.isNotEmpty) {
      displayedPlans.sort((a, b) {
        if (a["name"] == currentPlanName) return -1;
        if (b["name"] == currentPlanName) return 1;
        return 0;
      });
    }

    if (displayedPlans.isEmpty) {
      displayedPlans = List.from(SettingsService.defaultSubscriptionPlans);
    }

    if (displayedPlans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                "No subscription plans available",
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              Text(
                "Unable to load subscription plans. Tap below to retry.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _isLoading = true);
                  _loadData();
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Retry"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0288D1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "💧 Water Subscription",
          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
        ),
        const SizedBox(height: 4),
        Text(
          _isUpgrading ? "Upgrade to a premium plan." : "Choose a plan that suits your needs.",
          style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        ...displayedPlans.map((p) {
          final bool isSelected = _selectedPlan == p["name"];
          final bool isCurrentPlan = currentPlanName == p["name"];
          final saveText = (p["discountPercentage"] ?? 0) > 0 ? "Save ${p["discountPercentage"]}%" : "";
          final priceText = "₹${p["price"]} / Month";
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPlan = p["name"] as String;
                _planPrice = priceText;
                _frequency = p["frequency"] as String;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? const Color(0xFF0288D1) : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected ? const Color(0xFF0288D1).withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (isCurrentPlan)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Color(0xFF2E7D32), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            "Current Plan",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? const Color(0xFF0288D1) : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    p["name"] as String,
                                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (saveText.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F2FE),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      saveText,
                                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF0288D1)),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (p["description"] ?? "") as String,
                              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            if (p["includedProducts"] != null && (p["includedProducts"] as List).isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF0288D1)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "Includes: ${(p["includedProducts"] as List).join(", ")}",
                                        style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF0288D1), fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        priceText,
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF0288D1)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
        _buildPrimaryButton(label: "Continue", onTap: _nextStep),
      ],
    );
  }

  // --- STEP 2: BASIC DETAILS ---
  Widget _buildStep2BasicDetails() {
    // Filter water products based on selected plan's included products
    final activePlan = _subscriptionPlans.firstWhere(
      (p) => p["name"] == _selectedPlan,
      orElse: () => null,
    );
    
    List<ProductModel> availableProducts = _waterProducts;
    if (activePlan != null && activePlan["includedProducts"] != null) {
      final includedNames = List<String>.from(activePlan["includedProducts"]);
      if (includedNames.isNotEmpty) {
        availableProducts = _waterProducts.where((p) => includedNames.contains(p.name)).toList();
      }
    }

    // Auto-select first available if current selection is invalid
    if (availableProducts.isNotEmpty && !availableProducts.any((p) => p.name == _preferredProduct)) {
      // Must use addPostFrameCallback to avoid set state during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _preferredProduct = availableProducts.first.name;
          });
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Subscriber Details", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 4),
        Text("Enter subscriber contact & product preferences.", style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600)),
        const SizedBox(height: 20),
        _buildTextField(label: "Subscriber Name", controller: _nameController, onChanged: (v) {}),
        const SizedBox(height: 14),
        _buildTextField(label: "Mobile Number", controller: _phoneController, keyboardType: TextInputType.phone, onChanged: (v) {}),
        const SizedBox(height: 14),
        _buildTextField(label: "Email", controller: _emailController, keyboardType: TextInputType.emailAddress, onChanged: (v) {}),
        const SizedBox(height: 18),
        Text("Preferred Water Product", style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 8),
        if (availableProducts.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text("No products available for this plan.")),
          )
        else
          ...availableProducts.map((prod) {
            final isSelected = _preferredProduct == prod.name;
            return GestureDetector(
              onTap: () => setState(() {
                _preferredProduct = prod.name;
                _quantity = 1; // reset quantity when switching products
              }),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isSelected ? const Color(0xFF0288D1) : Colors.grey.shade300, width: isSelected ? 2 : 1),
                ),
                child: Row(
                  children: [
                    Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? const Color(0xFF0288D1) : Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(prod.name, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                          if (prod.description.isNotEmpty)
                            Text(prod.description, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_quantity > 1) {
                                setState(() => _quantity--);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.remove, size: 16, color: Colors.black87),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              _quantity.toString(),
                              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => _quantity++);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.add, size: 16, color: Color(0xFF0288D1)),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 20),
        _buildPrimaryButton(label: "Continue", onTap: _nextStep),
      ],
    );
  }

  // --- STEP 3: DELIVERY ADDRESS ---
  Widget _buildStep3DeliveryAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Delivery Address", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 4),
        Text("Where should we deliver your Nilara water?", style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600)),
        const SizedBox(height: 20),
        Text("Address Type", style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 8),
        Row(
          children: ["Home", "Office"].map((type) {
            final isSelected = _addressType == type;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _addressType = type),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE0F2FE) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? const Color(0xFF0288D1) : Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Text(
                      type,
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF0288D1) : Colors.black87),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        _buildTextField(label: "Address (Line 1)", controller: _streetController, onChanged: (v) {}),
        const SizedBox(height: 14),
        _buildTextField(label: "Apartment / Suite", controller: _apartmentController, onChanged: (v) {}),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _buildTextField(label: "Floor", controller: _floorController, onChanged: (v) {})),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(label: "Landmark", controller: _landmarkController, onChanged: (v) {})),
          ],
        ),
        const SizedBox(height: 14),
        _buildTextField(label: "Delivery Notes", controller: _notesController, onChanged: (v) {}),
        const SizedBox(height: 20),
        _buildPrimaryButton(label: "Save Address & Continue", onTap: _nextStep),
      ],
    );
  }

  // --- STEP 4: DELIVERY SCHEDULE ---
  Widget _buildStep4DeliverySchedule() {
    final dynamicSlots = SettingsService().deliveryTimeSlots.value;
    if (dynamicSlots.isNotEmpty && !dynamicSlots.contains(_preferredTimeSlot)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _preferredTimeSlot = dynamicSlots.first;
        });
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Delivery Schedule", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 4),
        Text("Select your preferred delivery time slot and frequency.", style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600)),
        const SizedBox(height: 20),
        Text("Preferred Time Slot", style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 10),
        ...dynamicSlots.map((slotName) {
          final isSelected = _preferredTimeSlot == slotName;
          return GestureDetector(
            onTap: () {
              setState(() {
                _preferredTimeSlot = slotName;
                _deliveryTime = slotName; // For compatibility
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? const Color(0xFF0288D1) : Colors.grey.shade200, width: isSelected ? 2 : 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: isSelected ? const Color(0xFF0288D1) : Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(slotName, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                  ),
                  if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF0288D1), size: 20),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Text("Start Date", style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _startDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 90)),
            );
            if (picked != null) {
              setState(() {
                _startDate = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade300)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][_startDate.weekday - 1]}, ${_startDate.day}/${_startDate.month}/${_startDate.year}",
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                ),
                const Icon(Icons.calendar_month, color: Color(0xFF0288D1), size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildPrimaryButton(label: "Continue", onTap: _nextStep),
      ],
    );
  }

  // --- STEP 5: PAYMENT ---
  Widget _buildStep5Payment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Payment", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 4),
        Text("Review summary and complete payment.", style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600)),
        const SizedBox(height: 20),

        // Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Subscription Summary", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              const SizedBox(height: 12),
              _buildSummaryRow("Plan", _selectedPlan),
              _buildSummaryRow("Product", "Nilara $_preferredProduct"),
              _buildSummaryRow("Frequency", _frequency),
              _buildSummaryRow("Delivery Time", _preferredTimeSlot),
              const Divider(height: 20),
              Builder(
                builder: (context) {
                  double parsedPrice = double.tryParse(_planPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
                  double finalPrice = parsedPrice;
                  if (_selectedCoupon != null) {
                    double discount = (_selectedCoupon!['discountPercent'] as num?)?.toDouble() ?? 0;
                    if (discount > 0) {
                      double discountAmount = (parsedPrice * discount) / 100;
                      double maxDiscount = (_selectedCoupon!['maxDiscountAmount'] as num?)?.toDouble() ?? 0;
                      if (maxDiscount > 0 && discountAmount > maxDiscount) {
                        discountAmount = maxDiscount;
                      }
                      finalPrice = parsedPrice - discountAmount;
                    }
                  }
                  return _buildSummaryRow("Total Monthly Price", "₹${finalPrice.toStringAsFixed(0)} / Month", isBold: true);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Coupon Selection
        if (_availableCoupons.isNotEmpty) ...[
          if (_selectedCoupon == null)
            GestureDetector(
              onTap: () {
                _showCouponBottomSheet();
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_offer, color: Color(0xFF0288D1), size: 20),
                        const SizedBox(width: 12),
                        Text("Apply Coupon", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                      ],
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF0288D1), width: 1.5),
                boxShadow: [BoxShadow(color: const Color(0xFF0288D1).withValues(alpha: 0.1), blurRadius: 8)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedCoupon!['code'] ?? '', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                      const SizedBox(height: 4),
                      Text(_selectedCoupon!['description'] ?? '', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCoupon = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                    child: Text("Remove", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
        ],

        Text("Payment Method", style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 10),
        ...["UPI (Google Pay / PhonePe)", "Credit / Debit Card", "Net Banking", "Cash / Pay on Delivery"].map((m) {
          final isSelected = _paymentMethod == m;
          return GestureDetector(
            onTap: () => setState(() => _paymentMethod = m),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSelected ? const Color(0xFF0288D1) : Colors.grey.shade300, width: isSelected ? 2 : 1),
              ),
              child: Row(
                children: [
                  Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? const Color(0xFF0288D1) : Colors.grey),
                  const SizedBox(width: 12),
                  Text(m, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
        Builder(
          builder: (context) {
            double parsedPrice = double.tryParse(_planPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
            double finalPrice = parsedPrice;
            if (_selectedCoupon != null) {
              double discount = (_selectedCoupon!['discountPercent'] as num?)?.toDouble() ?? 0;
              if (discount > 0) {
                double discountAmount = (parsedPrice * discount) / 100;
                double maxDiscount = (_selectedCoupon!['maxDiscountAmount'] as num?)?.toDouble() ?? 0;
                if (maxDiscount > 0 && discountAmount > maxDiscount) {
                  discountAmount = maxDiscount;
                }
                finalPrice = parsedPrice - discountAmount;
              }
            }
            return _buildPrimaryButton(label: "Pay ₹${finalPrice.toStringAsFixed(0)}", onTap: _nextStep);
          },
        ),
      ],
    );
  }

  void _showCouponBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                Text("Available Coupons", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                const SizedBox(height: 16),
                if (_availableCoupons.isEmpty)
                  Text("No coupons available at the moment.", style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade600)),
                ..._availableCoupons.map((coupon) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(coupon['code'] ?? '', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                            const SizedBox(height: 4),
                            Text(coupon['description'] ?? '', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedCoupon = coupon;
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Coupon ${coupon['code']} applied!")));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0288D1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: const Size(0, 36),
                          ),
                          child: Text("Apply", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- STEP 6: SUBSCRIPTION SUCCESS ---
  Widget _buildStep6Success() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(color: Color(0xFFE0F2FE), shape: BoxShape.circle),
            child: const Center(child: Text("🎉", style: TextStyle(fontSize: 50))),
          ),
          const SizedBox(height: 20),
          Text("Subscription Created Successfully", textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Text("Your Nilara water subscription is active.", style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              children: [
                _buildSummaryRow("First Delivery", "Tomorrow"),
                _buildSummaryRow("Delivery Time", _deliveryTime),
                _buildSummaryRow("Product", "Nilara $_preferredProduct"),
                _buildSummaryRow("Plan", _selectedPlan),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _buildPrimaryButton(label: "Go to Dashboard", onTap: _finishOnboarding),
        ],
      ),
    );
  }

  // --- ACTIVE SUBSCRIPTION DASHBOARD ---
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0288D1), Color(0xFF00B0FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0288D1).withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "My Subscriptions",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Manage your recurring water deliveries.",
                        style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.autorenew, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Active Plan Cards
          ..._mySubscriptions.map((sub) {
            return ValueListenableBuilder<Subscription?>(
              valueListenable: SubscriptionService().activeSubscription,
              builder: (context, activeSub, child) {
                final displaySub = (activeSub?.id == sub.id) ? activeSub! : sub;
                final isExpired = displaySub.status == 'Expired' || (displaySub.remainingDays ?? 1) <= 0;
                final displayStatus = isExpired ? 'Plan Expired' : displaySub.status;
                final statusColor = isExpired ? Colors.red : (displaySub.status == 'Active' ? const Color(0xFF2E7D32) : Colors.orange);
                final statusBgColor = isExpired ? const Color(0xFFFFEBEE) : (displaySub.status == 'Active' ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0));

                return GestureDetector(
                  onTap: () => _showSubscriptionDetails(displaySub),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF0288D1).withValues(alpha: 0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              displayStatus,
                              style: GoogleFonts.outfit(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "Plan: ${displaySub.planName}",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F8FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.water_drop, color: Color(0xFF0288D1), size: 40),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displaySub.productName.isNotEmpty ? displaySub.productName : "Nilara Subscription",
                              style: GoogleFonts.outfit(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${displaySub.planName} • Qty: ${displaySub.quantity}",
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildDetailItem(icon: Icons.repeat, title: "Frequency", value: displaySub.frequency),
                      _buildDetailItem(icon: Icons.access_time, title: "Time", value: displaySub.deliveryTimePref),
                      _buildDetailItem(icon: Icons.event, title: "Expires", value: displaySub.endDate != null ? "${displaySub.remainingDays} days" : "Until Cancelled"),
                    ],
                  ),
                ],
              ),
            ),
            );
              },
            );
          }),
          const SizedBox(height: 8),

          // Quick Actions
          Text(
            "Quick Actions",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickActions(),
          const SizedBox(height: 28),

          _buildSkippedDates(),

          // Benefits
          Text(
            "Subscription Benefits",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          _buildBenefitsChips(),
        ],
      ),
    );
  }

  void _showSubscriptionDetails(dynamic sub) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Subscription Details", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDetailCard(sub),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailCard(dynamic sub) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow("Plan Name", sub.planName, isBold: true),
          const Divider(height: 24),
          _buildSummaryRow("Product", sub.productName),
          const Divider(height: 24),
          _buildSummaryRow("Status", sub.status),
          const Divider(height: 24),
          _buildSummaryRow("Quantity", "${sub.quantity}"),
          const Divider(height: 24),
          _buildSummaryRow("Frequency", sub.frequency),
          const Divider(height: 24),
          _buildSummaryRow("Price", "₹${sub.price.toStringAsFixed(2)}"),
          const Divider(height: 24),
          _buildSummaryRow("Delivery Time", sub.deliveryTimePref),
          const Divider(height: 24),
          _buildSummaryRow("Next Delivery", sub.nextDelivery),
          const Divider(height: 24),
          _buildSummaryRow("Duration", "${sub.durationMonths} ${sub.durationMonths == 1 ? 'Month' : 'Months'}"),
          const Divider(height: 24),
          _buildSummaryRow("Remaining Days", "${sub.remainingDays} days"),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildTextField({required String label, String? initialValue, TextEditingController? controller, TextInputType? keyboardType, required Function(String) onChanged}) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade700),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF0288D1), width: 1.8)),
      ),
    );
  }

  Widget _buildPrimaryButton({required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0288D1),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600)),
          Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: const Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildDetailItem({required IconData icon, required String title, required String value}) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0288D1)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey.shade500)),
                Text(value, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSkipDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text("Skip Delivery", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.next_plan_outlined, color: Color(0xFF0288D1)),
                title: Text("Skip Tomorrow", style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.pop(context);
                  _handleSkip(DateTime.now().add(const Duration(days: 1)));
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_calendar_outlined, color: Color(0xFF0288D1)),
                title: Text("Custom Date", style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () async {
                  Navigator.pop(context);
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF0288D1),
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    _handleSkip(picked);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.date_range_outlined, color: Color(0xFF0288D1)),
                title: Text("Date Range", style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () async {
                  Navigator.pop(context);
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF0288D1),
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    _handleSkipRange(picked.start, picked.end);
                  }
                },
              ),
            ],
          ),
        );
      }
    );
  }

  Future<void> _handleSkipRange(DateTime start, DateTime end) async {
    final action = await _subscriptionService.skipDateRange(start, end);
    if (action != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Successfully skipped deliveries for the selected range!"),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
        _loadData();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update delivery skip status."), 
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2)
          ),
        );
      }
    }
  }

  Future<void> _handleSkip(DateTime date) async {
    final action = await _subscriptionService.skipDate(date);
    if (action != null) {
      if (mounted) {
        final formattedDate = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == 'skipped' 
                ? "Successfully skipped delivery for $formattedDate!" 
                : "Successfully restored delivery for $formattedDate!"
            ),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
        _loadData();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update delivery skip status."), 
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2)
          ),
        );
      }
    }
  }

  void _showRescheduleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final times = ["Morning 6:00 AM", "Morning 7:30 AM", "Evening 5:00 PM", "Evening 6:30 PM"];
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Reschedule Delivery", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...times.map((t) => ListTile(
                  title: Text(t, style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () async {
                    Navigator.pop(context);
                    final success = await _subscriptionService.reschedule(t);
                    if (success) {
                      await _loadData();
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Delivery rescheduled successfully!")));
                    } else {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to reschedule delivery.")));
                    }
                  },
                )).toList()
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildSkippedDates() {
    final sub = _mySubscriptions.isNotEmpty ? _mySubscriptions.first : null;
    if (sub == null || sub.skippedDeliveries.isEmpty) return const SizedBox();

    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    
    // Only show future skipped dates
    final List<DateTime> futureSkips = (sub.skippedDeliveries as List).cast<DateTime>()
        .where((d) => !d.isBefore(todayMidnight))
        .toList()
      ..sort((a, b) => a.compareTo(b));

    if (futureSkips.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Skipped Deliveries",
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: futureSkips.map((date) {
            final formatted = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
            return Chip(
              label: Text(formatted, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.deepOrange.shade700)),
              backgroundColor: Colors.orange.shade50,
              deleteIcon: const Icon(Icons.close, size: 14, color: Colors.deepOrange),
              onDeleted: () async {
                final success = await _subscriptionService.removeSkipDate(date);
                if (success) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Restored delivery for $formatted!"), backgroundColor: Colors.green.shade600));
                    _loadData();
                  }
                } else {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to restore delivery."), backgroundColor: Colors.red));
                }
              },
              side: BorderSide(color: Colors.orange.shade200),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildQuickActions() {
    final sub = _mySubscriptions.isNotEmpty ? _mySubscriptions.first : null;
    final isPaused = sub?.status == 'Suspended';

    final actions = [
      {
        "icon": isPaused ? Icons.play_circle_outline : Icons.pause_circle_outline, 
        "label": isPaused ? "Resume Plan" : "Pause Plan", 
        "onTap": () async {
          await _subscriptionService.toggleStatus();
          await _loadData();
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isPaused ? "Subscription resumed successfully." : "Subscription paused successfully."), duration: const Duration(seconds: 2)),
          );
        }
      },
      {
        "icon": Icons.skip_next_outlined, 
        "label": "Skip Next", 
        "onTap": () {
          _showSkipDialog();
        }
      },
      {
        "icon": Icons.edit_calendar_outlined, 
        "label": "Reschedule", 
        "onTap": () {
          _showRescheduleDialog();
        }
      },
      {
        "icon": Icons.upgrade_outlined, 
        "label": "Upgrade Plan", 
        "onTap": () {
          _handleUpgradePlan();
        }
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.9,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final item = actions[index];
        return GestureDetector(
          onTap: item["onTap"] as VoidCallback,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item["icon"] as IconData, color: const Color(0xFF0288D1), size: 24),
                const SizedBox(height: 6),
                Text(
                  item["label"] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBenefitsChips() {
    final sub = _mySubscriptions.isNotEmpty ? _mySubscriptions.first : null;
    List<dynamic> planFeatures = [];

    if (sub != null) {
      final plan = _subscriptionPlans.firstWhere(
        (p) => p['name'] == sub.planName, 
        orElse: () => null
      );
      if (plan != null && plan['features'] != null && (plan['features'] as List).isNotEmpty) {
        planFeatures = List.from(plan['features']);
      }
    }

    if (planFeatures.isEmpty) {
      // Fallback benefits if none are configured in the backend
      planFeatures = [
        "Fresh Drinking Water",
        "Priority Delivery",
        "Save up to 10%",
        "Flexible Schedule",
        "Pause Anytime"
      ];
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: planFeatures.map((f) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF0288D1).withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF0288D1)),
              const SizedBox(width: 6),
              Text(
                f.toString(),
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
