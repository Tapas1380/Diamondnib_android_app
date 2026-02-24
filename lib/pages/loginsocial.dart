import 'dart:convert';
import 'dart:math';

import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:diamondnib/pages/bottombar.dart';
import 'package:diamondnib/pages/forgotpassword.dart';
import 'package:diamondnib/pages/otpverify.dart';
import 'package:diamondnib/pages/signup.dart';
import 'package:diamondnib/provider/generalprovider.dart';
import 'package:diamondnib/provider/homeprovider.dart';
import 'package:diamondnib/provider/sectiondataprovider.dart';
import 'package:diamondnib/utils/color.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/utils/strings.dart';
import 'package:diamondnib/widget/myimage.dart';
import 'package:diamondnib/widget/mytext.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class LoginSocial extends StatefulWidget {
  final bool? ishome;
  const LoginSocial({super.key, required this.ishome});

  @override
  State<LoginSocial> createState() => LoginSocialState();
}

class LoginSocialState extends State<LoginSocial> {
  late ProgressDialog prDialog;
  late GeneralProvider generalProvider;

  final numberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isOTPMode = true;
  bool isPasswordVisible = false;
  String? mobileNumber,
      email,
      userName,
      strType,
      strDeviceType,
      strDeviceToken,
      strPrivacyAndTNC;
  File? mProfileImg;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String userEmail = "";

  @override
  void initState() {
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    super.initState();
    prDialog = ProgressDialog(context);
    _getDeviceToken();
    _getData();
  }

  _getDeviceToken() async {
    try {
      if (Platform.isAndroid) {
        strDeviceType = "1";
        strDeviceToken = await FirebaseMessaging.instance.getToken();
      } else {
        strDeviceType = "2";
        // final status = await OneSignal.shared.getDeviceState();
        // strDeviceToken = status?.userId;
      }
    } catch (e) {
      printLog("_getDeviceToken Exception ===> $e");
    }
    printLog("===>strDeviceToken $strDeviceToken");
    printLog("===>strDeviceType $strDeviceType");
  }

