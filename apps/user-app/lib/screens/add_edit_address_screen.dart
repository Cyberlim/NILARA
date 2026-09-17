import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../services/address_service.dart';


import '../services/user_service.dart';

class AddEditAddressScreen extends StatefulWidget {
  final Address? existingAddress;
  final bool isOrderingForSomeoneElse;
  final bool autoFetchLocation;

  const AddEditAddressScreen({
    Key? key, 
    this.existingAddress,
    this.isOrderingForSomeoneElse = false,
    this.autoFetchLocation = false,
  }) : super(key: key);

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressLine1Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;

  bool _isDefault = false;
  bool _isLoading = false;
  bool _isFetchingLocation = false;
  List<double> _coordinates = [77.2090, 28.6139];

  @override
  void initState() {
    super.initState();
    final userProfile = UserService().profile.value;
    if (widget.autoFetchLocation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getCurrentLocation();
      });
    }
    
    _titleController = TextEditingController(text: widget.existingAddress?.title ?? '');
    
    String initialName = widget.existingAddress?.recipientName ?? '';
    String initialPhone = widget.existingAddress?.phone ?? '';
    
    if (widget.existingAddress == null && !widget.isOrderingForSomeoneElse) {
      initialName = userProfile.name;
      initialPhone = userProfile.phone;
    }
    
    _nameController = TextEditingController(text: initialName);
    _phoneController = TextEditingController(text: initialPhone);
    _addressLine1Controller = TextEditingController(text: widget.existingAddress?.addressLine1 ?? '');
    _cityController = TextEditingController(text: widget.existingAddress?.city ?? '');
    _stateController = TextEditingController(text: widget.existingAddress?.state ?? '');
    _postalCodeController = TextEditingController(text: widget.existingAddress?.postalCode ?? '');
    _isDefault = widget.existingAddress?.isDefault ?? false;
    _coordinates = widget.existingAddress?.coordinates ?? [77.2090, 28.6139];

    _titleController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Location permissions denied.');
      }
      if (permission == LocationPermission.deniedForever) throw Exception('Location permissions permanently denied.'); 

      Position position = await Geolocator.getCurrentPosition();
      
      setState(() {
        _coordinates = [position.longitude, position.latitude];
      });

      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}');
      final response = await http.get(url, headers: {'User-Agent': 'NilaraApp/1.0'});
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          String houseNumber = address['house_number'] ?? '';
          String road = address['road'] ?? '';
          String suburb = address['suburb'] ?? '';
          
          List<String> line1Parts = [];
          if (houseNumber.isNotEmpty) line1Parts.add(houseNumber);
          if (road.isNotEmpty) line1Parts.add(road);
          if (suburb.isNotEmpty) line1Parts.add(suburb);
          
          String line1 = line1Parts.join(', ');
          if (line1.isEmpty && data['display_name'] != null) {
             line1 = data['display_name'].toString().split(',').first;
          }

          String city = address['city'] ?? address['town'] ?? address['village'] ?? address['county'] ?? '';
          String state = address['state'] ?? '';
          String postcode = address['postcode'] ?? '';

          setState(() {
            _addressLine1Controller.text = line1;
            _cityController.text = city;
            _stateController.text = state;
            _postalCodeController.text = postcode;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get location: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final address = Address(
      id: widget.existingAddress?.id ?? '',
      title: _titleController.text.trim(),
      recipientName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      addressLine1: _addressLine1Controller.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      isDefault: _isDefault,
      coordinates: _coordinates,
    );

    bool success;
    if (widget.existingAddress == null) {
      success = await AddressService().addAddress(address);
    } else {
      success = await AddressService().updateAddress(address.id, address);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save address. Please try again.'), backgroundColor: Colors.red),
        );
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
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          widget.existingAddress == null ? "Add New Address" : "Edit Address",
          style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Contact Details"),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _nameController,
                label: "Recipient Name",
                icon: Icons.person_outline,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _phoneController,
                label: "Phone Number",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Address Details"),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isFetchingLocation ? null : _getCurrentLocation,
                  icon: _isFetchingLocation 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location, color: Color(0xFF6FB353)),
                  label: Text(
                    _isFetchingLocation ? "Fetching Location..." : "Use Current Location",
                    style: GoogleFonts.outfit(color: const Color(0xFF6FB353), fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF6FB353)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildLabelChip("Home"),
                  const SizedBox(width: 8),
                  _buildLabelChip("Office"),
                  const SizedBox(width: 8),
                  _buildLabelChip("Other"),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _titleController,
                label: "Address Label",
                icon: Icons.label_outline,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _addressLine1Controller,
                label: "Flat / House no / Building / Street",
                icon: Icons.home_outlined,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cityController,
                      label: "City",
                      icon: Icons.location_city_outlined,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _postalCodeController,
                      label: "Pincode",
                      icon: Icons.pin_drop_outlined,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _stateController,
                label: "State",
                icon: Icons.map_outlined,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _isDefault,
                      onChanged: (val) => setState(() => _isDefault = val ?? false),
                      activeColor: const Color(0xFF6FB353),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Set as Default Address",
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6FB353),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          "SAVE ADDRESS",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildLabelChip(String label) {
    bool isSelected = false;
    if (label == 'Other') {
      isSelected = _titleController.text.isNotEmpty && 
                   _titleController.text.toLowerCase() != 'home' && 
                   _titleController.text.toLowerCase() != 'office';
    } else {
      isSelected = _titleController.text.toLowerCase() == label.toLowerCase();
    }
    
    return ActionChip(
      label: Text(label),
      backgroundColor: isSelected ? const Color(0xFF6FB353).withOpacity(0.1) : Colors.grey.shade100,
      side: BorderSide(color: isSelected ? const Color(0xFF6FB353) : Colors.grey.shade300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onPressed: () {
        if (label == 'Other') {
          if (_titleController.text.toLowerCase() == 'home' || _titleController.text.toLowerCase() == 'office') {
            _titleController.text = '';
          }
        } else {
          _titleController.text = label;
        }
      },
      labelStyle: GoogleFonts.outfit(
        color: isSelected ? const Color(0xFF6FB353) : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6FB353), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      style: GoogleFonts.outfit(fontSize: 15, color: Colors.black87),
    );
  }
}
