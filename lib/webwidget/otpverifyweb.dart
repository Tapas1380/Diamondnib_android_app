import 'package:diamondnib/provider/generalprovider.dart';
import 'package:diamondnib/provider/homeprovider.dart';
import 'package:diamondnib/provider/sectiondataprovider.dart';
import 'package:diamondnib/utils/color.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/utils/sharedpre.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/widget/mytext.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OTPVerifyWeb extends StatefulWidget {
  final String? mobileNumber;
  const OTPVerifyWeb(this.mobileNumber, {super.key});

  @override
  State<OTPVerifyWeb> createState() => _OTPVerifyWebState();
}

class _OTPVerifyWebState extends State<OTPVerifyWeb> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  SharedPre sharePref = SharedPre();
  final numberController = TextEditingController();
  final pinPutController = TextEditingController();
  ScrollController scollController = ScrollController();
  String? verificationId, finalOTP;
  int? forceResendingToken;
  bool codeResended = false;

  @override
  void initState() {
    super.initState();
    recptcha();
  }

  recptcha() async {
    // if (kIsWeb) {
    //   printLog("===>Web");
    //   ConfirmationResult confirmationResult = await _auth.signInWithPhoneNumber(
    //       widget.mobileNumber ?? "",
    //       RecaptchaVerifier(
    //         onSuccess: () => codeSend(false),
    //         onError: (FirebaseAuthException error) => _onVerificationFailed,
    //         onExpired: () => _onVerificationFailed,
    //         size: RecaptchaVerifierSize.compact,
    //         theme: RecaptchaVerifierTheme.dark,
    //         auth: FirebaseAuthPlatform.instance,
    //       ));
    //   printLog("verificationId ===> ${confirmationResult.verificationId}");
    // } else {
    printLog("===>app");
    codeSend(false);
    // }
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      constraints: const BoxConstraints(
        minWidth: 300,
        minHeight: 0,
        maxWidth: 500,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.centerLeft,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                focusColor: white.withOpacity(0.5),
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
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    width: 25,
                    height: 25,
                    alignment: Alignment.center,
                    child: Utils().backBtn(18, 18, 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            MyText(
              color: white,
              text: "verifyphonenumber",
              fontsizeNormal: 26,
              fontsizeWeb: 21,
              multilanguage: true,
              fontweight: FontWeight.bold,
              maxline: 1,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.center,
              fontstyle: FontStyle.normal,
            ),
            const SizedBox(height: 8),
            MyText(
              color: gray,
              text: "code_sent_desc",
              fontsizeNormal: 15,
              fontsizeWeb: 16,
              fontweight: FontWeight.w600,
              maxline: 3,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.center,
              multilanguage: true,
              fontstyle: FontStyle.normal,
            ),
            MyText(
              color: gray,
              text: widget.mobileNumber ?? "",
              fontsizeNormal: 15,
              fontsizeWeb: 16,
              fontweight: FontWeight.w600,
              maxline: 3,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.center,
              multilanguage: false,
              fontstyle: FontStyle.normal,
            ),
            const SizedBox(height: 40),

            /* Enter Received OTP */
            Pinput(
              length: 6,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              controller: pinPutController,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              defaultPinTheme: PinTheme(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  border: Border.all(color: yellow, width: 0.7),
                  shape: BoxShape.rectangle,
                  color: gray,
                  borderRadius: BorderRadius.circular(5),
                ),
                textStyle: GoogleFonts.montserrat(
                  color: white,
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 30),

            /* Confirm Button */
            InkWell(
              borderRadius: BorderRadius.circular(26),
              focusColor: white.withOpacity(0.5),
              onTap: () {
                printLog("Clicked sms Code =====> ${pinPutController.text}");
                if (pinPutController.text.toString().isEmpty) {
                  Utils.showSnackbar(context, "info", "enterreceivedotp", true);
                } else {
                  _checkOTPAndLogin();
                }
              },
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
                    borderRadius: BorderRadius.circular(26),
                  ),
                  alignment: Alignment.center,
                  child: MyText(
                    color: white,
                    text: "confirm",
                    fontsizeNormal: 17,
                    fontsizeWeb: 16,
                    multilanguage: true,
                    fontweight: FontWeight.w700,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.center,
                    fontstyle: FontStyle.normal,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            /* Resend */
            InkWell(
              borderRadius: BorderRadius.circular(10),
              focusColor: white.withOpacity(0.5),
              onTap: () {
                if (!codeResended) {
                  codeSend(true);
                }
              },
              child: Container(
                constraints: const BoxConstraints(minWidth: 70),
                padding: const EdgeInsets.all(5),
                child: MyText(
                  color: white,
                  text: "resend",
                  multilanguage: true,
                  fontsizeNormal: 16,
                  fontsizeWeb: 15,
                  fontweight: FontWeight.w700,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.center,
                  fontstyle: FontStyle.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  codeSend(bool isResend) async {
    codeResended = isResend;
    await phoneSignIn(
        phoneNumber: widget.mobileNumber.toString(), isResend: isResend);
  }

  Future<void> phoneSignIn(
      {required String phoneNumber, required bool isResend}) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: _onVerificationCompleted,
      verificationFailed: _onVerificationFailed,
      codeSent: _onCodeSent,
      codeAutoRetrievalTimeout: _onCodeTimeout,
    );
  }

  _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    printLog("verification completed ${authCredential.smsCode}");
    setState(() {
      finalOTP = authCredential.smsCode ?? "";
      pinPutController.text = authCredential.smsCode ?? "";
      printLog("finalOTP =====> $finalOTP");
    });
  }

  _onVerificationFailed(FirebaseAuthException exception) {
    if (exception.code == 'invalid-phone-number') {
      printLog("The phone number entered is invalid!");
      Utils.showSnackbar(context, "fail", "invalidphonenumber", true);
    }
  }

  _onCodeSent(String verificationId, int? forceResendingToken) {
    this.verificationId = verificationId;
    this.forceResendingToken = forceResendingToken;
    printLog("resendingToken =======> ${forceResendingToken.toString()}");
    printLog("code sent");
  }

  _onCodeTimeout(String timeout) {
    codeResended = false;
    return null;
  }

  _checkOTPAndLogin() async {
    bool error = false;
    UserCredential? userCredential;

    printLog("_checkOTPAndLogin verificationId =====> $verificationId");
    printLog("_checkOTPAndLogin smsCode =====> ${pinPutController.text}");
    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential? phoneAuthCredential = PhoneAuthProvider.credential(
      verificationId: verificationId ?? "",
      smsCode: pinPutController.text.toString(),
    );

    printLog(
        "phoneAuthCredential.smsCode        =====> ${phoneAuthCredential.smsCode}");
    printLog(
        "phoneAuthCredential.verificationId =====> ${phoneAuthCredential.verificationId}");
    try {
      userCredential = await _auth.signInWithCredential(phoneAuthCredential);
      printLog(
          "_checkOTPAndLogin userCredential =====> ${userCredential.user?.phoneNumber ?? ""}");
    } on FirebaseAuthException catch (e) {
      printLog("_checkOTPAndLogin error Code =====> ${e.code}");
      if (e.code == 'invalid-verification-code' ||
          e.code == 'invalid-verification-id') {
        if (!mounted) return;
        Utils.showSnackbar(context, "info", "otp_invalid", true);
        return;
      } else if (e.code == 'session-expired') {
        if (!mounted) return;
        Utils.showSnackbar(context, "fail", "otp_session_expired", true);
        return;
      } else {
        error = true;
      }
    }
    printLog(
        "Firebase Verification Complated & phoneNumber => ${userCredential?.user?.phoneNumber} and isError => $error");
    if (!error && userCredential != null) {
      _login(widget.mobileNumber.toString());
    } else {
      if (!mounted) return;
      Utils.showSnackbar(context, "fail", "otp_login_fail", true);
    }
  }

  _login(String mobile) async {
    printLog("click on Submit mobile => $mobile");
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final sectionDataProvider =
        Provider.of<SectionDataProvider>(context, listen: false);

    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    await generalProvider.loginWithOTP(mobile);

    if (!generalProvider.loading) {
      if (generalProvider.loginOTPModel.status == 200) {
        printLog(
            'loginOTPModel ==>> ${generalProvider.loginOTPModel.toString()}');
        printLog('Login Successfull!');
        await sharePref.save(
            "userid", generalProvider.loginOTPModel.result?[0].id.toString());
        await sharePref.save("username",
            generalProvider.loginOTPModel.result?[0].fullName.toString() ?? "");
        await sharePref.save("userimage",
            generalProvider.loginOTPModel.result?[0].image.toString() ?? "");
        await sharePref.save("useremail",
            generalProvider.loginOTPModel.result?[0].email.toString() ?? "");
        await sharePref.save("usermobile",
            generalProvider.loginOTPModel.result?[0].mobile.toString() ?? "");
        await sharePref.save("usertype",
            generalProvider.loginOTPModel.result?[0].type.toString() ?? "");

        // Set UserID for Next
        Constant.userID =
            generalProvider.loginOTPModel.result?[0].id.toString();
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
        if (!mounted) return;
        Utils.showSnackbar(
            context, "fail", "${generalProvider.loginOTPModel.message}", false);
      }
    }
  }
}
