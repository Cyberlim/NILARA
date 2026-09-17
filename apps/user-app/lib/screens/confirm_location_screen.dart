import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'main_navigation_screen.dart';

class ConfirmLocationScreen extends StatefulWidget {
  const ConfirmLocationScreen({super.key});

  @override
  State<ConfirmLocationScreen> createState() => _ConfirmLocationScreenState();
}

class _ConfirmLocationScreenState extends State<ConfirmLocationScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(28.6139, 77.2090); // Default: New Delhi
  bool _isMapReady = false;
  bool _isFetchingLocation = true;
  bool _isFormExpanded = true; // Set to true by default to show full UI
  String _currentAddress = "Fetching address details...";
  String _currentTitle = "Current Location";

  late AnimationController _markerAnimationController;
  late Animation<double> _markerScaleAnimation;

  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  List<dynamic> _suggestions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _markerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _markerScaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _markerAnimationController, curve: Curves.easeInOut),
    );

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearching = _searchFocusNode.hasFocus;
      });
    });

    _fetchCurrentLocation();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _fetchSuggestions(query);
      } else {
        setState(() {
          _suggestions = [];
        });
      }
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _suggestions = json.decode(response.body);
        });
      }
    } catch (e) {
      // Silently handle error
    }
  }

  void _onSuggestionSelected(dynamic suggestion) {
    _searchFocusNode.unfocus();
    _searchController.clear();
    setState(() {
      _suggestions = [];
      _isSearching = false;
    });

    final double lat = double.parse(suggestion['lat']);
    final double lon = double.parse(suggestion['lon']);
    final String displayName = suggestion['display_name'];

    setState(() {
      _currentLocation = LatLng(lat, lon);
      _currentAddress = displayName;
      _currentTitle = suggestion['name'] ?? displayName.split(',')[0];
    });

    _mapController.move(_currentLocation, 16.0);
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isFetchingLocation = false;
        _currentTitle = "Your Location";
      });
      
      if (_isMapReady) {
        _mapController.move(_currentLocation, 16.0);
      }

      // Reverse geocoding using OSM Nominatim API (No native SDK dependencies required)
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}');
      final response = await http.get(url, headers: {'User-Agent': 'BlinkitCloneApp'});
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] as Map<String, dynamic>?;
        
        if (address != null) {
          setState(() {
            final road = address['road'] ?? address['street'] ?? '';
            final subLocality = address['suburb'] ?? address['neighbourhood'] ?? '';
            final locality = address['city'] ?? address['town'] ?? address['village'] ?? '';
            final postalCode = address['postcode'] ?? '';
            final country = address['country'] ?? '';
            
            _currentAddress = "$road, $subLocality, $locality, $postalCode, $country";
            _currentAddress = _currentAddress.replaceAll(RegExp(r'^,\s*'), '').replaceAll(RegExp(r',\s*,'), ',');
          });
        }
      }
    } catch (e) {
      setState(() {
        _isFetchingLocation = false;
        _currentAddress = "Unable to fetch address. Please allow location access.";
      });
    }
  }

  @override
  void dispose() {
    _markerAnimationController.dispose();
    _houseController.dispose();
    _floorController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _showChangeLocationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Search Delivery Location",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search building, area or street",
                    hintStyle: GoogleFonts.outfit(color: Colors.black38),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF006DFF)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  autofocus: true,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.my_location, color: Color(0xFF006DFF)),
                title: Text(
                  "Use current location",
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF006DFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  _currentAddress,
                  style: GoogleFonts.outfit(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _fetchCurrentLocation();
                },
              )
            ],
          ),
        );
      },
    );
  }

  void _showAddressDetailsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      )..forward(),
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Enter complete address",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "This allows us to find you easily and deliver faster.",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _houseController,
                  decoration: InputDecoration(
                    labelText: "House no. / Flat no. / Building",
                    labelStyle: GoogleFonts.outfit(color: Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF8A2BE2)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _floorController,
                  decoration: InputDecoration(
                    labelText: "Floor (Optional)",
                    labelStyle: GoogleFonts.outfit(color: Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF8A2BE2)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close sheet
                      
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8A2BE2),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Save Address",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Confirm location",
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Flutter Map
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation,
                initialZoom: 16.0,
                onMapReady: () {
                  setState(() {
                    _isMapReady = true;
                  });
                  if (!_isFetchingLocation) {
                    _mapController.move(_currentLocation, 16.0);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.blinkitclone',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation,
                      width: 80,
                      height: 80,
                      child: AnimatedBuilder(
                        animation: _markerScaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _markerScaleAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF8A2BE2).withOpacity(0.3),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.location_on,
                                  color: Color(0xFF8A2BE2),
                                  size: 40,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Top Gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // Search Bar over Map
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Icon(Icons.search, color: Colors.black54),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: (val) {
                            setState(() {}); // For close icon visibility
                            _onSearchChanged(val);
                          },
                          decoration: InputDecoration(
                            hintText: "Search for a new address...",
                            hintStyle: GoogleFonts.outfit(color: Colors.black54),
                            border: InputBorder.none,
                          ),
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black54),
                          onPressed: () {
                            _searchController.clear();
                            _searchFocusNode.unfocus();
                            setState(() {
                              _suggestions = [];
                            });
                          },
                        )
                    ],
                  ),
                ),
                // Suggestions Dropdown
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _suggestions.isNotEmpty && _isSearching
                      ? Container(
                          margin: const EdgeInsets.only(top: 8),
                          constraints: const BoxConstraints(maxHeight: 250),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: _suggestions.length,
                            itemBuilder: (context, index) {
                              final suggestion = _suggestions[index];
                              return ListTile(
                                leading: const Icon(Icons.location_on, color: Color(0xFF8A2BE2)),
                                title: Text(
                                  suggestion['name'] ?? suggestion['display_name'].split(',')[0],
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  suggestion['display_name'],
                                  style: GoogleFonts.outfit(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () => _onSuggestionSelected(suggestion),
                              );
                            },
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // Go to current location button
          Positioned(
            bottom: _isFormExpanded ? 260 : 220,
            right: 16,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: FloatingActionButton(
                onPressed: _fetchCurrentLocation,
                backgroundColor: Colors.white,
                elevation: 4,
                child: const Icon(Icons.my_location, color: Color(0xFF8A2BE2)),
              ),
            ),
          ),

          // Bottom UI Panel with Gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              height: _isFormExpanded ? 240 : 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.6, 1.0],
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isFormExpanded) ...[
                      Text(
                        "Delivering your order to",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF8A2BE2), size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentTitle,
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currentAddress,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: _showChangeLocationSheet,
                            child: Text(
                              "Change",
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF8A2BE2),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _showAddressDetailsSheet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8A2BE2),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Confirm Location",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
