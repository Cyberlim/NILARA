import re

with open("lib/screens/ticket_list_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

old_build = """  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("My Tickets", style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF168BDB)))
          : _tickets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text("No tickets found.", style: GoogleFonts.outfit(color: Colors.grey.shade600)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = _tickets[index];
                    final isOpen = ticket['status'] == 'open';
                    
                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                ticketId: ticket['_id'],
                                ticketSubject: ticket['subject'],
                                isClosed: !isOpen,
                              ),
                            ),
                          ).then((_) => _fetchTickets());
                        },
                        title: Text(
                          ticket['subject'] ?? 'No Subject',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          isOpen ? 'Status: Open' : 'Status: Closed',
                          style: GoogleFonts.outfit(color: isOpen ? Colors.green : Colors.red, fontSize: 12),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTicketDialog,
        backgroundColor: const Color(0xFF168BDB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text("New Ticket", style: GoogleFonts.outfit(color: Colors.white)),
      ),
    );
  }"""

new_build = """  @override
  Widget build(BuildContext context) {
    final openTickets = _tickets.where((t) => t['status'] == 'open').toList();
    final closedTickets = _tickets.where((t) => t['status'] == 'closed' || t['status'] == 'history').toList();

    Widget buildList(List<dynamic> list, String emptyMessage) {
      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(emptyMessage, style: GoogleFonts.outfit(color: Colors.grey.shade600)),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final ticket = list[index];
          final isOpen = ticket['status'] == 'open';
          
          return Card(
            color: Colors.white,
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      ticketId: ticket['_id'],
                      ticketSubject: ticket['subject'],
                      isClosed: !isOpen,
                    ),
                  ),
                ).then((_) => _fetchTickets());
              },
              title: Text(
                ticket['subject'] ?? 'No Subject',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                isOpen ? 'Status: Open' : 'Status: Closed',
                style: GoogleFonts.outfit(color: isOpen ? Colors.green : Colors.red, fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text("My Tickets", style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.black87),
          bottom: TabBar(
            indicatorColor: const Color(0xFF168BDB),
            labelColor: const Color(0xFF168BDB),
            unselectedLabelColor: Colors.grey.shade600,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "Open"),
              Tab(text: "History"),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF168BDB)))
            : TabBarView(
                children: [
                  buildList(openTickets, "No open tickets found."),
                  buildList(closedTickets, "No history found."),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showCreateTicketDialog,
          backgroundColor: const Color(0xFF168BDB),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text("New Ticket", style: GoogleFonts.outfit(color: Colors.white)),
        ),
      ),
    );
  }"""

content = content.replace(old_build, new_build)

with open("lib/screens/ticket_list_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
