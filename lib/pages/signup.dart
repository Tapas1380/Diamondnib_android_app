import 'dart:io';

import 'package:diamondnib/pages/bottombar.dart';
import 'package:diamondnib/provider/generalprovider.dart';
import 'package:diamondnib/provider/homeprovider.dart';
import 'package:diamondnib/provider/sectiondataprovider.dart';
import 'package:diamondnib/utils/color.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/widget/mytext.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  final bool? ishome;
  const SignupPage({super.key, required this.ishome});

  @override
  State<SignupPage> createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
  late ProgressDialog prDialog;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  String? strDeviceType;
  String? strDeviceToken;

  @override
  void initState() {
    super.initState();
    prDialog = ProgressDialog(context);
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
      printLog("Signup _getDeviceToken Exception ===> $e");
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (fullName.isEmpty) {
      Utils.showSnackbar(context, "info", "Please enter your name", false);
      return;
    }
    if (email.isEmpty) {
      Utils.showSnackbar(context, "info", "Please enter your email", false);
      return;
    }
    if (password.isEmpty) {
      Utils.showSnackbar(context, "info", "Please enter your password", false);
      return;
    }
    if (confirmPassword.isEmpty) {
      Utils.showSnackbar(context, "info", "Please confirm your password", false);
      return;
    }
    if (password != confirmPassword) {
      Utils.showSnackbar(context, "info", "Passwords do not match", false);
      return;
    }

    if (!prDialog.isShowing()) {
      Utils.showProgress(context, prDialog);
    }

    try {
      final generalProvider =
          Provider.of<GeneralProvider>(context, listen: false);
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      final sectionDataProvider =
          Provider.of<SectionDataProvider>(context, listen: false);

      await generalProvider.loginWithEmailPassword(
        email,
        password,
        fullName,
        strDeviceType,
        strDeviceToken,
        true,
      );

      if (!generalProvider.loading) {
        if (generalProvider.loginEmailModel.status == 200 &&
            (generalProvider.loginEmailModel.result?.isNotEmpty ?? false)) {
          final user = generalProvider.loginEmailModel.result!.first;

          Utils.saveUserCreds(
            userID: user.id.toString(),
            userName: (user.fullName ?? "").toString(),
            userEmail: (user.email ?? "").toString(),
            userMobile: (user.mobile ?? "").toString(),
            userImage: (user.image ?? "").toString(),
            userPremium: (user.isBuy ?? "0").toString(),
            userType: (user.type ?? "").toString(),
          );

          Constant.userID = user.id.toString();

          await homeProvider.setSelectedTab(0);
          await sectionDataProvider.getSectionList("0", "1", 1);

          await prDialog.hide();
          if (!mounted) return;
          if (!kIsWeb) {
            await Utils.initializeHiveBoxes();
          }
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const Bottombar()),
            (Route<dynamic> route) => false,
          );
        } else {
          await prDialog.hide();
          if (!mounted) return;
          Utils.showSnackbar(
            context,
            "fail",
            "${generalProvider.loginEmailModel.message}",
            false,
          );
        }
      }
    } catch (e) {
      printLog("Signup exception ===> $e");
      await prDialog.hide();
      if (!mounted) return;
      Utils.showSnackbar(context, "fail", "Signup failed. Please try again.", false);
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
                      text: "Create Account",
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
                      text: "Sign up to continue",
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
                        controller: fullNameController,
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
                          hintText: "Enter your name",
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
                        controller: emailController,
                        style: const TextStyle(fontSize: 16, color: white),
                        keyboardType: TextInputType.emailAddress,
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
                          hintText: "Enter your email",
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
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
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
                          hintText: "Enter password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: gray,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
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
                    const SizedBox(height: 25),

                    InkWell(
                      onTap: _signup,
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
                          text: "Sign Up",
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
                    const SizedBox(height: 15),

                    Center(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: MyText(
                            color: colorAccent,
                            text: "Already have an account? Login",
                            fontsizeNormal: 14,
                            fontsizeWeb: 15,
                            multilanguage: false,
                            fontweight: FontWeight.w600,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.center,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
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
