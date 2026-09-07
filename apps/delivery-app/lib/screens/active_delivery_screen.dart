import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'order_delivered_screen.dart';
import '../services/delivery_service.dart';


class ActiveDeliveryScreen extends StatefulWidget {
  const ActiveDeliveryScreen({super.key});

  @override
  State<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends State<ActiveDeliveryScreen> {
  final LatLng _storeLocation = const LatLng(28.6200, 77.3639); 
  final LatLng _customerLocation = const LatLng(28.5900, 77.4400); 
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    final url = 'http://router.project-osrm.org/route/v1/driving/${_storeLocation.longitude},${_storeLocation.latitude};${_customerLocation.longitude},${_customerLocation.latitude}?overview=full&geometries=geojson';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
        setState(() {
          _routePoints = coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
        });
      }
    } catch (e) {
      // Fallback to straight line
      setState(() {
        _routePoints = [_storeLocation, _customerLocation];
      });
    }
  }

  void _showOtpBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 32,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Enter Delivery PIN",
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                "Ask the customer for the 4-digit PIN",
                style: GoogleFonts.outfit(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              
              // OTP Input Fields (Visual only for prototype)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) => Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    "•",
                    style: GoogleFonts.outfit(fontSize: 32, color: Colors.black87),
                  ),
                )),
              ),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final order = DeliveryService().activeOrder.value;
                    if (order != null) {
                      final success = await DeliveryService().updateDeliveryStatus(order['_id'], 'delivered');
                      if (success && context.mounted) {
                        Navigator.pop(context); // Close bottom sheet
                        Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(builder: (context) => const OrderDeliveredScreen())
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E9C1C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text("Verify & Complete", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      }
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
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("On the Way", style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Stack(
        children: [
          // MAP (Bottom Layer) - Beautiful White Theme
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(28.6050, 77.4019),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.cyberlim.delivery',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints.isEmpty ? [_storeLocation, _customerLocation] : _routePoints,
                      strokeWidth: 5.0,
                      color: const Color(0xFF1E9C1C), // Cyberlim green route
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _storeLocation,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset('assets/images/rider.png'), // Reusing rider avatar as map marker
                        ),
                      ),
                    ),
                    Marker(
                      point: _customerLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // TOP OVERLAY CARD
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Deliver to", style: GoogleFonts.outfit(color: Colors.black54, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text("Rohit Kumar", style: GoogleFonts.outfit(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text("A-1204, Supertech Eco Village 1,\nNoida, Uttar Pradesh", style: GoogleFonts.outfit(color: Colors.black54, fontSize: 13, height: 1.4)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.call_outlined, color: Colors.black87, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.message_outlined, color: Colors.black87, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // BOTTOM PANEL
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Time Left", style: GoogleFonts.outfit(color: Colors.black54, fontSize: 14)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text("12", style: GoogleFonts.outfit(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(" mins", style: GoogleFonts.outfit(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(height: 40, width: 1, color: Colors.grey.shade300),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Distance", style: GoogleFonts.outfit(color: Colors.black54, fontSize: 14)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text("2.1", style: GoogleFonts.outfit(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold)),
                            Text(" km", style: GoogleFonts.outfit(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: _showOtpBottomSheet,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1E9C1C),
                  side: const BorderSide(color: Color(0xFF1E9C1C), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  "Reached Drop Location",
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E9C1C)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
