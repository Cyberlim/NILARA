import re

with open("lib/screens/orders_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Fix normal orders list logic to always show headers
old_normal_logic = """                  return Column(
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
                  );"""

new_normal_logic = """                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ongoing Orders",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (ongoingOrders.isNotEmpty) buildList(ongoingOrders)
                      else Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text("No ongoing orders found.", style: GoogleFonts.outfit(color: Colors.grey.shade600)),
                      ),
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
                      if (pastOrders.isNotEmpty) buildList(pastOrders)
                      else Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text("No past orders found.", style: GoogleFonts.outfit(color: Colors.grey.shade600)),
                      ),
                    ],
                  );"""

content = content.replace(old_normal_logic, new_normal_logic)


old_bulk_logic = """                return Column(
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
                );"""

new_bulk_logic = """                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ongoing Orders",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (ongoingOrders.isNotEmpty) buildList(ongoingOrders)
                    else Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text("No ongoing bulk orders found.", style: GoogleFonts.outfit(color: Colors.grey.shade600)),
                    ),
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
                    if (pastOrders.isNotEmpty) buildList(pastOrders)
                    else Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text("No past bulk orders found.", style: GoogleFonts.outfit(color: Colors.grey.shade600)),
                    ),
                  ],
                );"""

content = content.replace(old_bulk_logic, new_bulk_logic)

with open("lib/screens/orders_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
