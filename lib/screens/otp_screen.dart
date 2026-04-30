import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:student_portal/screens/home_page.dart';
import 'package:provider/provider.dart';
import 'package:student_portal/providers/auth_provider.dart';
import 'package:student_portal/utils/app_colors.dart';
import 'package:student_portal/utils/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;

  const OtpScreen({super.key, required this.mobileNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double scaleFactor = (screenWidth / 375.0).clamp(0.8, 1.2);

    final defaultPinTheme = PinTheme(
      width: 50 * scaleFactor,
      height: 65 * scaleFactor,
      textStyle: AppFonts.main(
        fontSize: 24 * scaleFactor,
        color: Colors.black,
        fontWeight: FontWeight.w900,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.primaryAccent.withOpacity(0.5),
          width: 1.5,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primaryAccent, width: 2.5),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black,
              AppColors.darkBlueGradient,
              AppColors.deepAccent,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.0 * scaleFactor,
                    vertical: 20 * scaleFactor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 2,
                            color: AppColors.primaryAccent,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'VERIFICATION',
                            style: AppFonts.main(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12 * scaleFactor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: AppFonts.main(
                              fontSize: 42 * scaleFactor,
                              height: 1.1,
                              fontWeight: FontWeight.w900,
                            ),
                            children: [
                              const TextSpan(
                                text: 'ENTER\n',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: 'YOUR CODE',
                                style: TextStyle(
                                  color: AppColors.primaryAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          style: AppFonts.secondary(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14 * scaleFactor,
                          ),
                          children: [
                            const TextSpan(
                              text: "We've sent a 6-digit OTP to ",
                            ),
                            TextSpan(
                              text: widget.mobileNumber,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Icon(
                                    Icons.edit_note_rounded,
                                    color: AppColors.primaryAccent,
                                    size: 18 * scaleFactor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDFDFD),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24 * scaleFactor,
                    vertical: 30 * scaleFactor,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: const Icon(
                              Icons.key_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'ONE-TIME PASSWORD',
                            style: AppFonts.main(
                              color: Colors.black,
                              fontSize: 13 * scaleFactor,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.black.withOpacity(0.08),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '6-DIGIT CODE',
                            style: AppFonts.main(
                              color: Colors.black38,
                              fontSize: 11 * scaleFactor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Pinput(
                        controller: _otpController,
                        length: 6,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: defaultPinTheme,
                        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                        showCursor: true,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.05),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(5),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "DIDN'T RECEIVE CODE?",
                                  style: AppFonts.main(
                                    color: Colors.black38,
                                    fontSize: 10 * scaleFactor,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () async {
                                final authProvider = Provider.of<AuthProvider>(
                                  context,
                                  listen: false,
                                );
                                final success = await authProvider.sendOtp(
                                  widget.mobileNumber,
                                );
                                if (success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'OTP resent successfully',
                                      ),
                                      backgroundColor: AppColors.success,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                'RESEND',
                                style: AppFonts.main(
                                  color: AppColors.primaryAccent,
                                  fontSize: 14 * scaleFactor,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return Container(
                            width: double.infinity,
                            height: 60 * scaleFactor,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.secondaryAccent,
                                  AppColors.primaryAccent,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryAccent.withOpacity(
                                    0.4,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () async {
                                      if (_otpController.text.length == 6) {
                                        final success = await authProvider
                                            .verifyOtp(
                                              widget.mobileNumber,
                                              _otpController.text,
                                            );
                                        if (success && mounted) {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const HomePage(),
                                            ),
                                            (route) => false,
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: authProvider.isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'VERIFY & CONTINUE',
                                          style: AppFonts.main(
                                            color: Colors.white,
                                            fontSize: 16 * scaleFactor,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: Colors.green,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'CODE EXPIRES IN 10 MINUTES',
                            style: AppFonts.main(
                              color: Colors.black26,
                              fontSize: 10 * scaleFactor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
