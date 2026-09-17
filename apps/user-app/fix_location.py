import re

with open("lib/screens/add_edit_address_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

# 1. Imports
imports = """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../services/address_service.dart';
"""
content = re.sub(r"import 'package:flutter/material\.dart';\nimport 'package:google_fonts/google_fonts\.dart';\nimport '\.\./services/address_service\.dart';", imports, content)

# 2. State variables
state_vars = """  bool _isDefault = false;
  bool _isLoading = false;
  bool _isFetchingLocation = false;
  List<double> _coordinates = [77.2090, 28.6139];"""
content = content.replace("  bool _isDefault = false;\n  bool _isLoading = false;", state_vars)

# 3. Init state coordinates
init_coords = """    _postalCodeController = TextEditingController(text: widget.existingAddress?.postalCode ?? '');
    _isDefault = widget.existingAddress?.isDefault ?? false;
    _coordinates = widget.existingAddress?.coordinates ?? [77.2090, 28.6139];"""
content = content.replace("    _postalCodeController = TextEditingController(text: widget.existingAddress?.postalCode ?? '');\n    _isDefault = widget.existingAddress?.isDefault ?? false;", init_coords)


# 4. _getCurrentLocation function
loc_func = """  Future<void> _getCurrentLocation() async {
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

  Future<void> _saveAddress() async {"""
content = content.replace("  Future<void> _saveAddress() async {", loc_func)

# 5. Fix coordinates in _saveAddress
save_coords = """      isDefault: _isDefault,
      coordinates: _coordinates,"""
content = content.replace("      isDefault: _isDefault,\n      coordinates: widget.existingAddress?.coordinates ?? [77.2090, 28.6139], // Keep existing or default to New Delhi", save_coords)

# 6. Button in UI
btn_ui = """              _buildSectionTitle("Address Details"),
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
              const SizedBox(height: 24),"""
content = content.replace("""              _buildSectionTitle("Address Details"),
              const SizedBox(height: 12),""", btn_ui, 1)

with open("lib/screens/add_edit_address_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