  _getData() async {
    String? privacyUrl, termsConditionUrl;
    await generalProvider.getPages();
    if (!generalProvider.loading) {
      if (generalProvider.pagesModel.status == 200 &&
          generalProvider.pagesModel.result != null) {
        if ((generalProvider.pagesModel.result?.length ?? 0) > 0) {
          for (var i = 0;
              i < (generalProvider.pagesModel.result?.length ?? 0);
              i++) {
            if ((generalProvider.pagesModel.result?[i].pageName ?? "")
                .toLowerCase()
                .contains("privacy")) {
              privacyUrl = generalProvider.pagesModel.result?[i].url;
            }
            if ((generalProvider.pagesModel.result?[i].pageName ?? "")
                .toLowerCase()
                .contains("terms")) {
              termsConditionUrl = generalProvider.pagesModel.result?[i].url;
            }
          }
        }
      }
    }
    printLog('privacyUrl ==> $privacyUrl');
    printLog('termsConditionUrl ==> $termsConditionUrl');

    strPrivacyAndTNC = await Utils.getPrivacyTandCText(
        privacyUrl ?? "", termsConditionUrl ?? "");
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    numberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
          child: Stack(children: [
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
                      if (widget.ishome == true) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const Bottombar()),
                          (Route route) => false,
                        );
                      } else {
                        Navigator.of(context).pop();
                      }
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
                  // Container(
                  //   width: 170,
                  //   height: 60,
                  //   alignment: Alignment.centerLeft,
                  //   child: MyImage(
                  //     fit: BoxFit.fill,
                  //     imagePath: "appicon.png",
                  //   ),
                  // ),
                  const SizedBox(height: 25),
                  MyText(
                    color: white,
                    text: "welcomeback",
                    fontsizeNormal: 20,
                    fontsizeWeb: 25,
                    multilanguage: true,
                    fontweight: FontWeight.bold,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.center,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(height: 7),
                  MyText(
                    color: white,
                    text: "login_note",
                    fontsizeNormal: 14,
                    fontsizeWeb: 15,
                    multilanguage: true,
                    fontweight: FontWeight.w500,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.center,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(height: 30),

                  /* Email/Password or OTP Login based on mode */
                  if (!isOTPMode) ...[
                    /* Email Input */
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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

                    /* Password Input */
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
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                          hintStyle: GoogleFonts.inter(
                            color: gray,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          hintText: "Enter your password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
                    const SizedBox(height: 10),

                    /* Forgot Password */
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          // TODO: Implement forgot password functionality
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordPage(
                                initialEmail: emailController.text.trim(),
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: MyText(
                            color: colorAccent,
                            text: "Forgot Password?",
                            fontsizeNormal: 13,
                            fontsizeWeb: 14,
                            multilanguage: false,
                            fontweight: FontWeight.w600,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.right,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    /* Login Button */
                    InkWell(
                      onTap: () {
                        if (emailController.text.toString().isEmpty) {
                          Utils.showSnackbar(context, "info", "Please enter your email", false);
                        } else if (passwordController.text.toString().isEmpty) {
                          Utils.showSnackbar(context, "info", "Please enter your password", false);
                        } else {
                          _emailPasswordLogin();
                        }
                      },
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
                          text: "login",
                          multilanguage: true,
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
                    const SizedBox(height: 12),
                    Center(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SignupPage(ishome: false),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: MyText(
                            color: colorAccent,
                            text: "Don't have an account? Sign Up",
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
                  ] else ...[
                    /* Enter Mobile Number */
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
                      child: IntlPhoneField(
                        disableLengthCheck: true,
                        textAlignVertical: TextAlignVertical.center,
                        autovalidateMode: AutovalidateMode.disabled,
                        controller: numberController,
                        style: const TextStyle(fontSize: 16, color: white),
                        showCountryFlag: false,
                        showDropdownIcon: false,
                        initialCountryCode: 'IN',
                        dropdownTextStyle: GoogleFonts.inter(
                          color: white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: false,
                          hintStyle: GoogleFonts.inter(
                            color: gray,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          hintText: enterYourMobileNumber,
                        ),
                        onChanged: (phone) {
                          printLog('===> ${phone.completeNumber}');
                          printLog('===> ${numberController.text}');
                          mobileNumber = phone.completeNumber;
                          printLog('===>mobileNumber $mobileNumber');
                        },
                        onCountryChanged: (country) {
                          printLog('===> ${country.name}');
                          printLog('===> ${country.code}');
                        },
                      ),
                    ),
                    const SizedBox(height: 25),

                    /* Login Button */
                    InkWell(
                      onTap: () {
                        printLog("Click mobileNumber ==> $mobileNumber");
                        if (numberController.text.toString().isEmpty) {
                          Utils.showSnackbar(
                              context, "info", "login_with_mobile_note", true);
                        } else {
                          printLog("mobileNumber ==> $mobileNumber");
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => OTPVerify(mobileNumber ?? ""),
                            ),
                          );
                        }
                      },
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
                          text: "login",
                          multilanguage: true,
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
                  const SizedBox(height: 10),

                  /* Privacy & TermsCondition link */
                  if (strPrivacyAndTNC != null)
                    Utils.htmlTexts(strPrivacyAndTNC),
                  const SizedBox(height: 10),

                  /* Other Login Option Toggle */
                  Center(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isOTPMode = !isOTPMode;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: MyText(
                          color: colorAccent,
                          text: isOTPMode ? "Other login option" : "Login with Phone Number",
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
                  const SizedBox(height: 10),

                  /* Or */
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 1,
                        foregroundDecoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              white.withOpacity(0.6),
                              colorPrimaryDark.withOpacity(1),
                            ],
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      MyText(
                        color: gray,
                        text: "or",
                        multilanguage: true,
                        fontsizeNormal: 14,
                        fontsizeWeb: 16,
                        fontweight: FontWeight.w500,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(width: 15),
                      Container(
                        width: 80,
                        height: 1,
                        foregroundDecoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              white.withOpacity(0.6),
                              colorPrimaryDark.withOpacity(1),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  /* Google Login Button */
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 52,
                    padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                        color: grayDark,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(width: 1, color: white)),
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
                        printLog("Clicked on : ====> loginWith Google");
                        _gmailLogin();
                      },
                      borderRadius: BorderRadius.circular(26),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyImage(
                            width: 30,
                            height: 30,
                            imagePath: "ic_google.png",
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 15),
                          MyText(
                            color: white,
                            text: "loginwithgoogle",
                            fontsizeNormal: 14,
                            fontsizeWeb: 16,
                            multilanguage: true,
                            fontweight: FontWeight.w600,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.center,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
                      ),
                    ),
                  ),

                  /* Apple Login Button */
                  if (Platform.isIOS)
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 52,
                      padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                          color: grayDark,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(width: 1, color: white)),
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () {
                          printLog("Clicked on : ====> loginWith Apple");
                          signInWithApple();
                        },
                        borderRadius: BorderRadius.circular(26),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.apple_rounded,
                              size: 38,
                              color: black,
                            ),
                            const SizedBox(width: 15),
                            MyText(
                              color: black,
                              text: "loginwithapple",
                              fontsizeNormal: 14,
                              fontsizeWeb: 16,
                              multilanguage: true,
                              fontweight: FontWeight.w600,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              textalign: TextAlign.center,
                              fontstyle: FontStyle.normal,
                            ),
                          ],
                        ),
                      ),
                    ),

                  /* Facebook Login Button */
                  // Container(
                  //   width: MediaQuery.of(context).size.width,
                  //   height: 52,
                  //   padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                  //   decoration: BoxDecoration(
                  //     color: white,
                  //     borderRadius: BorderRadius.circular(26),
                  //   ),
                  //   alignment: Alignment.center,
                  //   child: InkWell(
                  //     onTap: () {
                  //       printLog("Clicked on : ====> loginWith Facebook");
                  //       facebookLogin();
                  //     },
                  //     borderRadius: BorderRadius.circular(26),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         MyImage(
                  //           width: 30,
                  //           height: 30,
                  //           imagePath: "ic_facebook.png",
                  //           fit: BoxFit.contain,
                  //         ),
                  //         const SizedBox(width: 30),
                  //         MyText(
                  //           color: black,
                  //           text: "loginwithfacebook",
                  //           fontsizeNormal: 14,
                  //           fontsizeWeb: 16,
                  //           multilanguage: true,
                  //           fontweight: FontWeight.w600,
                  //           maxline: 1,
                  //           overflow: TextOverflow.ellipsis,
                  //           textalign: TextAlign.center,
                  //           fontstyle: FontStyle.normal,
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  /* Email/Password Login */
  Future<void> _emailPasswordLogin() async {
    String emailInput = emailController.text.trim();
    String passwordInput = passwordController.text.trim();

    printLog('Email/Password Login ===> email: $emailInput');

    if (!mounted) return;
    if (!prDialog.isShowing()) {
      Utils.showProgress(context, prDialog);
    }

    try {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      final sectionDataProvider =
          Provider.of<SectionDataProvider>(context, listen: false);
      final generalProvider =
          Provider.of<GeneralProvider>(context, listen: false);

      await generalProvider.loginWithEmailPassword(
        emailInput,
        passwordInput,
        "",
        strDeviceType,
        strDeviceToken,
        false,
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
      printLog('Email/Password Login Exception ===> $e');
      await prDialog.hide();
      if (!mounted) return;
      Utils.showSnackbar(context, "fail", "Login failed. Please try again.", false);
    }
  }

  Future<void> _forgotPassword(String email) async {
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
      Utils.showSnackbar(
        context,
        (generalProvider.forgotPasswordModel.status == 200) ? "success" : "fail",
        "${generalProvider.forgotPasswordModel.message}",
        false,
      );
    } catch (e) {
      printLog('ForgotPassword Exception ===> $e');
      await prDialog.hide();
      if (!mounted) return;
      Utils.showSnackbar(
          context, "fail", "Failed to send reset password email.", false);
    }
  }

  /* Google Login */
  Future<void> _gmailLogin() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    GoogleSignInAccount user = googleUser;

    printLog('GoogleSignIn ===> id : ${user.id}');
    printLog('GoogleSignIn ===> email : ${user.email}');
    printLog('GoogleSignIn ===> displayName : ${user.displayName}');
    printLog('GoogleSignIn ===> photoUrl : ${user.photoUrl}');

    if (!mounted) return;
    Utils.showProgress(context, prDialog);

    UserCredential userCredential;
    try {
      GoogleSignInAuthentication googleSignInAuthentication =
          await user.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      userCredential = await _auth.signInWithCredential(credential);
      assert(await userCredential.user?.getIdToken() != null);
      printLog("User Name: ${userCredential.user?.displayName}");
      printLog("User Email ${userCredential.user?.email}");
      printLog("User photoUrl ${userCredential.user?.photoURL}");
      printLog("uid ===> ${userCredential.user?.uid}");
      String firebasedid = userCredential.user?.uid ?? "";
      printLog('firebasedid :===> $firebasedid');

      /* Save PhotoUrl in File */
      mProfileImg =
          await Utils.saveImageInStorage(userCredential.user?.photoURL ?? "");
      printLog('mProfileImg :===> $mProfileImg');

      checkAndNavigate(user.email, user.displayName ?? "", "2");
    } on FirebaseAuthException catch (e) {
      printLog('===>Exp${e.code.toString()}');
      printLog('===>Exp${e.message.toString()}');
      if (e.code.toString() == "user-not-found") {
      } else if (e.code == 'wrong-password') {
        // Hide Progress Dialog
        await prDialog.hide();
        printLog('Wrong password provided.');
        Utils.showToast(wrongpassword);
      } else {
        // Hide Progress Dialog
        await prDialog.hide();
      }
    }
  }

