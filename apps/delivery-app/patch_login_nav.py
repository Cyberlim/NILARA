import re

with open("lib/screens/login_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

import_str = "import 'onboarding_screen.dart';\n"
content = content.replace("import 'dashboard_screen.dart';", "import 'dashboard_screen.dart';\n" + import_str)

old_nav = """        if (success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        } else {"""

new_nav = """        if (success) {
          final isComplete = UserService().currentUser.value?.onboardingComplete ?? false;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => isComplete ? const DashboardScreen() : const OnboardingScreen()),
          );
        } else {"""

content = content.replace(old_nav, new_nav)

with open("lib/screens/login_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
