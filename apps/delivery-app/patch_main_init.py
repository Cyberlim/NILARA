import re

with open("lib/main.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Add UserService import
content = content.replace("import 'screens/splash_screen.dart';", "import 'screens/splash_screen.dart';\nimport 'services/user_service.dart';")

# Init UserService
old_main = """void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const NilaraDeliveryApp());
}"""

new_main = """void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await UserService().init();
  runApp(const NilaraDeliveryApp());
}"""
content = content.replace(old_main, new_main)

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(content)
