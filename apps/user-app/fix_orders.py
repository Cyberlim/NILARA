import re

with open("lib/screens/orders_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Fix normal orders list
old_normal_orders = """              _buildTopBanner(),
              const SizedBox(height: 24),
              Text(
                "Past Orders",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<List<Order>>(
                valueListenable: OrderService().orders,
                builder: (context, orders, child) {
                  if (orders.isEmpty) {
                    return Center(
                      child: Text(
                        "No orders yet.",
                        style: GoogleFonts.outfit(color: Colors.grey.shade600),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order)),
                          );
                        },
                        child: _buildOrderCard(
                          orderId: order.orderNumber,
                          date: order.date,
                          status: order.status,
                          statusColor: order.status == "Delivered" ? Colors.green : (order.status == "Cancelled" ? Colors.red : Colors.orange),
                          items: order.itemsSummary,
                          total: "?${order.total.toStringAsFixed(2)}",
                          images: const ["assets/images/qb4.jpg"], // Fixed placeholder
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 40),"""

new_normal_orders = """              _buildTopBanner(),
              const SizedBox(height: 24),
              ValueListenableBuilder<List<Order>>(
                valueListenable: OrderService().orders,
                builder: (context, orders, child) {
                  if (orders.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Text(
                          "No orders yet.",
                          style: GoogleFonts.outfit(color: Colors.grey.shade600),
                        ),
                      ),
                    );
                  }
                  
                  final ongoingOrders = orders.where((o) => o.status.toLowerCase() != 'delivered' && o.status.toLowerCase() != 'cancelled').toList();
                  final pastOrders = orders.where((o) => o.status.toLowerCase() == 'delivered' || o.status.toLowerCase() == 'cancelled').toList();

                  Widget buildList(List<Order> list) {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final order = list[index];
                        final st = order.status.toLowerCase();
                        final statusColor = st == "delivered" ? Colors.green : (st == "cancelled" ? Colors.red : Colors.orange);
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order)),
                            );
                          },
                          child: _buildOrderCard(
                            orderId: order.orderNumber,
                            date: order.date,
                            status: order.status.toUpperCase(),
                            statusColor: statusColor,
                            items: order.itemsSummary,
                            total: "?${order.total.toStringAsFixed(2)}",
                            images: const ["assets/images/qb4.jpg"],
                          ),
                        );
                      },
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (ongoingOrders.isNotEmpty) ...[
                        Text(
                          "Ongoing Orders",
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        buildList(ongoingOrders),
                        const SizedBox(height: 24),
                      ],
                      if (pastOrders.isNotEmpty) ...[
                        Text(
                          "Past Orders",
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        buildList(pastOrders),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),"""

content = content.replace(old_normal_orders, new_normal_orders)

# Fix bulk orders list
old_bulk_orders = """            // Pill Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterPill("All", _selectedBulkFilter == "All"),
                  const SizedBox(width: 8),
                  _buildFilterPill("Processing", _selectedBulkFilter == "Processing"),
                  const SizedBox(width: 8),
                  _buildFilterPill("Delivered", _selectedBulkFilter == "Delivered"),
                  const SizedBox(width: 8),
                  _buildFilterPill("Cancelled", _selectedBulkFilter == "Cancelled"),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            ValueListenableBuilder<List<dynamic>>(
              valueListenable: BulkOrderService().myBulkOrders,
              builder: (context, bulkOrders, _) {
                // Filter locally
                final filteredOrders = bulkOrders.where((order) {
                  if (_selectedBulkFilter == "All") return true;
                  return order['status'] == _selectedBulkFilter;
                }).toList();

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Text(
                        "No $_selectedBulkFilter bulk orders found.",
                        style: GoogleFonts.outfit(color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredOrders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    
                    // Safely extract date
                    String formattedDate = "N/A";
                    if (order['createdAt'] != null) {
                      final dt = DateTime.parse(order['createdAt']);
                      formattedDate = "${dt.day}/${dt.month}/${dt.year}";
                    }
                    
                    // Map generic image based on product name if possible
                    bool isJar = (order['productName'] ?? "").toString().contains('Jar');
                    final imagePath = isJar ? 'assets/images/20L daily bulk .png' : 'assets/images/qb4.jpg';

                    final String orderIdStr = order['_id'] != null 
                      ? "#${order['_id'].substring(order['_id'].length - 8).toUpperCase()}" 
                      : "#UNKNOWN";

                    return _buildBulkOrderCard(
                      context: context,
                      orderId: orderIdStr,
                      rawOrderId: order['_id'] ?? "",
                      date: formattedDate,
                      status: order['status'] ?? "Pending",
                      productName: order['productName'] ?? "Unknown Product",
                      quantity: "${order['quantity']} Items",
                      price: "?${order['totalPrice']?.toStringAsFixed(2) ?? '0.00'}",
                      imagePath: imagePath,
                      deliveryDate: order['deliveryDate'] ?? "N/A",
                      deliveryTime: order['timeSlot'] ?? "N/A",
                      addressTitle: order['address']?['title'] ?? "Delivery Address",
                      addressDetail: order['address']?['line1'] ?? "Address details not available",
                      adminMessage: order['adminMessage'],
                      advancePayment: order['advancePayment'],
                      remainingPayment: order['remainingPayment'],
                      advancePaid: order['advancePaid'] ?? false,
                      onPaymentSuccess: () {
                        // Refresh the list after successful payment
                        BulkOrderService().fetchMyBulkOrders();
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 40),"""

new_bulk_orders = """            ValueListenableBuilder<List<dynamic>>(
              valueListenable: BulkOrderService().myBulkOrders,
              builder: (context, bulkOrders, _) {
                if (bulkOrders.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Text(
                        "No bulk orders found.",
                        style: GoogleFonts.outfit(color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }

                final ongoingOrders = bulkOrders.where((order) {
                  final status = (order['status'] ?? "").toString().toLowerCase();
                  return status != 'delivered' && status != 'cancelled';
                }).toList();

                final pastOrders = bulkOrders.where((order) {
                  final status = (order['status'] ?? "").toString().toLowerCase();
                  return status == 'delivered' || status == 'cancelled';
                }).toList();

                Widget buildList(List<dynamic> list) {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final order = list[index];
                      
                      String formattedDate = "N/A";
                      if (order['createdAt'] != null) {
                        final dt = DateTime.parse(order['createdAt']);
                        formattedDate = "${dt.day}/${dt.month}/${dt.year}";
                      }
                      
                      bool isJar = (order['productName'] ?? "").toString().contains('Jar');
                      final imagePath = isJar ? 'assets/images/20L daily bulk .png' : 'assets/images/qb4.jpg';

                      final String orderIdStr = order['_id'] != null 
                        ? "#${order['_id'].substring(order['_id'].length - 8).toUpperCase()}" 
                        : "#UNKNOWN";

                      return _buildBulkOrderCard(
                        context: context,
                        orderId: orderIdStr,
                        rawOrderId: order['_id'] ?? "",
                        date: formattedDate,
                        status: order['status'] ?? "Pending",
                        productName: order['productName'] ?? "Unknown Product",
                        quantity: "${order['quantity']} Items",
                        price: "?${order['totalPrice']?.toStringAsFixed(2) ?? '0.00'}",
                        imagePath: imagePath,
                        deliveryDate: order['deliveryDate'] ?? "N/A",
                        deliveryTime: order['timeSlot'] ?? "N/A",
                        addressTitle: order['address']?['title'] ?? "Delivery Address",
                        addressDetail: order['address']?['line1'] ?? "Address details not available",
                        adminMessage: order['adminMessage'],
                        advancePayment: order['advancePayment'],
                        remainingPayment: order['remainingPayment'],
                        advancePaid: order['advancePaid'] ?? false,
                        onPaymentSuccess: () {
                          BulkOrderService().fetchMyBulkOrders();
                        },
                      );
                    },
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (ongoingOrders.isNotEmpty) ...[
                      Text(
                        "Ongoing Orders",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      buildList(ongoingOrders),
                      const SizedBox(height: 24),
                    ],
                    if (pastOrders.isNotEmpty) ...[
                      Text(
                        "Past Orders",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      buildList(pastOrders),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 40),"""

content = content.replace(old_bulk_orders, new_bulk_orders)

with open("lib/screens/orders_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
