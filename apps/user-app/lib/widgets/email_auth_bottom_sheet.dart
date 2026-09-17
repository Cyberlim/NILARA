import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/main_navigation_screen.dart';

/// Displays the Nilara styled Email & Password Login / Signup Bottom Sheet.
Future<void> showEmailAuthBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalContext) => const EmailAuthBottomSheet(),
  );
}

class EmailAuthBottomSheet extends StatefulWidget {
  const EmailAuthBottomSheet({super.key});

  @override
  State<EmailAuthBottomSheet> createState() => _EmailAuthBottomSheetState();
}

class _EmailAuthBottomSheetState extends State<EmailAuthBottomSheet> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mode: true for Sign In, false for Sign Up
  bool _isSignInMode = true;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Focus nodes
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _switchMode(bool isSignIn) {
    setState(() {
      _isSignInMode = isSignIn;
      _errorMessage = null;
      _successMessage = null;
    });
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();
    final confirmPassword = _confirmPasswordController.text;

    // Validation
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email or Gmail address.');
      _emailFocus.requestFocus();
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address (e.g. name@gmail.com).');
      _emailFocus.requestFocus();
      return;
    }

    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password.');
      _passwordFocus.requestFocus();
      return;
    }

    if (!_isSignInMode) {
      if (name.isEmpty) {
        setState(() => _errorMessage = 'Please enter your full name.');
        _nameFocus.requestFocus();
        return;
      }
      if (password.length < 6) {
        setState(() => _errorMessage = 'Password must be at least 6 characters long.');
        _passwordFocus.requestFocus();
        return;
      }
      if (password != confirmPassword) {
        setState(() => _errorMessage = 'Passwords do not match. Please check again.');
        _confirmPasswordFocus.requestFocus();
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignInMode) {
        // Sign In
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (!mounted) return;

        if (userCredential.user != null) {
          Navigator.pop(context); // Close bottom sheet

          final displayName = userCredential.user?.displayName ?? '';
          final greeting = displayName.isNotEmpty ? 'Welcome, $displayName!' : 'Welcome to Nilara!';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Signed in successfully! $greeting',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF00875A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              duration: const Duration(seconds: 3),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          );
        }
      } else {
        // Sign Up (Create Account)
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (name.isNotEmpty) {
          await userCredential.user?.updateDisplayName(name);
        }

        // Sign out newly created user so they sign in explicitly
        await _auth.signOut();

        if (!mounted) return;

        setState(() {
          _isSignInMode = true; // Redirect to Sign In form
          _isLoading = false;
          _passwordController.clear();
          _confirmPasswordController.clear();
          _errorMessage = null;
          _successMessage = 'Account created successfully! Please enter your password to sign in.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Account created! Please enter your password to sign in.',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF00875A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            duration: const Duration(seconds: 4),
          ),
        );

        _passwordFocus.requestFocus();
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = 'Authentication failed. Please check your details.';
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email. Please create an account.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password. Please try again.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists with this email. Please sign in instead.';
          break;
        case 'weak-password':
          message = 'Password is too weak. Please use at least 6 characters.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again in a moment.';
          break;
        default:
          message = e.message ?? message;
      }
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text.trim());
    bool isSending = false;
    String? resetError;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF168BDB).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_reset_rounded, color: Color(0xFF168BDB), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Reset Password",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enter your registered email address and we'll send you a link to reset your password.",
                    style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                      labelStyle: GoogleFonts.outfit(fontSize: 13),
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF168BDB), size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF168BDB), width: 1.8),
                      ),
                    ),
                  ),
                  if (resetError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      resetError!,
                      style: GoogleFonts.outfit(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSending ? null : () => Navigator.pop(dialogContext),
                  child: Text("Cancel", style: GoogleFonts.outfit(color: Colors.grey.shade600)),
                ),
                ElevatedButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          final emailToReset = resetEmailController.text.trim();
                          if (emailToReset.isEmpty) {
                            setDialogState(() => resetError = "Please enter your email");
                            return;
                          }
                          setDialogState(() {
                            isSending = true;
                            resetError = null;
                          });

                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await _auth.sendPasswordResetEmail(email: emailToReset);
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Password reset email sent to $emailToReset. Please check your inbox!',
                                    style: GoogleFonts.outfit(color: Colors.white),
                                  ),
                                  backgroundColor: const Color(0xFF00875A),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            setDialogState(() {
                              isSending = false;
                              resetError = e.message ?? "Failed to send reset link";
                            });
                          } catch (_) {
                            setDialogState(() {
                              isSending = false;
                              resetError = "Error sending reset email";
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF168BDB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text("Send Link", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top drag pill handle
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Header with Nilara theme gradient badge & close button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF168BDB), Color(0xFF0258C9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF168BDB).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isSignInMode ? Icons.login_rounded : Icons.person_add_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isSignInMode ? "Sign In with Email" : "Create New Account",
                            style: GoogleFonts.outfit(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1D1E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isSignInMode
                                ? "Enter your Gmail & password to continue"
                                : "Sign up with your Gmail to get started",
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.black54,
                        ),
                      ),
                      splashRadius: 22,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Segmented Switcher: [ Sign In ]  [ Create Account ]
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _switchMode(true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: _isSignInMode ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _isSignInMode
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.06),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                "Sign In",
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: _isSignInMode ? FontWeight.bold : FontWeight.w500,
                                  color: _isSignInMode ? const Color(0xFF168BDB) : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _switchMode(false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: !_isSignInMode ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: !_isSignInMode
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.06),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                "Create Account",
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: !_isSignInMode ? FontWeight.bold : FontWeight.w500,
                                  color: !_isSignInMode ? const Color(0xFF168BDB) : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Name Field (Sign Up mode only)
                if (!_isSignInMode) ...[
                  Text(
                    "Full Name *",
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: "Enter your full name",
                      hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 13.5),
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF168BDB), size: 22),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF168BDB), width: 1.8),
                      ),
                    ),
                    style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF1A1D1E)),
                  ),
                  const SizedBox(height: 14),
                ],

                // Email / Gmail ID field
                Text(
                  "Email / Gmail ID *",
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: "e.g. name@gmail.com",
                    hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 13.5),
                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF168BDB), size: 22),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF168BDB), width: 1.8),
                    ),
                  ),
                  style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF1A1D1E)),
                ),

                const SizedBox(height: 14),

                // Password field
                Text(
                  _isSignInMode ? "Password *" : "Create Password (min 6 characters) *",
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  obscureText: _obscurePassword,
                  textInputAction: _isSignInMode ? TextInputAction.done : TextInputAction.next,
                  onSubmitted: (_) {
                    if (_isSignInMode) _handleAuth();
                  },
                  decoration: InputDecoration(
                    hintText: "••••••••",
                    hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 15),
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF168BDB), size: 22),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF168BDB), width: 1.8),
                    ),
                  ),
                  style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF1A1D1E)),
                ),

                // Confirm Password (Sign Up mode only)
                if (!_isSignInMode) ...[
                  const SizedBox(height: 14),
                  Text(
                    "Confirm Password *",
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleAuth(),
                    decoration: InputDecoration(
                      hintText: "Re-enter password",
                      hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 13.5),
                      prefixIcon: const Icon(Icons.lock_reset_rounded, color: Color(0xFF168BDB), size: 22),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.grey.shade500,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF168BDB), width: 1.8),
                      ),
                    ),
                    style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF1A1D1E)),
                  ),
                ],

                // Forgot Password link (Sign In mode only)
                if (_isSignInMode) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPasswordDialog,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF168BDB),
                        ),
                      ),
                    ),
                  ),
                ],

                // Success alert (after signup redirect)
                if (_successMessage != null && _isSignInMode) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _successMessage!,
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              color: const Color(0xFF065F46),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Error alert
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              color: const Color(0xFFDC2626),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Primary Submit Button
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF168BDB), Color(0xFF0258C9)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF168BDB).withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _isSignInMode ? "Signing in..." : "Creating account...",
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isSignInMode ? Icons.arrow_forward_rounded : Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isSignInMode ? "Sign In" : "Create Account",
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Toggle mode prompt
                Center(
                  child: GestureDetector(
                    onTap: () => _switchMode(!_isSignInMode),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade700),
                        children: [
                          TextSpan(
                            text: _isSignInMode
                                ? "Don't have an account? "
                                : "Already have an account? ",
                          ),
                          TextSpan(
                            text: _isSignInMode ? "Sign Up" : "Sign In",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF168BDB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
