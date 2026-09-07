import re

with open("lib/screens/dashboard_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

import_str = "import 'wallet_tab.dart';\n"
if "import 'wallet_tab.dart';" not in content:
    content = content.replace("import 'profile_tab.dart';", "import 'profile_tab.dart';\n" + import_str)

old_screens = """  final List<Widget> _screens = [
    const HomeTab(),
    const NewOrderScreen(),
    const ProfileTab(),
  ];"""

new_screens = """  final List<Widget> _screens = [
    const HomeTab(),
    const NewOrderScreen(),
    const WalletTab(),
    const ProfileTab(),
  ];"""

old_nav = """        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.delivery_dining), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'New'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],"""

new_nav = """        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.delivery_dining), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'New'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],"""

content = content.replace(old_screens, new_screens)
content = content.replace(old_nav, new_nav)

# The BottomNavigationBar type might need to be fixed if there are more than 3 items, it defaults to shifting. 
# We need `type: BottomNavigationBarType.fixed`
old_nav_type = "        currentIndex: _currentIndex,"
new_nav_type = "        type: BottomNavigationBarType.fixed,\n        currentIndex: _currentIndex,"
if "type: BottomNavigationBarType.fixed" not in content:
    content = content.replace(old_nav_type, new_nav_type)

with open("lib/screens/dashboard_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
