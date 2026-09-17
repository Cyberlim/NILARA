import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // View mode: false = Welcome/Options screen, true = Email & Password form
  bool _showEmailAuth = false;

  // In Email Auth: true = Sign In, false = Create Account (Sign Up)
  bool _isSignInMode = true;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  String? _successMessage;

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  // Animations
  late AnimationController _entranceController;
  late AnimationController _shineController;
  
  late Animation<Offset> _taglineSlide;
  late Animation<double> _formFade;
  late Animation<double> _btnScale;

  @override
  void initState() {
    super.initState();

    // Button Shine Animation
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: false);

    // Entrance Animations (Finishes in 900ms)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _taglineSlide = Tween<Offset>(begin: const Offset(0, 1.0), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic)),
    );

    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.4, 0.8, curve: Curves.easeOut)),
    );

    _btnScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.5, 0.9, curve: Curves.easeOutBack)),
    );

    _entranceController.forward();
  }

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
    _entranceController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        final GoogleAuthProvider authProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(authProvider);
      } else {
        await GoogleSignIn.instance.initialize(
          serverClientId: '460372603542-bro4sp8fo1ud1arl3bp33evevnhagm19.apps.googleusercontent.com',
        );
        final googleUser = await GoogleSignIn.instance.authenticate();

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }
      
      if (userCredential.user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully signed in with Google!'), backgroundColor: Colors.green),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailAuth() async {
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
        setState(() => _errorMessage = 'Passwords do not match. Please re-enter.');
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
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (!mounted) return;

        if (userCredential.user != null) {
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
        // Sign Up Mode: Create account and redirect to Sign In form
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (name.isNotEmpty) {
          await userCredential.user?.updateDisplayName(name);
        }

        // Sign out so user explicitly signs in with credentials
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
          message = 'Too many attempts. Please wait a moment and try again.';
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
                    "Enter your registered email address and we'll send you a password reset link.",
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
    final size = MediaQuery.of(context).size;
    final topBannerHeight = _showEmailAuth ? 115.0 : (size.height * 0.38);

    return PopScope(
      canPop: !_showEmailAuth,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_showEmailAuth) {
          setState(() {
            _showEmailAuth = false;
            _errorMessage = null;
          });
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemStatusBarContrastEnforced: false,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarContrastEnforced: false,
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    children: [
                      // Top Colored Section with Logo (Smoothly resizes when entering email form)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeInOutCubic,
                        height: topBannerHeight,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F172A),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(18),
                            bottomRight: Radius.circular(18),
                          ),
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 320),
                              width: _showEmailAuth ? 160 : 240,
                              child: Image.asset(
                                'assets/images/banner/LOGO.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Dynamic View: Either Welcome Options OR Inline Email Sign In/Sign Up Form
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 280),
                        crossFadeState: _showEmailAuth
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: _buildWelcomeView(),
                        secondChild: _buildEmailAuthForm(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ================= VIEW 1: WELCOME & SOCIAL LOGIN =================
  Widget _buildWelcomeView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          // Heading & Subtitle
          SlideTransition(
            position: _taglineSlide,
            child: Column(
              children: [
                Text(
                  "India's Fastest",
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0B1B3D),
                    height: 1.2,
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF006DFF), Color(0xFF2196FF)],
                  ).createShader(bounds),
                  child: Text(
                    "Water Delivery",
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                Text(
                  "App",
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0B1B3D),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Fresh drinking water, cooking oils & daily\nessentials delivered in minutes.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Action Buttons
          ScaleTransition(
            scale: _btnScale,
            child: FadeTransition(
              opacity: _formFade,
              child: Column(
                children: [
                  // 1. Google Sign-In Button
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : _signInWithGoogle,
                        borderRadius: BorderRadius.circular(16),
                        splashColor: Colors.grey.shade100,
                        highlightColor: Colors.grey.shade50,
                        child: Center(
                          child: _isLoading 
                            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Color(0xFF006DFF), strokeWidth: 2))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset('assets/images/google_logo.png', height: 22),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Continue with Google",
                                    style: GoogleFonts.outfit(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0B1B3D),
                                    ),
                                  ),
                                ],
                              ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Divider with "OR"
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300, endIndent: 12)),
                      Text(
                        "OR",
                        style: GoogleFonts.outfit(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade400,
                          letterSpacing: 1,
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300, indent: 12)),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 2. Continue with Email & Password Button
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF168BDB), width: 1.4),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF168BDB).withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _showEmailAuth = true;
                            _errorMessage = null;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        splashColor: const Color(0xFF168BDB).withValues(alpha: 0.12),
                        highlightColor: const Color(0xFF168BDB).withValues(alpha: 0.05),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.mail_outline_rounded,
                                color: Color(0xFF168BDB),
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Continue with Email & Password",
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF168BDB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Policy Links Footer
          _buildPolicyFooter(),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }

  // ================= VIEW 2: INLINE EMAIL SIGN IN & SIGN UP FORM =================
  Widget _buildEmailAuthForm() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Back Button & Title
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showEmailAuth = false;
                    _errorMessage = null;
                  });
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: Color(0xFF1E293B),
                  ),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isSignInMode ? "Sign In with Email" : "Create New Account",
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0B1B3D),
                      ),
                    ),
                    Text(
                      _isSignInMode
                          ? "Enter your credentials to continue"
                          : "Enter your details to create an account",
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Segmented Switcher: [ Sign In ]  [ Create Account ]
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSignInMode = true;
                        _errorMessage = null;
                        _successMessage = null;
                      });
                    },
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
                    onTap: () {
                      setState(() {
                        _isSignInMode = false;
                        _errorMessage = null;
                        _successMessage = null;
                      });
                    },
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
                          "Sign Up",
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

          const SizedBox(height: 18),

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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
            const SizedBox(height: 12),
          ],

          // Email Field
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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

          const SizedBox(height: 12),

          // Password Field
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
              if (_isSignInMode) _handleEmailAuth();
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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

          // Confirm Password Field (Sign Up mode only)
          if (!_isSignInMode) ...[
            const SizedBox(height: 12),
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
              onSubmitted: (_) => _handleEmailAuth(),
              decoration: InputDecoration(
                hintText: "Re-enter your password",
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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

          // Forgot Password Link (Sign In mode only)
          if (_isSignInMode) ...[
            const SizedBox(height: 4),
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

          const SizedBox(height: 18),

          // Primary Submit Button
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF168BDB), Color(0xFF0258C9)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF168BDB).withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleEmailAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 14),

          // Toggle Mode Link
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isSignInMode = !_isSignInMode;
                  _errorMessage = null;
                  _successMessage = null;
                });
              },
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

          const SizedBox(height: 14),

          // Return to Welcome Options
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _showEmailAuth = false;
                  _errorMessage = null;
                });
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 16, color: Colors.grey),
              label: Text(
                "Back to other login options",
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          _buildPolicyFooter(),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
        ],
      ),
    );
  }

  // ================= POLICY FOOTER =================
  Widget _buildPolicyFooter() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/privacy'),
          child: Text("Privacy Policy", style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey, decoration: TextDecoration.underline)),
        ),
        Text("•", style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/refund'),
          child: Text("Return & Refund", style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey, decoration: TextDecoration.underline)),
        ),
        Text("•", style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/family'),
          child: Text("Family Policy", style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey, decoration: TextDecoration.underline)),
        ),
      ],
    );
  }
}
