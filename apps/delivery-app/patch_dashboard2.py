import re

with open("lib/screens/dashboard_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("import 'wallet_tab.dart';", "import 'earnings_tab.dart';\nimport '../services/wallet_service.dart';")
content = content.replace("const WalletTab(),", "const EarningsTab(),")

# Fetch wallet data when dashboard initializes
init_str = """  @override
  void initState() {
    super.initState();
    WalletService.instance.fetchWalletData();"""
    
content = content.replace("  @override\n  void initState() {\n    super.initState();", init_str)

with open("lib/screens/dashboard_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
