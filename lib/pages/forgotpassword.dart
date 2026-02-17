import 'dart:io';

import 'package:diamondnib/provider/generalprovider.dart';
import 'package:diamondnib/utils/color.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/widget/mytext.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  final String? initialEmail;
  const ForgotPasswordPage({super.key, this.initialEmail});

  @override
  State<ForgotPasswordPage> createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late ProgressDialog prDialog;

  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? strDeviceType;
  String? strDeviceToken;
  bool codeSent = false;

  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    prDialog = ProgressDialog(context);
    emailController.text = widget.initialEmail ?? "";
    _getDeviceToken();
  }

  Future<void> _getDeviceToken() async {
    try {
      if (Platform.isAndroid) {
        strDeviceType = "1";
        strDeviceToken = await FirebaseMessaging.instance.getToken();
      } else {
        strDeviceType = "2";
        strDeviceToken = "";
      }
    } catch (e) {
      printLog("ForgotPassword _getDeviceToken Exception ===> $e");
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      Utils.showSnackbar(context, "info", "Please enter your email", false);
      return;
    }

    if (!mounted) return;
    if (!prDialog.isShowing()) {
      Utils.showProgress(context, prDialog);
    }

    try {
      final generalProvider =
          Provider.of<GeneralProvider>(context, listen: false);

      await generalProvider.forgotPassword(email);
      await prDialog.hide();

      if (!mounted) return;
      final msg = (generalProvider.forgotPasswordModel.message ??
              generalProvider.forgotPasswordModel.success ??
              generalProvider.forgotPasswordModel.errors ??
              "")
          .toString();
      Utils.showSnackbar(
        context,
        (generalProvider.forgotPasswordModel.status == 200) ? "success" : "fail",
        msg.isNotEmpty ? msg : "Something went wrong",
        false,
      );

      if (generalProvider.forgotPasswordModel.status == 200) {
        setState(() {
          codeSent = true;
        });
      }
    } catch (e) {
      await prDialog.hide();
      if (!mounted) return;
      Utils.showSnackbar(
        context,
        "fail",
        "Failed to send reset password code.",
        false,
      );
    }
  }

  Future<void> _verifyCodeAndReset() async {
    final email = emailController.text.trim();
    final code = codeController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (code.isEmpty) {
      Utils.showSnackbar(context, "info", "Please enter the code", false);
      return;
    }

    if (newPassword.isEmpty) {
      Utils.showSnackbar(context, "info", "Please enter new password", false);
      return;
    }

    if (confirmPassword.isEmpty) {
      Utils.showSnackbar(context, "info", "Please confirm new password", false);
      return;
    }

    if (newPassword != confirmPassword) {
      Utils.showSnackbar(context, "info", "Passwords do not match", false);
      return;
    }

    if (!mounted) return;
    if (!prDialog.isShowing()) {
      Utils.showProgress(context, prDialog);
    }

    try {
      final generalProvider =
          Provider.of<GeneralProvider>(context, listen: false);
      // Call new API for code verification and password reset
      final result = await generalProvider.verifyResetCode(
        email,
        code,
        newPassword,
        confirmPassword,
      );
      await prDialog.hide();

      if (!mounted) return;
      Utils.showSnackbar(
        context,
        (result.status == 200) ? "success" : "fail",
        "${result.message}",
        false,
      );

      if (result.status == 200) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      await prDialog.hide();
      if (!mounted) return;
      Utils.showSnackbar(
        context,
        "fail",
        "Failed to reset password.",
        false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/otpbg.png"))),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      stops: const [0.1, 0.2, 0.6],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorPrimary.withOpacity(0.8),
                        colorPrimary.withOpacity(0.8),
                        colorPrimary
                      ]),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: SafeArea(
                  child: Container(
                    height: 50,
                    width: 50,
                    margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                    child: InkWell(
                      focusColor: white.withOpacity(0.40),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Utils().backBtn(18.0, 18.0, 12.0),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),
                    MyText(
                      color: white,
                      text: "Forgot Password",
                      fontsizeNormal: 20,
                      fontsizeWeb: 25,
                      multilanguage: false,
                      fontweight: FontWeight.bold,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.center,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(height: 7),
                    MyText(
                      color: white,
                      text: codeSent
                          ? "Enter the code sent to your email and set a new password"
                          : "Enter your email to receive reset instructions",
                      fontsizeNormal: 14,
                      fontsizeWeb: 15,
                      multilanguage: false,
                      fontweight: FontWeight.w500,
                      maxline: 2,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.center,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(height: 30),
                    if (!codeSent) ...[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: white,
                            width: 0.7,
                          ),
                          color: transparentColor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(11),
                          ),
                        ),
                        child: TextField(
                          controller: emailController,
                          style: const TextStyle(fontSize: 16, color: white),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            hintStyle: GoogleFonts.inter(
                              color: gray,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            hintText: "Enter your email",
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: _submit,
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                colorAccent,
                                yellow,
                              ],
                              begin: FractionalOffset(0.0, 0.0),
                              end: FractionalOffset(1.0, 0.2),
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: MyText(
                            color: white,
                            text: "Send",
                            multilanguage: false,
                            fontsizeNormal: 17,
                            fontsizeWeb: 19,
                            fontweight: FontWeight.w700,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.center,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: white,
                            width: 0.7,
                          ),
                          color: transparentColor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(11),
                          ),
                        ),
                        child: TextField(
                          controller: codeController,
                          style: const TextStyle(fontSize: 16, color: white),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            hintStyle: GoogleFonts.inter(
                              color: gray,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            hintText: "Enter code",
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: white,
                            width: 0.7,
                          ),
                          color: transparentColor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(11),
                          ),
                        ),
                        child: TextField(
                          controller: newPasswordController,
                          obscureText: !isNewPasswordVisible,
                          style: const TextStyle(fontSize: 16, color: white),
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            hintStyle: GoogleFonts.inter(
                              color: gray,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            hintText: "New password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                isNewPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: gray,
                              ),
                              onPressed: () {
                                setState(() {
                                  isNewPasswordVisible = !isNewPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: white,
                            width: 0.7,
                          ),
                          color: transparentColor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(11),
                          ),
                        ),
                        child: TextField(
                          controller: confirmPasswordController,
                          obscureText: !isConfirmPasswordVisible,
                          style: const TextStyle(fontSize: 16, color: white),
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            hintStyle: GoogleFonts.inter(
                              color: gray,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            hintText: "Confirm password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: gray,
                              ),
                              onPressed: () {
                                setState(() {
                                  isConfirmPasswordVisible =
                                      !isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: _verifyCodeAndReset,
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                colorAccent,
                                yellow,
                              ],
                              begin: FractionalOffset(0.0, 0.0),
                              end: FractionalOffset(1.0, 0.2),
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: MyText(
                            color: white,
                            text: "Reset Password",
                            multilanguage: false,
                            fontsizeNormal: 17,
                            fontsizeWeb: 19,
                            fontweight: FontWeight.w700,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.center,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 15),
                    if (kIsWeb) const SizedBox(height: 1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
