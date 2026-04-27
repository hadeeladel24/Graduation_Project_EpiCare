import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:easy_localization/easy_localization.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  bool agree = false;
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // دالة للحصول على رقم المستخدم التالي بشكل آمن
  Future<int> _getNextUserNumber() async {
    final DatabaseReference counterRef = FirebaseDatabase.instance.ref('user_counter');
    try {
      final TransactionResult result = await counterRef.runTransaction((currentValue) {
        int currentNumber = 0;
        if (currentValue != null && currentValue is int) {
          currentNumber = currentValue;
        }
        return Transaction.success(currentNumber + 1);
      });

      if (result.committed && result.snapshot.value != null) {
        return result.snapshot.value as int;
      } else {
        await counterRef.set(1);
        return 1;
      }
    } catch (e) {
      final snapshot = await counterRef.get();
      if (snapshot.exists && snapshot.value != null) {
        int currentValue = snapshot.value as int;
        await counterRef.set(currentValue + 1);
        return currentValue + 1;
      } else {
        await counterRef.set(1);
        return 1;
      }
    }
  }

  Future<void> signUp() async {
    if (nameController.text.trim().isEmpty) {
      _showSnackBar('please_enter_name'.tr(), Colors.red);
      return;
    }
    if (emailController.text.trim().isEmpty) {
      _showSnackBar('please_enter_email'.tr(), Colors.red);
      return;
    }
    if (passwordController.text.trim().length < 6) {
      _showSnackBar('password_min_length'.tr(), Colors.red);
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar('passwords_dont_match'.tr(), Colors.red);
      return;
    }
    if (!agree) {
      _showSnackBar('must_agree_terms'.tr(), Colors.red);
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        String uid = user.uid;

        int userNumber = await _getNextUserNumber();
        await user.updateDisplayName(nameController.text.trim());
        await user.reload();

        await FirebaseDatabase.instance.ref('users/$uid').set({
          'email': emailController.text.trim(),
          'fullName': nameController.text.trim(),
          'user_number': userNumber,
          'profileImageUrl': '',
          'contacts': [],
          'createdAt': DateTime.now().toIso8601String(),
        });

        await FirebaseDatabase.instance.ref('realtime_data/$uid').set({
          'acc': {'x': 0, 'y': 0, 'z': 0},
          'heart_rate': 72,
          'steps': 0,
          'is_seizure_detected': false,
          'timestamp': DateTime.now().toIso8601String(),
        });

        await FirebaseDatabase.instance.ref('seizure_events/$uid').set({});

        if (mounted) _showSuccessDialog();
      }
    } on FirebaseAuthException catch (e) {
      String message = 'account_creation_error'.tr();
      if (e.code == 'weak-password') message = 'weak_password'.tr();
      else if (e.code == 'email-already-in-use') message = 'email_already_used'.tr();
      else if (e.code == 'invalid-email') message = 'invalid_email_address'.tr();

      _showSnackBar(message, Colors.red);
    } catch (e) {
      _showSnackBar('unexpected_error_occurred'.tr(), Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2DD4BF), Color(0xFF14B8A6)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF14B8A6).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 24),
              Text(
                "account_created".tr(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "account_created_successfully".tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280), height: 1.5),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14B8A6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: Text(
                    "login".tr(),
                    style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 15), textAlign: TextAlign.center),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;
    final horizontalPadding = screenWidth * 0.06;
    final verticalPadding = screenHeight * 0.02;
    final inputFieldHeight = screenHeight * 0.07;
    final buttonHeight = screenHeight * 0.07;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.02),
              Text(
                "create_account".tr(),
                style: TextStyle(fontSize: screenWidth * 0.08, fontWeight: FontWeight.bold, color: const Color(0xFF111827)),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                "create_account_subtitle".tr(),
                style: TextStyle(fontSize: screenWidth * 0.045, color: const Color(0xFF6B7280)),
              ),
              SizedBox(height: screenHeight * 0.05),
              _buildInputField(controller: nameController, hintText: "full_name_en".tr(), icon: Icons.person_outline_rounded, height: inputFieldHeight),
              SizedBox(height: screenHeight * 0.02),
              _buildInputField(controller: emailController, hintText: "email".tr(), icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, height: inputFieldHeight),
              SizedBox(height: screenHeight * 0.02),
              _buildInputField(controller: passwordController, hintText: "password".tr(), icon: Icons.lock_outline_rounded, obscureText: _obscurePassword, suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF9CA3AF)), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)), height: inputFieldHeight),
              SizedBox(height: screenHeight * 0.02),
              _buildInputField(controller: confirmPasswordController, hintText: "confirm_password".tr(), icon: Icons.lock_outline_rounded, obscureText: _obscureConfirmPassword, suffixIcon: IconButton(icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF9CA3AF)), onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)), height: inputFieldHeight),
              SizedBox(height: screenHeight * 0.03),
              Row(
                children: [
                  SizedBox(width: 24, height: 24, child: Checkbox(value: agree, activeColor: const Color(0xFF14B8A6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), onChanged: (val) => setState(() => agree = val ?? false))),
                  const SizedBox(width: 12),
                  Expanded(child: Text("agree_terms_privacy".tr(), style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)))),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: isLoading ? null : signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14B8A6),
                    disabledBackgroundColor: const Color(0xFF14B8A6).withOpacity(0.6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.04)),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? SizedBox(width: screenHeight * 0.03, height: screenHeight * 0.03, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text("create_account_button".tr(), style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("already_have_account".tr(), style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280))),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: Text("login".tr(), style: const TextStyle(color: Color(0xFF14B8A6), fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    double? height,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16, color: Color(0xFF111827)),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 22),
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: height != null ? height * 0.25 : 18),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
