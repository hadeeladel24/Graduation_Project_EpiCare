import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    
    if (email.isEmpty) {
      _showSnackBar("enter_email_first".tr(), Colors.red);
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (mounted) {
        _showSuccessDialog();
      }
    } on FirebaseAuthException catch (e) {
      String message = "an_error_occurred_when_reset_link_error".tr();
      
      if (e.code == 'user-not-found') {
        message = "no_user_with_this_email_address".tr();
      } else if (e.code == 'invalid-email') {
        message = "invalid_email_address".tr();
      }

      _showSnackBar(message, Colors.red);
    } catch (e) {
      _showSnackBar("unexpected_error_occurred".tr(), Colors.red);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(width * 0.06)),
        child: Padding(
          padding: EdgeInsets.all(width * 0.08),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: width * 0.22,
                height: width * 0.22,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2DD4BF), Color(0xFF14B8A6)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF14B8A6).withOpacity(0.3),
                      blurRadius: width * 0.05,
                      offset: Offset(0, height * 0.01),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mark_email_read_rounded,
                  color: Colors.white,
                  size: width * 0.12,
                ),
              ),
              SizedBox(height: height * 0.03),
              Text(
                "sent".tr(),
                style: TextStyle(
                  fontSize: width * 0.065,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: height * 0.015),
              Text(
                "reset_email_sent".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: width * 0.038,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              SizedBox(height: height * 0.035),
              SizedBox(
                width: double.infinity,
                height: height * 0.065,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14B8A6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * 0.04),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "back_to_login".tr(),
                    style: TextStyle(
                      fontSize: width * 0.045,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
    final size = MediaQuery.of(context).size;
    final width = size.width;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: width * 0.038),
          textAlign: TextAlign.center,
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(width * 0.03)),
        margin: EdgeInsets.all(width * 0.04),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(   
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF111827), size: width * 0.06),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: height * 0.025),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: height * 0.025),
              
              // Icon
              Container(
                width: width * 0.25,
                height: width * 0.25,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2DD4BF), Color(0xFF14B8A6)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF14B8A6).withOpacity(0.3),
                      blurRadius: width * 0.05,
                      offset: Offset(0, height * 0.01),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.lock_reset_rounded,
                  color: Colors.white,
                  size: width * 0.12,
                ),
              ),
              
              SizedBox(height: height * 0.04),
              
              // Title
              Text(
                "forgot_password_title".tr(),
                style: TextStyle(
                  fontSize: width * 0.08,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height * 0.015),
              Text(
                "forgot_password_description".tr(),
                style: TextStyle(
                  fontSize: width * 0.038,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: height * 0.05),
              
              // Email Field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(width * 0.04),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: width * 0.003,
                  ),
                ),
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    fontSize: width * 0.045,
                    color: const Color(0xFF111827),
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: const Color(0xFF9CA3AF),
                      size: width * 0.055,
                    ),
                    hintText: "email".tr(),
                    hintStyle: TextStyle(
                      color: const Color(0xFF9CA3AF),
                      fontSize: width * 0.04,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: height * 0.025),
                  ),
                ),
              ),
              
              SizedBox(height: height * 0.04),
              
              // Reset Button
              SizedBox(
                width: double.infinity,
                height: height * 0.07,
                child: ElevatedButton(
                  onPressed: isLoading ? null : resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14B8A6),
                    disabledBackgroundColor: const Color(0xFF14B8A6).withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * 0.04),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: width * 0.06,
                          height: width * 0.06,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          "send_reset_link".tr(),
                          style: TextStyle(
                            fontSize: width * 0.045,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              SizedBox(height: height * 0.03),
              
              // Back to Login
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_ios,
                        size: width * 0.04,
                        color: const Color(0xFF14B8A6),
                      ),
                      SizedBox(width: width * 0.015),
                      Text(
                        "back_to_login".tr(),
                        style: TextStyle(
                          color: const Color(0xFF14B8A6),
                          fontSize: width * 0.038,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}




