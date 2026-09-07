import re

with open("lib/screens/login_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Add UserService import
content = content.replace("import 'dashboard_screen.dart';", "import 'dashboard_screen.dart';\nimport '../services/user_service.dart';")

# Update _handleAuthentication method
old_auth = """  void _handleAuthentication() async {
    // Basic validation
    if (_isSignUpMode) {
      if (_nameController.text.trim().isEmpty) {
        _showSnackBar("Please enter your Full Name");
        return;
      }
      if (_emailController.text.trim().isEmpty || !_emailController.text.contains('@')) {
        _showSnackBar("Please enter a valid Email address");
        return;
      }
      if (_passwordController.text.trim().length < 6) {
        _showSnackBar("Password must be at least 6 characters");
        return;
      }
    } else {
      if (_emailController.text.trim().isEmpty) {
        _showSnackBar("Please enter your Email address");
        return;
      }
      if (_passwordController.text.trim().isEmpty) {
        _showSnackBar("Please enter your Password");
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }"""

new_auth = """  void _handleAuthentication() async {
    // Basic validation
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar("Please enter your Email address");
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      _showSnackBar("Please enter your Password");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await UserService().login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        _showSnackBar("Login failed. Check credentials or ensure you are a Delivery Partner.");
      }
    }
  }"""
content = content.replace(old_auth, new_auth)

with open("lib/screens/login_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
