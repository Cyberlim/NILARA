import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/address_service.dart';
import 'add_edit_address_screen.dart';
class SavedAddressesScreen extends StatelessWidget {
  const SavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          "Saved Addresses",
          style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: ValueListenableBuilder<List<Address>>(
        valueListenable: AddressService().addresses,
        builder: (context, addresses, child) {
          if (addresses.isEmpty) {
            return Center(
              child: Text(
                "No saved addresses.",
                style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 16),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final address = addresses[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: address.isDefault ? const Color(0xFF168BDB).withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: address.isDefault ? const Color(0xFF168BDB) : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      address.title.toLowerCase() == 'home'
                          ? Icons.home
                          : (address.title.toLowerCase() == 'work' ? Icons.work : Icons.location_on),
                      color: address.isDefault ? const Color(0xFF168BDB) : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                address.title,
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              if (address.isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF168BDB),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "DEFAULT",
                                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (address.recipientName.isNotEmpty) ...[
                            Text(
                              "${address.recipientName} | ${address.phone}",
                              style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            address.fullAddress,
                            style: GoogleFonts.outfit(color: Colors.grey.shade700, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddEditAddressScreen(existingAddress: address),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Edit",
                                  style: GoogleFonts.outfit(color: const Color(0xFF168BDB), fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: () => AddressService().deleteAddress(address.id),
                                child: Text(
                                  "Delete",
                                  style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (!address.isDefault) ...[
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () => AddressService().setDefault(address.id),
                                  child: Text(
                                    "Set as Default",
                                    style: GoogleFonts.outfit(color: const Color(0xFF168BDB), fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddEditAddressScreen(autoFetchLocation: true),
                  ),
                );
              },
              icon: const Icon(Icons.my_location, color: Color(0xFF6FB353)),
              label: Text("Use Current Location", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF6FB353))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF6FB353), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddEditAddressScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF168BDB),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Add New Address", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
