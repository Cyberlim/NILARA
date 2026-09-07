import re

with open("lib/screens/splash_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

import_str = "import 'login_screen.dart';\nimport 'dashboard_screen.dart';\nimport '../services/user_service.dart';\n"
content = content.replace("import 'onboarding_screen.dart';", "import 'onboarding_screen.dart';\n" + import_str)

old_nav = """    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OnboardingScreen()));
      }
    });"""

new_nav = """    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        if (UserService().token.value != null) {
          final isComplete = UserService().currentUser.value?.onboardingComplete ?? false;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => isComplete ? const DashboardScreen() : const OnboardingScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    });"""

content = content.replace(old_nav, new_nav)

with open("lib/screens/splash_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
