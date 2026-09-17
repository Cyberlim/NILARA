import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/cart_service.dart';
import '../services/address_service.dart';
import '../widgets/product_card.dart';
import 'payment_screen.dart';
import 'saved_addresses_screen.dart';
import 'add_edit_address_screen.dart';
import '../services/marketing_service.dart';
import '../services/settings_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _leaveAtDoor = false;

  // Marketing & Extras state
  List<dynamic> _coupons = [];
  List<dynamic> _gifts = [];
  Map<String, dynamic>? _appliedCoupon;
  bool _isGiftAdded = false;
  String? _deliveryTimePref;

  // Settings state
  double _handlingCharge = 2.0;
  double _deliveryFee = 25.0;
  double _freeDeliveryMinAmount = 500.0;

  @override
  void initState() {
    super.initState();
    _fetchMarketingData();
    if (SettingsService().deliveryTimeSlots.value.isNotEmpty) {
      _deliveryTimePref = SettingsService().deliveryTimeSlots.value.first;
    }
  }

  Future<void> _fetchMarketingData() async {
    final coupons = await MarketingService().fetchActiveCoupons();
    final gifts = await MarketingService().fetchActiveGifts();
    final settings = await SettingsService().fetchSettings();
    if (mounted) {
      setState(() {
        _coupons = coupons;
        _gifts = gifts;
        if (settings != null) {
          _handlingCharge = (settings['handlingCharge'] ?? 2.0).toDouble();
          _deliveryFee = (settings['deliveryFee'] ?? 25.0).toDouble();
          _freeDeliveryMinAmount =
              (settings['freeDeliveryMinAmount'] ?? 500.0).toDouble();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Review Cart",
              style: GoogleFonts.outfit(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              "Instamart",
              style: GoogleFonts.outfit(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: ValueListenableBuilder<Map<String, CartItem>>(
        valueListenable: CartService().items,
        builder: (context, cartItems, child) {
          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    "Your cart is empty",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          // Calculate totals
          double itemTotal = 0;
          for (var item in cartItems.values) {
            String cleanPrice = item.price.replaceAll(RegExp(r'[^0-9.]'), '');
            double priceVal = double.tryParse(cleanPrice) ?? 0;
            itemTotal += priceVal * item.quantity;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSavingsCard(itemTotal, _calculateDiscount(itemTotal)),
                const SizedBox(height: 12),
                _buildOrderingForSomeoneElseCard(),
                const SizedBox(height: 12),
                _buildFreeGiftCard(itemTotal),
                const SizedBox(height: 12),
                _buildCartItemsCard(cartItems, itemTotal),
                const SizedBox(height: 12),
                _buildBeforeYouCheckout(),
                const SizedBox(height: 12),
                _buildOffersCard(),
                const SizedBox(height: 12),
                _buildLeaveAtDoorCard(),
                const SizedBox(height: 12),
                _buildBillDetailsCard(itemTotal),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<Map<String, CartItem>>(
        valueListenable: CartService().items,
        builder: (context, cartItems, child) {
          if (cartItems.isEmpty) return const SizedBox.shrink();
          double itemTotal = 0;
          for (var item in cartItems.values) {
            String cleanPrice = item.price.replaceAll(RegExp(r'[^0-9.]'), '');
            double priceVal = double.tryParse(cleanPrice) ?? 0;
            itemTotal += priceVal * item.quantity;
          }
          double discount = _calculateDiscount(itemTotal);
          double appliedDelivery =
              itemTotal >= _freeDeliveryMinAmount ? 0 : _deliveryFee;
          double grandTotal =
              itemTotal + _handlingCharge + appliedDelivery - discount;
          return Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () =>
                    _showAddressBottomSheet(context, grandTotal),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6FB353),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  "PAY ₹${grandTotal.toStringAsFixed(0)}",
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddressBottomSheet(BuildContext context, double totalAmount) {
    String selectedAddressId = AddressService()
        .addresses
        .value
        .firstWhere((a) => a.isDefault,
            orElse: () => AddressService().addresses.value.first)
        .id;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Select a delivery address",
                      style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<List<Address>>(
                    valueListenable: AddressService().addresses,
                    builder: (context, addresses, child) {
                      return Column(
                        children: addresses.map((address) {
                          final isSelected = selectedAddressId == address.id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () => setModalState(
                                  () => selectedAddressId = address.id),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: isSelected
                                          ? Colors.green
                                          : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1),
                                  borderRadius: BorderRadius.circular(12),
                                  color: isSelected
                                      ? Colors.green.shade50
                                      : Colors.white,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      address.title.toLowerCase() == 'home'
                                          ? Icons.home
                                          : (address.title.toLowerCase() ==
                                                  'work'
                                              ? Icons.work
                                              : Icons.location_on),
                                      color: isSelected
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(address.title,
                                              style: GoogleFonts.outfit(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          const SizedBox(height: 4),
                                          Text(address.fullAddress,
                                              style: GoogleFonts.outfit(
                                                  color: Colors.grey.shade700,
                                                  fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(Icons.check_circle,
                                          color: Colors.green),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => AddEditAddressScreen()));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        const Icon(Icons.add, color: Colors.green),
                        const SizedBox(width: 12),
                        Text("Add a new address",
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 15)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PaymentScreen(
                                    totalAmount: totalAmount,
                                    deliveryAddressId: selectedAddressId,
                                    deliveryTimePref: _deliveryTimePref,
                                  )),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6FB353),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: Text(
                          "PAY ₹${totalAmount.toStringAsFixed(0)}",
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWhiteCard({required Widget child, Color? color}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSavingsCard(double itemTotal, double couponDiscount) {
    double productSavings = itemTotal * 0.2;
    double totalSavings = productSavings + couponDiscount;
    if (totalSavings <= 0) return const SizedBox.shrink();
    return _buildWhiteCard(
      color: const Color(0xFFE3EFFF),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Your total savings",
                    style: GoogleFonts.outfit(
                        color: const Color(0xFF1E5BB5),
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                if (couponDiscount > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                      "Includes ₹${couponDiscount.toStringAsFixed(0)} savings from coupon",
                      style: GoogleFonts.outfit(
                          color: const Color(0xFF4A80C9), fontSize: 11)),
                ] else ...[
                  const SizedBox(height: 2),
                  Text(
                      "Includes ₹${productSavings.toStringAsFixed(0)} savings from products",
                      style: GoogleFonts.outfit(
                          color: const Color(0xFF4A80C9), fontSize: 11)),
                ]
              ],
            ),
            Text("₹${totalSavings.toStringAsFixed(0)}",
                style: GoogleFonts.outfit(
                    color: const Color(0xFF1E5BB5),
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderingForSomeoneElseCard() {
    return _buildWhiteCard(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditAddressScreen(
                isOrderingForSomeoneElse: true,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ordering for someone else?",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "Add details",
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4CA04B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildFreeGiftCard(double cartTotal) {
    if (_gifts.isEmpty) return const SizedBox.shrink();

    final applicableGift = _gifts.lastWhere(
      (gift) => cartTotal >= gift['minOrderValue'],
      orElse: () => _gifts.first,
    );

    final isUnlocked = cartTotal >= applicableGift['minOrderValue'];

    return _buildWhiteCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Free gift for you!",
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: AssetImage(applicableGift['image'] ??
                                  'assets/images/qb4.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                applicableGift['name'] ?? "Surprise Gift",
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                isUnlocked
                                    ? "FREE"
                                    : "Unlock at ₹${applicableGift['minOrderValue']}",
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isUnlocked
                                      ? Colors.black87
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isUnlocked)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isGiftAdded = !_isGiftAdded;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: _isGiftAdded ? Colors.red.shade50 : Colors.green.shade50,
                                border: Border.all(
                                    color: _isGiftAdded ? Colors.red.shade200 : Colors.green.shade200),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _isGiftAdded ? "REMOVE" : "ADD",
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _isGiftAdded ? Colors.red : const Color(0xFF4CA04B),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!isUnlocked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF6F3FF),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.card_giftcard,
                              color: Colors.purple, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            "Add ₹${(applicableGift['minOrderValue'] - cartTotal).toStringAsFixed(0)} more to unlock",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.purple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

  Widget _buildCartItemsCard(
      Map<String, CartItem> cartItems, double itemTotal) {
    final int totalItems =
        cartItems.values.fold(0, (sum, item) => sum + item.quantity);

    Map<String, dynamic>? unlockedGift;
    if (_gifts.isNotEmpty && _isGiftAdded) {
      try {
        unlockedGift = _gifts.lastWhere(
          (g) => itemTotal >= g['minOrderValue'],
        );
      } catch (_) {}
    }

    return _buildWhiteCard(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CA04B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.local_shipping_outlined,
                      color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Order",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Shipment of $totalItems item${totalItems > 1 ? 's' : ''}",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cartItems.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
            itemBuilder: (context, index) {
              final item = cartItems.values.elementAt(index);
              return _buildCartItemRow(item);
            },
          ),
          if (unlockedGift != null) ...[
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            _buildFreeGiftRow(unlockedGift),
          ],
        ],
      ),
    );
  }

  Widget _buildFreeGiftRow(Map<String, dynamic> gift) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F9),
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(gift['image'] ?? 'assets/images/qb4.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gift['name'] ?? "Surprise Gift",
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "1 pc",
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "FREE",
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.green.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemRow(CartItem item) {
    double lineOriginalPriceVal = 0;
    if (item.originalPrice != null) {
      String cleanOrigPrice =
          item.originalPrice!.replaceAll(RegExp(r'[^0-9.]'), '');
      lineOriginalPriceVal =
          (double.tryParse(cleanOrigPrice) ?? 0) * item.quantity;
    } else {
      String cleanPrice = item.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double priceVal = double.tryParse(cleanPrice) ?? 0;
      lineOriginalPriceVal = (priceVal * 1.2) * item.quantity;
    }
    String lineOriginalPriceStr =
        "₹${lineOriginalPriceVal.toStringAsFixed(0)}";

    String cleanPrice = item.price.replaceAll(RegExp(r'[^0-9.]'), '');
    double priceVal = double.tryParse(cleanPrice) ?? 0;
    double linePriceVal = priceVal * item.quantity;
    String linePriceStr = "₹${linePriceVal.toStringAsFixed(0)}";

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F9),
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(item.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.unit ?? "1 pc",
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF4CA04B),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          CartService().removeItem(item.productId),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(Icons.remove,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.quantity.toString(),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => CartService().addItem(
                          item.productId,
                          item.variantId,
                          item.title,
                          item.imagePath,
                          item.price,
                          originalPrice: item.originalPrice,
                          unit: item.unit),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child:
                            Icon(Icons.add, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    lineOriginalPriceStr,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    linePriceStr,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBeforeYouCheckout() {
    final mockItems = [
      {
        'title': 'Nilara Water 20L',
        'image': 'assets/images/20L daily bulk .png',
        'price': '₹40',
        'original': '₹50'
      },
      {
        'title': 'Nilara Mustard Oil 1L',
        'image': 'assets/images/nilara1lmustardoil.png',
        'price': '₹185',
        'original': '₹210'
      },
      {
        'title': 'Nilara Premium Milk',
        'image': 'assets/images/milk.png',
        'price': '₹75',
        'original': '₹90'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            "Before you checkout",
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: mockItems.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = mockItems[index];
              return Container(
                width: 130,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16)),
                      child: Image.asset(
                        product['image']!,
                        width: 130,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 130,
                          height: 100,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['title']!,
                            style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(product['original']!,
                                  style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      color: Colors.grey.shade400,
                                      decoration:
                                          TextDecoration.lineThrough)),
                              const SizedBox(width: 4),
                              Text(product['price']!,
                                  style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOffersCard() {
    return _buildWhiteCard(
      child: InkWell(
        onTap: () => _showCouponsBottomSheet(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3EFFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_offer_outlined,
                    color: Color(0xFF1E5BB5), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Apply Coupon",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (_appliedCoupon != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        "Saved ₹${_calculateDiscount(0)}",
                        style: GoogleFonts.outfit(
                            fontSize: 12, color: Colors.green.shade600),
                      ),
                    ] else
                      Text(
                        "${_coupons.length} coupon${_coupons.length != 1 ? 's' : ''} available",
                        style: GoogleFonts.outfit(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                  ],
                ),
              ),
              if (_appliedCoupon != null)
                GestureDetector(
                  onTap: () => setState(() => _appliedCoupon = null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text("Remove",
                        style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: Colors.red,
                            fontWeight: FontWeight.bold)),
                  ),
                )
              else
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showCouponsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Available Coupons",
                  style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              const SizedBox(height: 16),
              Expanded(
                child: _coupons.isEmpty
                    ? Center(
                        child: Text("No coupons available",
                            style: GoogleFonts.outfit(
                                color: Colors.grey.shade500)))
                    : ListView.separated(
                        itemCount: _coupons.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final coupon = _coupons[index];
                          final isApplied =
                              _appliedCoupon?['_id'] == coupon['_id'];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: isApplied
                                      ? Colors.green
                                      : Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(12),
                              color: isApplied
                                  ? Colors.green.shade50
                                  : Colors.white,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(coupon['code'] ?? '',
                                          style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: const Color(0xFF1E5BB5))),
                                      const SizedBox(height: 4),
                                      Text(
                                          coupon['description'] ??
                                              "${coupon['discountPercent']}% off",
                                          style: GoogleFonts.outfit(
                                              fontSize: 12,
                                              color: Colors.grey.shade600)),
                                      if (coupon['minOrderValue'] != null)
                                        Text(
                                            "Min order: ₹${coupon['minOrderValue']}",
                                            style: GoogleFonts.outfit(
                                                fontSize: 11,
                                                color: Colors.grey.shade400)),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    double itemTotal = CartService()
                                        .items
                                        .value
                                        .values
                                        .fold(0.0, (sum, item) {
                                      String cleanPrice = item.price
                                          .replaceAll(RegExp(r'[^0-9.]'), '');
                                      double priceVal =
                                          double.tryParse(cleanPrice) ?? 0;
                                      return sum + priceVal * item.quantity;
                                    });
                                    if (itemTotal >=
                                        (coupon['minOrderValue'] ?? 0)) {
                                      setState(() => _appliedCoupon =
                                          isApplied ? null : coupon);
                                      Navigator.pop(context);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Add more items to use this coupon."),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    isApplied ? "REMOVE" : "APPLY",
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      color: isApplied
                                          ? Colors.red
                                          : const Color(0xFF0288D1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeliveryTimeCard() {
    final slots = SettingsService().deliveryTimeSlots.value;
    if (slots.isEmpty) return const SizedBox.shrink();
    
    // Ensure default selection
    if (_deliveryTimePref == null || !slots.contains(_deliveryTimePref)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _deliveryTimePref = slots.first);
      });
    }

    return _buildWhiteCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Preferred Delivery Time",
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: slots.map((slot) {
                final isSelected = _deliveryTimePref == slot;
                return GestureDetector(
                  onTap: () => setState(() => _deliveryTimePref = slot),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE0F2FE) : Colors.white,
                      border: Border.all(
                          color: isSelected ? const Color(0xFF0288D1) : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      slot,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFF0288D1) : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveAtDoorCard() {
    return _buildWhiteCard(
      child: InkWell(
        onTap: () => setState(() => _leaveAtDoor = !_leaveAtDoor),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _leaveAtDoor,
                  onChanged: (val) {
                    if (val != null) setState(() => _leaveAtDoor = val);
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  activeColor: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Leave the order at door or gate",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Opt for no-contact delivery & our delivery partner will leave it at your door/gate.",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillDetailsCard(double itemTotal) {
    double discount = _calculateDiscount(itemTotal);
    final bool isFreeDelivery = itemTotal >= _freeDeliveryMinAmount;

    return _buildWhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bill Details",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Item Total",
                        style: GoogleFonts.outfit(
                            fontSize: 12, color: Colors.black87)),
                    Text("₹${itemTotal.toStringAsFixed(2)}",
                        style: GoogleFonts.outfit(
                            fontSize: 12, color: Colors.black87)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Handling Charge",
                        style: GoogleFonts.outfit(
                            fontSize: 12, color: Colors.black87)),
                    Text("₹${_handlingCharge.toStringAsFixed(2)}",
                        style: GoogleFonts.outfit(
                            fontSize: 12, color: Colors.black87)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Delivery Fee",
                            style: GoogleFonts.outfit(
                                fontSize: 12, color: Colors.black87)),
                        if (isFreeDelivery)
                          Text(
                            "Free above ₹${_freeDeliveryMinAmount.toStringAsFixed(0)}",
                            style: GoogleFonts.outfit(
                                fontSize: 10, color: Colors.green.shade600),
                          ),
                      ],
                    ),
                    isFreeDelivery
                        ? Row(children: [
                            Text(
                              "₹${_deliveryFee.toStringAsFixed(2)}",
                              style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                  decoration: TextDecoration.lineThrough),
                            ),
                            const SizedBox(width: 6),
                            Text("FREE",
                                style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.green.shade600,
                                    fontWeight: FontWeight.bold)),
                          ])
                        : Text("₹${_deliveryFee.toStringAsFixed(2)}",
                            style: GoogleFonts.outfit(
                                fontSize: 12, color: Colors.black87)),
                  ],
                ),
                if (discount > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Coupon Discount",
                          style: GoogleFonts.outfit(
                              fontSize: 12, color: Colors.red)),
                      Text("-₹${discount.toStringAsFixed(2)}",
                          style: GoogleFonts.outfit(
                              fontSize: 12, color: Colors.red)),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Grand Total",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "₹${(itemTotal + _handlingCharge + (isFreeDelivery ? 0 : _deliveryFee) - discount).toStringAsFixed(2)}",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateDiscount(double itemTotal) {
    if (_appliedCoupon == null) return 0.0;

    if (itemTotal < (_appliedCoupon!['minOrderValue'] ?? 0)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _appliedCoupon = null);
      });
      return 0.0;
    }

    double discount = 0;
    double percent =
        (_appliedCoupon!['discountPercent'] ?? 0).toDouble();
    if (percent > 0) {
      discount = (itemTotal * percent) / 100;
    }
    double maxDiscount =
        (_appliedCoupon!['maxDiscountAmount'] ?? 0).toDouble();

    if (maxDiscount > 0 && discount > maxDiscount) {
      discount = maxDiscount;
    }

    if (percent == 0 && maxDiscount > 0) {
      discount = maxDiscount;
    }

    return discount;
  }
}
