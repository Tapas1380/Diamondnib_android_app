import 'dart:io';

import 'package:diamondnib/provider/generalprovider.dart';
import 'package:diamondnib/provider/homeprovider.dart';
import 'package:diamondnib/provider/sectiondataprovider.dart';
import 'package:diamondnib/utils/color.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/utils/sharedpre.dart';
import 'package:diamondnib/utils/strings.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/widget/myimage.dart';
import 'package:diamondnib/widget/mytext.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

class LoginSocialWeb extends StatefulWidget {
  const LoginSocialWeb({super.key});

  @override
  State<LoginSocialWeb> createState() => _LoginSocialWebState();
}

class _LoginSocialWebState extends State<LoginSocialWeb> {
  SharedPre sharedPref = SharedPre();
  final numberController = TextEditingController();
  String? mobileNumber, email, userName, strType;
  File? mProfileImg;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      constraints: const BoxConstraints(
        minWidth: 300,
        minHeight: 0,
        maxWidth: 450,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 40,
                  alignment: Alignment.centerLeft,
                  child: MyImage(
                    fit: BoxFit.contain,
                    imagePath: "appicon.png",
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (kIsWeb) {
                      if (context.canPop()) {
                        context.pop();
                      }
                    } else {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  focusColor: white.withOpacity(0.5),
                  child: Container(
                    width: 30,
                    height: 30,
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    child: Utils().closeBtn(white, 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            MyText(
              color: white,
              text: "welcomeback",
              fontsizeNormal: 16,
              fontsizeWeb: 18,
              multilanguage: true,
              fontweight: FontWeight.bold,
              maxline: 1,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.start,
              fontstyle: FontStyle.normal,
            ),
            const SizedBox(height: 7),
            MyText(
              color: gray,
              text: "login_with_mobile_note",
              fontsizeNormal: 13,
              fontsizeWeb: 14,
              multilanguage: true,
              fontweight: FontWeight.w500,
              maxline: 2,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.start,
              fontstyle: FontStyle.normal,
            ),
            const SizedBox(height: 20),

            /* Enter Mobile Number */
            Container(
              width: MediaQuery.of(context).size.width,
              height: 35,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: yellow,
                  width: 0.7,
                ),
                color: gray,
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: IntlPhoneField(
                disableLengthCheck: true,
                controller: numberController,
                textAlignVertical: TextAlignVertical.center,
                autovalidateMode: AutovalidateMode.disabled,
                style: const TextStyle(
                  color: white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                showCountryFlag: false,
                showDropdownIcon: false,
                initialCountryCode: 'IN',
                dropdownTextStyle: GoogleFonts.montserrat(
                  color: white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintStyle: GoogleFonts.montserrat(
                    color: gray,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  hintText: enterYourMobileNumber,
                ),
                onChanged: (phone) {
                  printLog('===> ${phone.completeNumber}');
                  mobileNumber = phone.completeNumber;
                  printLog('===>mobileNumber $mobileNumber');
                },
                onCountryChanged: (country) {
                  printLog('===> ${country.name}');
                  printLog('===> ${country.code}');
                },
              ),
            ),
            const SizedBox(height: 30),

            /* Login Button */
            InkWell(
              onTap: () {
                printLog("Click mobileNumber ==> $mobileNumber");
                if (numberController.text.toString().isEmpty) {
                  Utils.showSnackbar(
                      context, "info", "login_with_mobile_note", true);
                } else {
                  printLog("mobileNumber ==> $mobileNumber");
                  Utils.buildWebAlertDialog(context, "otp", mobileNumber);
                }
              },
              focusColor: white,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 35,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        primaryLight,
                        colorAccent,
                      ],
                      begin: FractionalOffset(0.0, 0.0),
                      end: FractionalOffset(1.0, 0.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: MyText(
                    color: white,
                    text: "login",
                    multilanguage: true,
                    fontsizeNormal: 15,
                    fontsizeWeb: 14,
                    fontweight: FontWeight.w600,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.center,
                    fontstyle: FontStyle.normal,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 1,
                  color: colorAccent,
                ),
                const SizedBox(width: 15),
                MyText(
                  color: gray,
                  text: "or",
                  multilanguage: true,
                  fontsizeNormal: 14,
                  fontsizeWeb: 14,
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
                  color: colorAccent,
                ),
              ],
            ),
            const SizedBox(height: 25),

            /* Google Login Button */
            InkWell(
              onTap: () {
                printLog("Clicked on : ====> loginWith Google");
                _gmailLogin();
              },
              focusColor: yellow,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 35,
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyImage(
                        width: 20,
                        height: 20,
                        imagePath: "ic_google.png",
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 25),
                      Flexible(
                        child: MyText(
                          color: black,
                          text: "loginwithgoogle",
                          fontsizeNormal: 14,
                          fontsizeWeb: 12,
                          multilanguage: true,
                          fontweight: FontWeight.w600,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
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
    );
  }

  /* Google(Gmail) Login */
  Future<void> _gmailLogin() async {
    try {
      // Initialize Google Sign-In with explicit client ID for web
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: kIsWeb 
          ? "541713979906-quom9eehq2geduha1nme6r5f8dndcttc.apps.googleusercontent.com"
          : null,
        scopes: ['email', 'profile'],
      );

      // Clear any existing sessions
      await googleSignIn.signOut();
      
      // Try to sign in
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        printLog("Google Sign-In was cancelled by user");
        return;
      }

      // Get authentication tokens
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      printLog("Attempting to sign in with Google...");
      
      // Sign in to Firebase with Google credentials
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      
      if (user != null) {
        printLog("✅ Google Sign-In Successful");
        printLog("User ID: ${user.uid}");
        printLog("Name: ${user.displayName}");
        printLog("Email: ${user.email}");
        printLog("Photo URL: ${user.photoURL}");
        printLog("Is Email Verified: ${user.emailVerified}");
        printLog("Provider Data: ${user.providerData.map((p) => '${p.providerId}: ${p.email}').join(', ')}");

        // Save profile image if available
        if (user.photoURL != null) {
          try {
            mProfileImg = await Utils.saveImageInStorage(user.photoURL!);
            printLog('Profile image saved: $mProfileImg');
          } catch (e) {
            printLog('Error saving profile image: $e');
          }
        }

        // Proceed with app's login flow
        if (mounted) {
          checkAndNavigate(user.email ?? "", user.displayName ?? "", "2");
        }
      } else {
        throw Exception('User is null after sign in');
      }
    } on FirebaseAuthException catch (e) {
      printLog("❌ Firebase Auth Error: ${e.code}");
      printLog("Message: ${e.message}");
      printLog("Stack: ${e.stackTrace}");
      
      String errorMessage = 'Authentication failed. ';
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage += 'An account already exists with the same email but different sign-in credentials.';
          break;
        case 'invalid-credential':
          errorMessage += 'The credential is malformed or has expired.';
          break;
        case 'operation-not-allowed':
          errorMessage += 'Google Sign-In is not enabled for this project.';
          break;
        case 'user-disabled':
          errorMessage += 'This user account has been disabled.';
          break;
        case 'user-not-found':
          errorMessage += 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage += 'Incorrect password.';
          break;
        case 'invalid-verification-code':
          errorMessage += 'The verification code is invalid.';
          break;
        case 'invalid-verification-id':
          errorMessage += 'The verification ID is invalid.';
          break;
        default:
          errorMessage += '${e.message}';
      }
      
      if (mounted) {
        Utils.showToast(errorMessage);
      }
    } catch (e, st) {
      printLog("❌ Unexpected Error during Google Sign-In: $e");
      printLog("Stack trace: $st");
      
      if (mounted) {
        Utils.showToast('An unexpected error occurred. Please try again.');
      }
    }
  }

  void checkAndNavigate(String mail, String displayName, String type) async {
    email = mail;
    userName = displayName;
    strType = type;
    printLog('checkAndNavigate email ==>> $email');
    printLog('checkAndNavigate userName ==>> $userName');
    printLog('checkAndNavigate strType ==>> $strType');
    printLog('checkAndNavigate mProfileImg :===> $mProfileImg');
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final sectionDataProvider =
        Provider.of<SectionDataProvider>(context, listen: false);
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    await generalProvider.loginWithSocial(
        email, userName, type, type, mProfileImg);
    printLog('checkAndNavigate loading ==>> ${generalProvider.loading}');

    if (!generalProvider.loading) {
      if (generalProvider.loginSocialModel.status == 200) {
        printLog('Login Successfull!');
        await sharedPref.save("userid",
            generalProvider.loginSocialModel.result?[0].id.toString());
        await sharedPref.save(
            "username",
            generalProvider.loginSocialModel.result?[0].fullName.toString() ??
                "");
        await sharedPref.save("userimage",
            generalProvider.loginSocialModel.result?[0].image.toString() ?? "");
        await sharedPref.save("useremail",
            generalProvider.loginSocialModel.result?[0].email.toString() ?? "");
        await sharedPref.save(
            "usermobile",
            generalProvider.loginSocialModel.result?[0].mobile.toString() ??
                "");
        await sharedPref.save("usertype",
            generalProvider.loginSocialModel.result?[0].type.toString() ?? "");

        // Set UserID for Next
        Constant.userID =
            generalProvider.loginSocialModel.result?[0].id.toString();
        printLog('Constant userID ==>> ${Constant.userID}');

        if (!mounted) return;
        if (kIsWeb) {
          if (context.canPop()) {
            context.pop();
          }
        } else {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }

        await homeProvider.homeNotifyProvider();
        // await sectionDataProvider.getSectionBanner("0", "1");
        await sectionDataProvider.getSectionList("0", "1", 1);
      } else {
        // Hide Progress Dialog
        if (!mounted) return;
        Utils.showSnackbar(context, "fail",
            "${generalProvider.loginSocialModel.message}", false);
      }
    }
  }
}
