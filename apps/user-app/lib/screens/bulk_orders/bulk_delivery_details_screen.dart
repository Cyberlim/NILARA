import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bulk_order_summary_screen.dart';
import '../../services/address_service.dart';
import '../add_edit_address_screen.dart';

class BulkDeliveryDetailsScreen extends StatefulWidget {
  final String productName;
  final int quantity;
  final double totalPrice;
  final Map<String, dynamic>? customDesign;

  const BulkDeliveryDetailsScreen({
    super.key,
    required this.productName,
    required this.quantity,
    required this.totalPrice,
    this.customDesign,
  });

  @override
  State<BulkDeliveryDetailsScreen> createState() => _BulkDeliveryDetailsScreenState();
}

class _BulkDeliveryDetailsScreenState extends State<BulkDeliveryDetailsScreen> {
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  final TextEditingController _instructionsController = TextEditingController();
  Address? _selectedAddress;

  final List<String> _timeSlots = ['Morning (6 AM - 12 PM)', 'Afternoon (12 PM - 5 PM)', 'Evening (5 PM - 9 PM)'];

  @override
  void initState() {
    super.initState();
    _autoSelectAddress();
    AddressService().addresses.addListener(_autoSelectAddress);
  }

  void _autoSelectAddress() {
    if (_selectedAddress == null) {
      final addresses = AddressService().addresses.value;
      if (addresses.isNotEmpty) {
        setState(() {
          _selectedAddress = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0288D1),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    AddressService().addresses.removeListener(_autoSelectAddress);
    _instructionsController.dispose();
    super.dispose();
  }

  void _showAddressBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return ValueListenableBuilder<List<Address>>(
          valueListenable: AddressService().addresses,
          builder: (context, addresses, _) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select Delivery Address",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (addresses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("No addresses found."),
                    ),
                  ...addresses.map((address) {
                    final isSelected = _selectedAddress?.id == address.id;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.location_on,
                        color: isSelected ? const Color(0xFF0288D1) : Colors.grey,
                      ),
                      title: Text(
                        address.title,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        address.fullAddress,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Color(0xFF0288D1))
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedAddress = address;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showAddAddressBottomSheet();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0288D1)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Add New Address",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0288D1),
                        ),
                      ),
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

  void _showAddAddressBottomSheet() async {
    final bool? added = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditAddressScreen()),
    );
    if (added == true) {
      final addresses = AddressService().addresses.value;
      if (addresses.isNotEmpty) {
        setState(() {
          _selectedAddress = addresses.last;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Delivery Details",
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Where and when would you like your order?",
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              
              // Address Section
              Text(
                "Delivery Address",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _selectedAddress == null 
                  ? Text("No address selected", style: GoogleFonts.outfit(color: Colors.grey))
                  : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF0288D1)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedAddress!.title,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedAddress!.fullAddress,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _showAddressBottomSheet,
                      child: Text(
                        "Change",
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0288D1),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _showAddAddressBottomSheet,
                child: Row(
                  children: [
                    const Icon(Icons.add, color: Color(0xFF0288D1), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Add New Address",
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0288D1),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Delivery Date
              Text(
                "Delivery Date",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null 
                          ? "Select Date" 
                          : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: _selectedDate == null ? Colors.grey.shade500 : Colors.black87,
                          fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.calendar_month, color: Colors.grey.shade600),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Time Slot
              Text(
                "Preferred Time Slot",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: _timeSlots.map((slot) {
                  final isSelected = _selectedTimeSlot == slot;
                  final isMorning = slot.startsWith('Morning');
                  final isAfternoon = slot.startsWith('Afternoon');
                  final icon = isMorning ? Icons.wb_sunny_outlined : (isAfternoon ? Icons.wb_twilight : Icons.nights_stay_outlined);
                  
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTimeSlot = slot),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF0288D1) : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(icon, color: isSelected ? const Color(0xFF0288D1) : Colors.grey.shade600, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              slot,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? const Color(0xFF0288D1) : Colors.black87,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Color(0xFF0288D1), size: 20),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 32),
              
              // Special Instructions
              Text(
                "Special Instructions (Optional)",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _instructionsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "E.g. Call before delivery, place at reception, loading dock etc.",
                  hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF0288D1)),
                  ),
                ),
              ),
              
              const SizedBox(height: 100), // Padding for bottom bar
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_selectedAddress == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a delivery address')));
                  return;
                }
                if (_selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a delivery date')));
                  return;
                }
                if (_selectedTimeSlot == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a preferred time slot')));
                  return;
                }
                
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => BulkOrderSummaryScreen(
                      productName: widget.productName,
                      quantity: widget.quantity,
                      totalPrice: widget.totalPrice,
                      deliveryDate: "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                      timeSlot: _selectedTimeSlot!,
                      selectedAddress: _selectedAddress!.toJson(),
                      specialInstructions: _instructionsController.text.trim(),
                      customDesign: widget.customDesign,
                    ),
                  )
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0288D1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                "Continue",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