  /* Apple Login */
  /// Generates a cryptographically secure random nonce
  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _generateAppleProfilePicture(String? displayName, String? userId) {
    if (displayName != null && displayName.isNotEmpty) {
      // Use initials for profile picture
      List<String> names = displayName.split(' ');
      String initials = '';
      if (names.isNotEmpty) {
        initials += names[0][0].toUpperCase();
        if (names.length > 1) {
          initials += names[names.length - 1][0].toUpperCase();
        }
      }
      // Use a service that generates avatars with initials
      return 'https://ui-avatars.com/api/?name=$initials&background=007AFF&color=fff&size=200';
    } else {
      // Use user ID to generate a unique avatar
      return 'https://ui-avatars.com/api/?name=Apple&background=007AFF&color=fff&size=200';
    }
  }

  Future<User?> signInWithApple() async {
    printLog("=== Starting Apple Sign-In Process ===");
    
    // Check if Apple Sign-In is available
    final isAvailable = await SignInWithApple.isAvailable();
    printLog("Apple Sign-In available: $isAvailable");
    
    if (!isAvailable) {
      Utils.showToast('Apple Sign-In is not available on this device');
      return null;
    }
    
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    printLog("Generated nonce - raw: $rawNonce, hashed: $nonce");

    try {
      printLog("Requesting Apple ID credential...");
      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      printLog("=== Apple Credential Data Analysis ===");
      printLog("Apple credential received:");
      printLog("- identityToken: ${appleCredential.identityToken?.substring(0, min(50, appleCredential.identityToken?.length ?? 0))}...");
      printLog("- authorizationCode: ${appleCredential.authorizationCode?.substring(0, min(50, appleCredential.authorizationCode?.length ?? 0))}...");
      printLog("- givenName: '${appleCredential.givenName}' (type: ${appleCredential.givenName.runtimeType})");
      printLog("- familyName: '${appleCredential.familyName}' (type: ${appleCredential.familyName.runtimeType})");
      printLog("- email: '${appleCredential.email}' (type: ${appleCredential.email.runtimeType})");
      printLog("- userIdentifier: '${appleCredential.userIdentifier}' (type: ${appleCredential.userIdentifier.runtimeType})");
      
      // Analyze what data we received
      bool hasName = (appleCredential.givenName != null && appleCredential.givenName!.isNotEmpty) ||
                     (appleCredential.familyName != null && appleCredential.familyName!.isNotEmpty);
      bool hasEmail = appleCredential.email != null && appleCredential.email!.isNotEmpty;
      
      printLog("=== Data Analysis ===");
      printLog("Has name data: $hasName");
      printLog("Has email data: $hasEmail");
      printLog("Is first sign-in: ${hasName || hasEmail}");
      printLog("Is returning user: ${!hasName && !hasEmail}");
      
      if (appleCredential.identityToken == null) {
        printLog("ERROR: Apple identityToken is null");
        Utils.showToast('Failed to get Apple identity token');
        return null;
      }

      // Create an `OAuthCredential` from the credential returned by Apple.
      printLog("Creating OAuth credential...");
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      printLog("OAuth credential created successfully");
      
      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      printLog("Signing in with Firebase...");
      final authResult = await _auth.signInWithCredential(oauthCredential);
      printLog("Firebase auth result: ${authResult.user?.uid}");

      // Handle display name - Apple only provides name on first sign-in
      String? displayName;
      String? actualEmail;
      String? profileImageUrl;
      
      // Check if this is first sign-in (Apple provides data)
      bool hasAppleName = (appleCredential.givenName != null && appleCredential.givenName!.isNotEmpty) ||
                         (appleCredential.familyName != null && appleCredential.familyName!.isNotEmpty);
      bool hasAppleEmail = appleCredential.email != null && appleCredential.email!.isNotEmpty;
      
      if (hasAppleName || hasAppleEmail) {
        // FIRST SIGN-IN - Apple provides actual user data
        printLog("=== FIRST SIGN-IN DETECTED ===");
        
        // Get EXACT name from Apple
        if (hasAppleName) {
          displayName = '${appleCredential.givenName ?? ""} ${appleCredential.familyName ?? ""}'.trim();
          printLog("Using EXACT Apple provided name: $displayName");
        }
        
        // Get EXACT email from Apple
        if (hasAppleEmail) {
          actualEmail = appleCredential.email;
          printLog("Using EXACT Apple provided email: $actualEmail");
        }
        
        // Generate Apple profile picture URL (Apple doesn't provide direct profile pics)
        // Use a generic Apple-style avatar or user's initials
        profileImageUrl = _generateAppleProfilePicture(displayName, appleCredential.userIdentifier);
        printLog("Generated Apple profile picture: $profileImageUrl");
        
        // Store the EXACT data in Firebase for future use
        try {
          await authResult.user?.updateDisplayName(displayName);
          if (actualEmail != null) {
            await authResult.user?.updateEmail(actualEmail);
          }
          // Store photo URL in Firebase user profile
          await authResult.user?.updatePhotoURL(profileImageUrl);
          printLog("EXACT user data stored in Firebase successfully");
        } catch (e) {
          printLog("Error storing user data in Firebase: $e");
        }
        
      } else {
        // SUBSEQUENT SIGN-IN - Retrieve EXACT data from Firebase
        printLog("=== SUBSEQUENT SIGN-IN DETECTED ===");
        
        // Get stored EXACT data from Firebase
        displayName = authResult.user?.displayName;
        actualEmail = authResult.user?.email;
        profileImageUrl = authResult.user?.photoURL;
        
        printLog("Retrieved EXACT data from Firebase - Name: $displayName, Email: $actualEmail, Photo: $profileImageUrl");
        
        // If no data in Firebase, use fallbacks
        if (displayName == null || displayName.isEmpty) {
          displayName = "Apple User";
          printLog("No name in Firebase, using fallback: $displayName");
        }
        
        if (actualEmail == null || actualEmail.isEmpty) {
          actualEmail = "apple_${appleCredential.userIdentifier}@privaterelay.appleid.com";
          printLog("No email in Firebase, using placeholder: $actualEmail");
        }
        
        if (profileImageUrl == null || profileImageUrl.isEmpty) {
          profileImageUrl = _generateAppleProfilePicture(displayName, appleCredential.userIdentifier);
          printLog("No photo in Firebase, generated: $profileImageUrl");
        }
      }
      
      // Set the final data for the app
      userEmail = actualEmail ?? "";
      
      // Save profile image from URL to File (same as Google Sign-In)
      mProfileImg = await Utils.saveImageInStorage(profileImageUrl ?? "");
      printLog("=== FINAL USER DATA ===");
      printLog("Display Name: $displayName");
      printLog("Email: $userEmail");
      printLog("Profile Picture: $mProfileImg");
    
    final firebaseUser = authResult.user;
    dynamic firebasedId = firebaseUser?.uid;  

      printLog("userEmail =====FINAL==> $userEmail");
      printLog("firebasedId ===FINAL==> $firebasedId");
      printLog("displayName ===FINAL==> $displayName");

      // Ensure we pass non-null values to checkAndNavigate
      checkAndNavigate(userEmail ?? "", displayName ?? "Apple User", "3");
    } on FirebaseAuthException catch (e) {
      printLog("Apple FirebaseAuthException =====> ${e.code}: ${e.message}");
      await prDialog.hide();
      
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid credentials provided.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Apple sign-in is not enabled.';
          break;
        default:
          errorMessage = 'An error occurred during Apple sign-in: ${e.message}';
      }
      
      Utils.showToast(errorMessage);
    } catch (exception) {
      printLog("Apple Login exception =====> $exception");
      await prDialog.hide();
      Utils.showToast('Apple sign-in failed. Please try again.');
    }
    return null;
  }

  checkAndNavigate(String mail, String displayName, String type) async {
    email = mail;
    userName = displayName;
    strType = type;
    printLog('checkAndNavigate email ==>> $email');
    printLog('checkAndNavigate userName ==>> $userName');
    printLog('checkAndNavigate strType ==>> $strType');
    printLog('checkAndNavigate mProfileImg :===> $mProfileImg');
    if (!prDialog.isShowing()) {
      Utils.showProgress(context, prDialog);
    }
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final sectionDataProvider =
        Provider.of<SectionDataProvider>(context, listen: false);
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    await generalProvider.loginWithSocial(
        email, userName ?? "", type, strDeviceType, mProfileImg);
    printLog('checkAndNavigate loading ==>> ${generalProvider.loading}');

    if (!generalProvider.loading) {
      if (generalProvider.loginSocialModel.status == 200) {
        printLog('Login Successfull!');
        Utils.saveUserCreds(
          userID: generalProvider.loginSocialModel.result?[0].id.toString(),
          userName:
              generalProvider.loginSocialModel.result?[0].fullName.toString(),
          userEmail:
              generalProvider.loginSocialModel.result?[0].email.toString(),
          userMobile:
              generalProvider.loginSocialModel.result?[0].mobile.toString(),
          userImage:
              generalProvider.loginSocialModel.result?[0].image.toString(),
          userPremium:
              generalProvider.loginSocialModel.result?[0].isBuy.toString(),
          userType: generalProvider.loginSocialModel.result?[0].type.toString(),
        );

        // Set UserID for Next
        Constant.userID =
            generalProvider.loginSocialModel.result?[0].id.toString();
        printLog('Constant userID ==>> ${Constant.userID}');

        await homeProvider.setSelectedTab(0);
        // await sectionDataProvider.getSectionBanner("0", "1");
        await sectionDataProvider.getSectionList("0", "1", 1);

        // Hide Progress Dialog
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
        // Hide Progress Dialog
        await prDialog.hide();
        if (!mounted) return;
        Utils.showSnackbar(context, "fail",
            "${generalProvider.loginSocialModel.message}", false);
      }
    }
  }
}
