import re

with open("lib/screens/orders_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Add import
imports = """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../services/order_service.dart';"""
content = content.replace("import 'package:flutter/material.dart';\nimport 'package:google_fonts/google_fonts.dart';\nimport '../services/order_service.dart';", imports)

old_gesture = """                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderDetailsScreen(orderId: order.id),
                            ),
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
                        );"""

new_gesture = """                      return Slidable(
                        key: ValueKey(order.id),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.25,
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                final success = await OrderService().hideOrder(order.id);
                                if (!success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Failed to delete order history')),
                                  );
                                }
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderDetailsScreen(orderId: order.id),
                              ),
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
                        ),
                      );"""
content = content.replace(old_gesture, new_gesture)

with open("lib/screens/orders_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
