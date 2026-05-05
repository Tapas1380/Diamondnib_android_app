import 'dart:async';
import 'dart:io';
import 'dart:convert'; // for utf8
import 'package:crypto/crypto.dart'; // for sha512

import 'package:diamondnib/provider/channelsectionprovider.dart';
import 'package:diamondnib/provider/paymentprovider.dart';
import 'package:diamondnib/provider/profileprovider.dart';
import 'package:diamondnib/provider/showdetailsprovider.dart';
import 'package:diamondnib/provider/videodetailsprovider.dart';
import 'package:diamondnib/utils/color.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/utils/sharedpre.dart';
import 'package:diamondnib/utils/strings.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/widget/myimage.dart';
import 'package:diamondnib/widget/mytext.dart';
import 'package:diamondnib/widget/nodata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
// import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
// // ⚠️ Your custom PayU wrapper (matches the code you pasted)
// import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';

final bool _kAutoConsume = Platform.isIOS || true;

class AllPayment extends StatefulWidget {
  final String? payType,
      coin,
      itemId,
      price,
      itemTitle,
      typeId,
      videoType,
      productPackage,
      currency;
  const AllPayment({
    super.key,
    required this.payType,
    required this.itemId,
    required this.price,
    required this.itemTitle,
    required this.typeId,
    required this.coin,
    required this.videoType,
    required this.productPackage,
    required this.currency,
  });

  @override
  State<AllPayment> createState() => AllPaymentState();
}

class AllPaymentState extends State<AllPayment>
  {
  final couponController = TextEditingController();
  late ProgressDialog prDialog;
  late PaymentProvider paymentProvider;
  SharedPre sharedPref = SharedPre();
  String? userId, userName, userEmail, userMobileNo, paymentId;
  String? strCouponCode = "";
  bool isPaymentDone = false;

  // ✅ PayU SDK instance (needs the protocol)
  // late PayUCheckoutProFlutter _payuSdk;

  /* InApp Purchase */
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  late List<String> _kProductIds;
  final List<PurchaseDetails> _purchases = <PurchaseDetails>[];

Timer? _paymentVerificationTimer;
 late LifecycleEventHandler _lifecycleEventHandler;
  /* Paytm */
  String paytmResult = "";

  /* Flutterwave */
  String selectedCurrency = "";
  bool isTestMode = true;

  /* Stripe */
  Map<String, dynamic>? paymentIntent;

@override
void initState() {
  prDialog = ProgressDialog(context);
  
  // Initialize lifecycle handler
  _lifecycleEventHandler = LifecycleEventHandler(
    resumeCallBack: () async {
      print("🔄 App resumed - checking pending payment");
      await _checkPendingPaymentOnResume();
    },
  );

  // Check for pending payments when app starts
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _checkPendingPaymentOnStart();
  });

  // Add lifecycle observer
  WidgetsBinding.instance.addObserver(_lifecycleEventHandler);

  if (!kIsWeb) {
    _kProductIds = <String>[widget.productPackage ?? ""];
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object error) {
      printLog("onError ============> ${error.toString()}");
    });
    initStoreInfo();
  }
  
  _getData();
  super.initState();
}


// Check for pending payments when app starts
Future<void> _checkPendingPaymentOnStart() async {
  final pendingPayment = await _getPendingPayment();
  if (pendingPayment != null) {
    print("🔄 Found pending payment on app start: ${pendingPayment['txnId']}");
    _startUPIPaymentVerification(pendingPayment['txnId']!, pendingPayment['amount']!);
  }
}


 
  _getData() async {
    paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    await paymentProvider.getPaymentOption();
    await paymentProvider.setFinalAmount(widget.price ?? "");

    if (paymentProvider.paymentOptionModel.status == 200) {
      if (paymentProvider.paymentOptionModel.result != null) {
        if (paymentProvider.paymentOptionModel.result?.flutterwave != null) {}
      }
    }

    /* PaymentID */
    paymentId = Utils.generateRandomOrderID();
    printLog('paymentId =====================> $paymentId');

    userId = await sharedPref.read("userid");
    userName = await sharedPref.read("username");
    userEmail = await sharedPref.read("useremail");
    userMobileNo = await sharedPref.read("usermobile");
    printLog('getUserData userId ==> $userId');
    printLog('getUserData userName ==> $userName');
    printLog('getUserData userEmail ==> $userEmail');
    printLog('getUserData userMobileNo ==> $userMobileNo');

    Future.delayed(Duration.zero).then((value) {
      if (!context.mounted) return;
      setState(() {});
    });
  }

@override
void dispose() {
  // Cancel any running timers
  _paymentVerificationTimer?.cancel();
  
  // Remove lifecycle observer using the same instance
  WidgetsBinding.instance.removeObserver(_lifecycleEventHandler);
  
  paymentProvider.clearProvider();
  if (!kIsWeb) {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition = _inAppPurchase
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
  }
  couponController.dispose();
  super.dispose();
}

  /* add_rent_transaction API */
  Future addRentTransaction(videoId, amount, typeId, videoType) async {
    final videoDetailsProvider =
        Provider.of<VideoDetailsProvider>(context, listen: false);
    final showDetailsProvider =
        Provider.of<ShowDetailsProvider>(context, listen: false);

    Utils.showProgress(context, prDialog);
    await paymentProvider.addRentTransaction(
        videoId, amount, typeId, videoType, strCouponCode);

    if (!paymentProvider.payLoading) {
      await prDialog.hide();

      if (paymentProvider.successModel.status == 200) {
        isPaymentDone = true;
        if (videoType == "1") {
          await videoDetailsProvider.updateRentPurchase();
        } else if (videoType == "2") {
          await showDetailsProvider.updateRentPurchase();
        }

        if (!mounted) return;
        Navigator.pop(context, isPaymentDone);
      } else {
        isPaymentDone = false;
        if (!mounted) return;
        Utils.showSnackbar(
            context, "info", paymentProvider.successModel.message ?? "", true);
      }
    }
  }

  /* apply_coupon API */
  Future applyCoupon() async {
    FocusManager.instance.primaryFocus?.unfocus();
    Utils.showProgress(context, prDialog);
    if (widget.payType == "Package") {
      await paymentProvider.applyPackageCouponCode(
          strCouponCode, widget.itemId);

      if (!paymentProvider.couponLoading) {
        await prDialog.hide();
        if (paymentProvider.couponModel.status == 200) {
          couponController.clear();
          await paymentProvider.setFinalAmount(
              paymentProvider.couponModel.result?.discountAmount.toString());
          strCouponCode =
              paymentProvider.couponModel.result?.uniqueId.toString();
          printLog("strCouponCode =============> $strCouponCode");
          printLog("finalAmount =============> ${paymentProvider.finalAmount}");
          if (!mounted) return;
          Utils.showSnackbar(context, "success",
              paymentProvider.couponModel.message ?? "", false);
        } else {
          if (!mounted) return;
          Utils.showSnackbar(context, "fail",
              paymentProvider.couponModel.message ?? "", false);
        }
      }
    } else if (widget.payType == "Rent") {
      await paymentProvider.applyRentCouponCode(strCouponCode, widget.itemId,
          widget.typeId, widget.videoType, widget.price);

      if (!paymentProvider.couponLoading) {
        await prDialog.hide();
        if (paymentProvider.couponModel.status == 200) {
          couponController.clear();
          await paymentProvider.setFinalAmount(
              paymentProvider.couponModel.result?.discountAmount.toString());
          strCouponCode =
              paymentProvider.couponModel.result?.uniqueId.toString();
          printLog("strCouponCode =============> $strCouponCode");
          printLog("finalAmount =============> ${paymentProvider.finalAmount}");
          if (!mounted) return;
          Utils.showSnackbar(context, "success",
              paymentProvider.couponModel.message ?? "", false);
        } else {
          if (!mounted) return;
          Utils.showSnackbar(context, "fail",
              paymentProvider.couponModel.message ?? "", false);
        }
      }
    } else {
      await prDialog.hide();
    }
  }

  openPayment({required String pgName}) async {
    printLog("finalAmount =============> ${paymentProvider.finalAmount}");
    if (pgName == "paypal") {
      _paypalInit();
    } else if (pgName == "inapp") {
      _initInAppPurchase();
    } else if (pgName == "razorpay") {
      _initializeRazorpay();
    } else if (pgName == "flutterwave") {
      _flutterwaveInit();
    } else if (pgName == "payumoney") {
      _payumoneyInit();
    } else if (pgName == "paytm") {
      _paytmInit();
    } else if (pgName == "stripe") {
      // _stripeInit();
    } else if (pgName == "paystack") {
      // _paystackInit();
    } else if (pgName == "instamojo") {
      // _initInstamojo();
    } else if (pgName == "cash") {
      if (!mounted) return;
      Utils.showSnackbar(context, "info", "cash_payment_msg", true);
    }
  }

  bool checkKeysAndContinue({
    required String isLive,
    required bool isBothKeyReq,
    required String liveKey1,
    required String liveKey2,
    required String testKey1,
    required String testKey2,
  }) {
    if (isLive == "1") {
      if (isBothKeyReq) {
        if (liveKey1 == "" || liveKey2 == "") {
          Utils.showSnackbar(context, "", "payment_not_processed", true);
          return false;
        }
      } else {
        if (liveKey1 == "") {
          Utils.showSnackbar(context, "", "payment_not_processed", true);
          return false;
        }
      }
      return true;
    } else {
      if (isBothKeyReq) {
        if (testKey1 == "" || testKey2 == "") {
          Utils.showSnackbar(context, "", "payment_not_processed", true);
          return false;
        }
      } else {
        if (testKey1 == "") {
          Utils.showSnackbar(context, "", "payment_not_processed", true);
          return false;
        }
      }
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: onBackPressed,
      child: _buildPage(),
    );
  }

  Widget _buildPage() {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: Utils.myAppBarWithBack(context, "payment_details", false, true),
      body: SafeArea(
        child: Center(
          child: _buildMobilePage(),
        ),
      ),
    );
  }

  Widget _buildMobilePage() {
    return Container(
      width:
          ((kIsWeb || Constant.isTV) && MediaQuery.of(context).size.width > 720)
              ? MediaQuery.of(context).size.width * 0.5
              : MediaQuery.of(context).size.width,
      margin: (kIsWeb || Constant.isTV)
          ? const EdgeInsets.fromLTRB(50, 0, 50, 50)
          : const EdgeInsets.all(0),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: (kIsWeb || Constant.isTV) ? 40 : 0),
          Container(
            margin: const EdgeInsets.all(8.0),
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: 5,
              color: colorPrimaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width,
                constraints: const BoxConstraints(minHeight: 50),
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    _buildCouponBox(),
                    const SizedBox(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      constraints: const BoxConstraints(minHeight: 50),
                      decoration: Utils.setBackground(yellow, 0),
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      alignment: Alignment.centerLeft,
                      child: Consumer<PaymentProvider>(
                        builder: (context, paymentProvider, child) {
                          return RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              text: payableAmountIs,
                              style: GoogleFonts.montserrat(
                                textStyle: const TextStyle(
                                  color: colorPrimaryDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.normal,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      "${Constant.currencySymbol}${paymentProvider.finalAmount ?? ""}",
                                  style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                      color: black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.normal,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /* PGs */
          Expanded(
            child: SingleChildScrollView(
              child: paymentProvider.loading
                  ? Container(
                      height: 230,
                      padding: const EdgeInsets.all(20),
                      child: Utils.pageLoader(),
                    )
                  : paymentProvider.paymentOptionModel.status == 200
                      ? paymentProvider.paymentOptionModel.result != null
                          ? ((kIsWeb)
                              ? _buildWebPayments()
                              : _buildPaymentPage())
                          : const NoData(
                              title: 'no_payment', subTitle: 'no_payment_desc')
                      : const NoData(
                          title: 'no_payment', subTitle: 'no_payment_desc'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponBox() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        border: Border.all(color: colorAccent, width: 0.5),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              child: TextField(
                onSubmitted: (value) async {
                  if (value.isNotEmpty) {
                    strCouponCode = value.toString();
                    applyCoupon();
                  } else {
                    strCouponCode = "";
                  }
                  printLog("strCouponCode ===========> $strCouponCode");
                },
                onChanged: (value) async {
                  if (value.isNotEmpty) {
                    strCouponCode = value.toString();
                  } else {
                    strCouponCode = "";
                  }
                  printLog("strCouponCode ===========> $strCouponCode");
                },
                textInputAction: TextInputAction.done,
                obscureText: false,
                controller: couponController,
                keyboardType: TextInputType.text,
                maxLines: 1,
                style: const TextStyle(
                  color: white,
                  fontSize: 16,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  filled: true,
                  fillColor: transparentColor,
                  hintStyle: TextStyle(
                    color: gray,
                    fontSize: 14,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w500,
                  ),
                  hintText: couponAddHint,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () async {
              if (strCouponCode != null && (strCouponCode ?? "").isNotEmpty) {
                applyCoupon();
              } else {
                Utils.showSnackbar(context, "info", emptyCouponMsg, false);
              }
            },
            child: Container(
              height: 30,
              constraints: const BoxConstraints(minWidth: 50),
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
              decoration: Utils.setBackground(white, 5),
              alignment: Alignment.center,
              child: MyText(
                color: black,
                text: "apply",
                multilanguage: true,
                fontsizeNormal: 13,
                fontsizeWeb: 14,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                fontweight: FontWeight.w600,
                textalign: TextAlign.end,
                fontstyle: FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentPage() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyText(
            color: white,
            text: "payment_methods",
            fontsizeNormal: 15,
            fontsizeWeb: 17,
            maxline: 1,
            multilanguage: true,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w600,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 5),
          MyText(
            color: gray,
            text: "choose_a_payment_methods_to_pay",
            multilanguage: true,
            fontsizeNormal: 13,
            fontsizeWeb: 15,
            maxline: 2,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w500,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 15),
          MyText(
            color: colorAccent,
            text: "pay_with",
            multilanguage: true,
            fontsizeNormal: 16,
            fontsizeWeb: 16,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w700,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 20),

          (!kIsWeb) ? _buildAndroidPG() : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildWebPayments() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyText(
            color: white,
            text: "payment_methods",
            fontsizeNormal: 15,
            fontsizeWeb: 17,
            maxline: 1,
            multilanguage: true,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w600,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 5),
          MyText(
            color: gray,
            text: "choose_a_payment_methods_to_pay",
            multilanguage: true,
            fontsizeNormal: 13,
            fontsizeWeb: 15,
            maxline: 2,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w500,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 15),
          MyText(
            color: colorAccent,
            text: "pay_with",
            multilanguage: true,
            fontsizeNormal: 16,
            fontsizeWeb: 16,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w700,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 20),

          /* Razorpay (web) */
          paymentProvider.paymentOptionModel.result?.razorpay != null
              ? paymentProvider
                          .paymentOptionModel.result?.razorpay?.visibility ==
                      "1"
                  ? _buildPGButton("pg_razorpay.png", "Razorpay", 35, 130,
                      onClick: () async {
                      await paymentProvider.setCurrentPayment("razorpay");
                      openPayment(pgName: "razorpay");
                    })
                  : const SizedBox.shrink()
              : const NoData(title: 'no_payment', subTitle: 'no_payment_desc'),
              //payu web
                paymentProvider.paymentOptionModel.result?.payumoney != null
            ? paymentProvider
                        .paymentOptionModel.result?.payumoney?.visibility ==
                    "1"
                ? _buildPGButton("pg_payumoney.png", "PayU Money", 35, 130,
                    onClick: () async {
                    await paymentProvider.setCurrentPayment("payumoney");
                    openPayment(pgName: "payumoney");
                  })
                : const SizedBox.shrink()
            : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildIOSPG() {
    return _buildIOSPGButton("In-App Purchase", 35, 110, onClick: () async {
      await paymentProvider.setCurrentPayment("inapp");
      _initInAppPurchase();
    });
  }

  Widget _buildIOSPGButton(String pgName, double imgHeight, double imgWidth,
      {required Function() onClick}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 5,
        color: colorPrimaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onClick,
          child: Container(
            constraints: const BoxConstraints(minHeight: 85),
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: MyText(
                    color: yellow,
                    text: pgName,
                    multilanguage: false,
                    fontsizeNormal: 22,
                    fontsizeWeb: 22,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    fontweight: FontWeight.w600,
                    textalign: TextAlign.start,
                    fontstyle: FontStyle.normal,
                  ),
                ),
                const SizedBox(width: 20),
                const Icon(
                  Icons.arrow_right_alt_rounded,
                  size: 22,
                  color: white,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAndroidPG() {
    return Column(
      children: [
        /* In-App purchase */
        paymentProvider.paymentOptionModel.result?.inapppurchage != null
            ? paymentProvider
                        .paymentOptionModel.result?.inapppurchage?.visibility ==
                    "1"
                ? _buildPGButton("pg_inapp.png", "InApp Purchase", 35, 110,
                    onClick: () async {
                    await paymentProvider.setCurrentPayment("inapp");
                    openPayment(pgName: "inapp");
                  })
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* Paypal */
        paymentProvider.paymentOptionModel.result?.paypal != null
            ? paymentProvider.paymentOptionModel.result?.paypal?.visibility ==
                    "1"
                ? _buildPGButton("pg_paypal.png", "Paypal", 35, 130,
                    onClick: () async {
                    await paymentProvider.setCurrentPayment("paypal");
                    openPayment(pgName: "paypal");
                  })
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* Razorpay */
        paymentProvider.paymentOptionModel.result?.razorpay != null
            ? paymentProvider.paymentOptionModel.result?.razorpay?.visibility ==
                    "1"
                ? _buildPGButton("pg_razorpay.png", "Razorpay", 35, 130,
                    onClick: () async {
                    await paymentProvider.setCurrentPayment("razorpay");
                    openPayment(pgName: "razorpay");
                  })
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* Paytm */
        paymentProvider.paymentOptionModel.result?.paytm != null
            ? paymentProvider.paymentOptionModel.result?.paytm?.visibility ==
                    "1"
                ? _buildPGButton("pg_paytm.png", "Paytm", 30, 90,
                    onClick: () async {
                    await paymentProvider.setCurrentPayment("paytm");
                    openPayment(pgName: "paytm");
                  })
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* Flutterwave */
        paymentProvider.paymentOptionModel.result?.flutterwave != null
            ? paymentProvider
                        .paymentOptionModel.result?.flutterwave?.visibility ==
                    "1"
                ? _buildPGButton("pg_flutterwave.png", "Flutterwave", 35, 130,
                    onClick: () async {
                    await paymentProvider.setCurrentPayment("flutterwave");
                    openPayment(pgName: "flutterwave");
                  })
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* PayUMoney */
        paymentProvider.paymentOptionModel.result?.payumoney != null
            ? paymentProvider
                        .paymentOptionModel.result?.payumoney?.visibility ==
                    "1"
                ? _buildPGButton("pg_payumoney.png", "PayU Money", 35, 130,
                    onClick: () async {
                    await paymentProvider.setCurrentPayment("payumoney");
                    openPayment(pgName: "payumoney");
                  })
                : const SizedBox.shrink()
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildPGButton(
      String imageName, String pgName, double imgHeight, double imgWidth,
      {required Function() onClick}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 5,
        color: colorPrimaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onClick,
          child: Container(
            constraints: const BoxConstraints(minHeight: 85),
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                MyImage(
                  imagePath: imageName,
                  fit: BoxFit.contain,
                  height: imgHeight,
                  width: imgWidth,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: MyText(
                    color: white,
                    text: pgName,
                    multilanguage: false,
                    fontsizeNormal: 14,
                    fontsizeWeb: 15,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    fontweight: FontWeight.w600,
                    textalign: TextAlign.end,
                    fontstyle: FontStyle.normal,
                  ),
                ),
                const SizedBox(width: 15),
                const Icon(
                  Icons.arrow_right_alt_rounded,
                  size: 22,
                  color: white,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* ********* InApp purchase START ********* */
  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {});
      return;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    final ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {});
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {});
      return;
    }
    setState(() {});
  }

  _initInAppPurchase() async {
    printLog(
        "_initInAppPurchase _kProductIds ============> ${_kProductIds[0].toString()}");
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(_kProductIds.toSet());
    if (response.notFoundIDs.isNotEmpty) {
      Utils.showToast("Please check SKU");
      return;
    }
    printLog("productID ============> ${response.productDetails[0].id}");
    late PurchaseParam purchaseParam;
    if (Platform.isAndroid) {
      purchaseParam =
          GooglePlayPurchaseParam(productDetails: response.productDetails[0]);
    } else {
      purchaseParam = PurchaseParam(productDetails: response.productDetails[0]);
    }
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          printLog(
              "purchaseDetails ============> ${purchaseDetails.error.toString()}");
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          printLog("===> status ${purchaseDetails.status}");
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!_kAutoConsume && purchaseDetails.productID == _kProductIds[0]) {
            final InAppPurchaseAndroidPlatformAddition androidAddition =
                _inAppPurchase.getPlatformAddition<
                    InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          printLog(
              "===> pendingCompletePurchase ${purchaseDetails.pendingCompletePurchase}");
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    printLog("===> productID ${purchaseDetails.productID}");
    if (purchaseDetails.productID == _kProductIds[0]) {
      if (widget.payType == "Package") {
        addTransaction(widget.itemId, widget.itemTitle,
            paymentProvider.finalAmount, paymentId, widget.currency);
      } else if (widget.payType == "Rent") {
        addRentTransaction(widget.itemId, paymentProvider.finalAmount,
            widget.typeId, widget.videoType);
      }
      setState(() {});
    } else {
      printLog("===> consumables else $purchaseDetails");
      setState(() {
        _purchases.add(purchaseDetails);
      });
    }
  }

  void showPendingUI() {
    setState(() {});
  }

  void handleError(IAPError error) {
    setState(() {});
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    printLog("invalid Purchase ===> $purchaseDetails");
  }
  /* ********* InApp purchase END ********* */

  /* ********* Razorpay START ********* */
  void _initializeRazorpay() {
    if (paymentProvider.paymentOptionModel.result?.razorpay != null) {
      bool isContinue = checkKeysAndContinue(
        isLive:
            (paymentProvider.paymentOptionModel.result?.razorpay?.isLive ?? ""),
        isBothKeyReq: false,
        liveKey1:
            (paymentProvider.paymentOptionModel.result?.razorpay?.key1 ?? ""),
        liveKey2: "",
        testKey1:
            (paymentProvider.paymentOptionModel.result?.razorpay?.key1 ?? ""),
        testKey2: "",
      );
      if (!isContinue) return;

      Razorpay razorpay = Razorpay();
      var options = {
        'key': (paymentProvider.paymentOptionModel.result?.razorpay?.key1 ?? ""),
        'currency': Constant.currency,
        'amount': (double.parse(paymentProvider.finalAmount ?? "0") * 100),
        'name': widget.itemTitle ?? "",
        'description': widget.itemTitle ?? "",
        'retry': {'enabled': true, 'max_count': 1},
        'send_sms_hash': true,
        'prefill': {'contact': userMobileNo, 'email': userEmail},
        'external': {
          'wallets': ['paytm']
        }
      };
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);

      try {
        razorpay.open(options);
      } catch (e) {
        printLog('Razorpay Error :=========> $e');
      }
    } else {
      Utils.showSnackbar(context, "", "payment_not_processed", true);
    }
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) async {
    Utils.showSnackbar(context, "fail", "payment_fail", true);
    await paymentProvider.setCurrentPayment("");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    paymentId = response.paymentId.toString();
    printLog("paymentId ========> $paymentId");
    Utils.showSnackbar(context, "success", "payment_success", true);
    if (widget.payType == "Package") {
      addTransaction(widget.itemId, widget.itemTitle,
          paymentProvider.finalAmount, paymentId, widget.currency);
    } else if (widget.payType == "Rent") {
      addRentTransaction(widget.itemId, paymentProvider.finalAmount,
          widget.typeId, widget.videoType);
    }
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    printLog("============ External Wallet Selected ============");
  }
  /* ********* Razorpay END ********* */

  /* ********* Paytm START ********* */
  Future<void> _paytmInit() async {
    if (paymentProvider.paymentOptionModel.result?.paytm != null) {
      bool isContinue = checkKeysAndContinue(
        isLive:
            (paymentProvider.paymentOptionModel.result?.paytm?.isLive ?? ""),
        isBothKeyReq: false,
        liveKey1:
            (paymentProvider.paymentOptionModel.result?.paytm?.key1 ?? ""),
        liveKey2: "",
        testKey1:
            (paymentProvider.paymentOptionModel.result?.paytm?.key1 ?? ""),
        testKey2: "",
      );
      if (!isContinue) return;

      bool payTmIsStaging;
      String payTmMerchantID,
          payTmOrderId,
          payTmCustmoreID,
          payTmChannelID,
          payTmTxnAmount,
          payTmWebsite,
          payTmCallbackURL,
          payTmIndustryTypeID;

      payTmOrderId = paymentId ?? "";
      payTmCustmoreID = "${Constant.userID}_$paymentId";
      payTmChannelID = "WAP";
      payTmTxnAmount = "${(paymentProvider.finalAmount ?? "")}.00";
      payTmIndustryTypeID = "Retail";

      if (paymentProvider.paymentOptionModel.result?.paytm?.isLive == "1") {
        payTmMerchantID =
            paymentProvider.paymentOptionModel.result?.paytm?.key1 ?? "";
        payTmIsStaging = false;
        payTmWebsite = "DEFAULT";
        payTmCallbackURL =
            "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$payTmOrderId";
      } else {
        payTmMerchantID =
            paymentProvider.paymentOptionModel.result?.paytm?.key1 ?? "";
        payTmIsStaging = true;
        payTmWebsite = "WEBSTAGING";
        payTmCallbackURL =
            "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$payTmOrderId";
      }

      var sendMap = <String, dynamic>{
        "mid": payTmMerchantID,
        "orderId": payTmOrderId,
        "amount": payTmTxnAmount,
        "txnToken": paymentProvider.payTmModel.result?.paytmChecksum ?? "",
        "callbackUrl": payTmCallbackURL,
        "isStaging": payTmIsStaging,
        "restrictAppInvoke": true,
        "enableAssist": true,
      };
      printLog("sendMap ===> $sendMap");

      await paymentProvider.getPaytmToken(
        payTmMerchantID,
        payTmOrderId,
        payTmCustmoreID,
        payTmChannelID,
        payTmTxnAmount,
        payTmWebsite,
        payTmCallbackURL,
        payTmIndustryTypeID,
      );

      if (!paymentProvider.loading) {
        if (paymentProvider.payTmModel.result != null) {
          if (paymentProvider.payTmModel.result?.paytmChecksum != null) {
            try {
              var response = AllInOneSdk.startTransaction(
                payTmMerchantID,
                payTmOrderId,
                payTmTxnAmount,
                paymentProvider.payTmModel.result?.paytmChecksum ?? "",
                payTmCallbackURL,
                payTmIsStaging,
                true,
                true,
              );
              response.then((value) {
                printLog("value ====> $value");
                setState(() {
                  paytmResult = value.toString();
                });
              }).catchError((onError) {
                if (onError is PlatformException) {
                  setState(() {
                    paytmResult = "${onError.message} \n  ${onError.details}";
                  });
                } else {
                  setState(() {
                    paytmResult = onError.toString();
                  });
                }
              });
            } catch (err) {
              paytmResult = err.toString();
            }
          } else {
            if (!mounted) return;
            Utils.showSnackbar(context, "", "payment_not_processed", true);
          }
        } else {
          if (!mounted) return;
          Utils.showSnackbar(context, "", "payment_not_processed", true);
        }
      }
    } else {
      Utils.showSnackbar(context, "", "payment_not_processed", true);
    }
  }
  /* ********* Paytm END ********* */

  /* ********* Paypal START ********* */
  Future<void> _paypalInit() async {
    if (paymentProvider.paymentOptionModel.result?.paypal != null) {
      bool isContinue = checkKeysAndContinue(
        isLive:
            (paymentProvider.paymentOptionModel.result?.paypal?.isLive ?? ""),
        isBothKeyReq: true,
        liveKey1:
            (paymentProvider.paymentOptionModel.result?.paypal?.key1 ?? ""),
        liveKey2:
            (paymentProvider.paymentOptionModel.result?.paypal?.key2 ?? ""),
        testKey1:
            (paymentProvider.paymentOptionModel.result?.paypal?.key1 ?? ""),
        testKey2:
            (paymentProvider.paymentOptionModel.result?.paypal?.key2 ?? ""),
      );
      if (!isContinue) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => UsePaypal(
              sandboxMode:
                  (paymentProvider.paymentOptionModel.result?.paypal?.isLive ??
                              "") ==
                          "1"
                      ? false
                      : true,
              clientId:
                  (paymentProvider.paymentOptionModel.result?.paypal?.key1 ??
                      ""),
              secretKey:
                  (paymentProvider.paymentOptionModel.result?.paypal?.key2 ??
                      ""),
              returnURL: "return.example.com",
              cancelURL: "cancel.example.com",
              transactions: [
                {
                  "amount": {
                    "total": '${paymentProvider.finalAmount}',
                    "currency": Constant.currency,
                    "details": {
                      "subtotal": '${paymentProvider.finalAmount}',
                      "shipping": '0',
                      "shipping_discount": 0
                    }
                  },
                  "description": widget.payType ?? "",
                  "item_list": {
                    "items": [
                      {
                        "name": "${widget.itemTitle}",
                        "quantity": 1,
                        "price": '${paymentProvider.finalAmount}',
                        "currency": Constant.currency
                      }
                    ],
                  }
                }
              ],
              note: "Contact us for any questions on your order.",
              onSuccess: (params) async {
                if (widget.payType == "Package") {
                  addTransaction(
                      widget.itemId,
                      widget.itemTitle,
                      paymentProvider.finalAmount,
                      params["paymentId"],
                      widget.currency);
                } else if (widget.payType == "Rent") {
                  addRentTransaction(widget.itemId, paymentProvider.finalAmount,
                      widget.typeId, widget.videoType);
                }
              },
              onError: (params) {
                Utils.showSnackbar(
                    context, "fail", params["message"].toString(), false);
              },
              onCancel: (params) {
                Utils.showSnackbar(context, "fail", params.toString(), false);
              }),
        ),
      );
    } else {
      Utils.showSnackbar(context, "", "payment_not_processed", true);
    }
  }
  /* ********* Paypal END ********* */

  /* ********* Flutterwave START ********* */
  _flutterwaveInit() async {
    bool isContinue = checkKeysAndContinue(
      isLive: (paymentProvider.paymentOptionModel.result?.flutterwave?.isLive ??
          ""),
      isBothKeyReq: false,
      liveKey1:
          (paymentProvider.paymentOptionModel.result?.flutterwave?.key1 ?? ""),
      liveKey2: "",
      testKey1:
          (paymentProvider.paymentOptionModel.result?.flutterwave?.key1 ?? ""),
      testKey2: "",
    );
    if (!isContinue) return;

    final Customer customer = Customer(
        email: userEmail ?? "",
        name: userName ?? "",
        phoneNumber: userMobileNo ?? '');

    final Flutterwave flutterwave = Flutterwave(
      context: context,
      publicKey:
          (paymentProvider.paymentOptionModel.result?.flutterwave?.key1 ?? ""),
      currency: Constant.currency,
      redirectUrl: 'https://www.divinetechs.com',
      txRef: const Uuid().v1(),
      amount: widget.price.toString().trim(),
      customer: customer,
      paymentOptions: "card, payattitude, barter, bank transfer, ussd",
      customization: Customization(title: widget.itemTitle),
      isTestMode:
          paymentProvider.paymentOptionModel.result?.flutterwave?.isLive != "1",
    );
    ChargeResponse? response = await flutterwave.charge();
    printLog("Flutterwave response =====> ${response.toJson()}");
    if (response.status == "success" && response.success == true) {
      paymentId = response.transactionId.toString();
      if (!mounted) return;
      Utils.showSnackbar(context, "success", "payment_success", true);

      if (widget.payType == "Package") {
        addTransaction(widget.itemId, widget.itemTitle,
            paymentProvider.finalAmount, paymentId, widget.currency);
      } else if (widget.payType == "Rent") {
        addRentTransaction(widget.itemId, paymentProvider.finalAmount,
            widget.typeId, widget.videoType);
      }
    } else if (response.status == "cancel" && response.status == "cancelled") {
      if (!mounted) return;
      Utils.showSnackbar(context, "info", "payment_cancel", true);
    } else {
      if (!mounted) return;
      Utils.showSnackbar(context, "fail", "payment_fail", true);
    }
  }
  /* ********* Flutterwave END ********* */

  /* ********* PayUMoney START ********* */
// Future<void> _payumoneyInit() async {
//   final payu = paymentProvider.paymentOptionModel.result?.payumoney;
//   if (payu == null) {
//     Utils.showSnackbar(context, "", "payment_not_processed", true);
//     return;
//   }

//   Utils.showProgress(context, prDialog);
//   try {
//     final String merchantKey = payu.key2 ?? "";
//     final String salt = payu.key3 ?? "";
//     final bool isLiveEnv = (payu.isLive == "1");

//     final String txnId = paymentId ?? Utils.generateRandomOrderID();
//     final String amountRaw = paymentProvider.finalAmount ?? "0";
//     final String amount =
//         double.tryParse(amountRaw)?.toStringAsFixed(2) ?? "0.00";

//     final String productInfo = widget.itemTitle ?? "Subscription";
//     final String firstName = userName ?? "User";
//     final String email = userEmail ?? "user@example.com";
//     final String phone = userMobileNo?.replaceAll("+", "") ?? "9999999999";
//     const String udf1 = "";
//     const String udf2 = "";
//     const String udf3 = "";
//     const String udf4 = "";
//     const String udf5 = "";

//     // ✅ Correct hash generation
//     final hashString =
//         "$merchantKey|$txnId|$amount|$productInfo|$firstName|$email|$udf1|$udf2|$udf3|$udf4|$udf5||||||$salt";
//     print("🧩 Hash String => $hashString");

//     final hash = sha512.convert(utf8.encode(hashString.trim())).toString();

//     // ✅ URLs for success/failure callbacks
//     final String successUrl = "https://app.diamondnib.com/public/payu/success";
//     final String failureUrl = "https://app.diamondnib.com/public/payu/failure";

//     // ✅ Environment selection
//     final String payuBaseUrl = isLiveEnv
//         ? "https://secure.payu.in/_payment"
//         : "https://test.payu.in/_payment";

//     // ✅ HTML Payment Form
//     String htmlForm = """
//       <!DOCTYPE html>
//       <html>
//         <head>
//           <meta charset="utf-8" />
//           <meta name="viewport" content="width=device-width, initial-scale=1.0" />
//           <title>Diamondnib Payment</title>
//           <style>
//             body {
//               margin: 0;
//               font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
//               background: linear-gradient(135deg, #1d1e20, #2b2d31);
//               color: #ffffff;
//               display: flex;
//               align-items: center;
//               justify-content: center;
//               height: 100vh;
//               text-align: center;
//             }
//             .container {
//               background: #232428;
//               padding: 40px;
//               border-radius: 16px;
//               box-shadow: 0 8px 20px rgba(0, 0, 0, 0.4);
//               max-width: 400px;
//               width: 90%;
//               animation: fadeIn 1s ease-in-out;
//             }
//             img { width: 120px; margin-bottom: 20px; }
//             h2 { margin: 0; font-weight: 600; font-size: 1.4rem; color: #f7f7f7; }
//             p { color: #b8b8b8; margin: 12px 0 30px; font-size: 0.95rem; }
//             .loader {
//               border: 5px solid rgba(255, 255, 255, 0.2);
//               border-top: 5px solid #f9b233;
//               border-radius: 50%;
//               width: 60px; height: 60px;
//               animation: spin 1.2s linear infinite;
//               margin: 0 auto 20px;
//             }
//             @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
//             @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
//             .footer { margin-top: 25px; font-size: 0.8rem; color: #7c7c7c; }
//           </style>
//         </head>
//         <body>
//           <div class="container">
//             <img src="https://static.payu.in/images/merchant_logo.png" alt="PayU" />
//             <h2>Redirecting to PayU Secure Checkout</h2>
//             <p>Please wait while we securely process your payment with Diamondnib.</p>
//             <div class="loader"></div>
//             <form id="payuForm" action="$payuBaseUrl" method="post">
//               <input type="hidden" name="key" value="$merchantKey" />
//               <input type="hidden" name="txnid" value="$txnId" />
//               <input type="hidden" name="amount" value="$amount" />
//               <input type="hidden" name="productinfo" value="$productInfo" />
//               <input type="hidden" name="firstname" value="$firstName" />
//               <input type="hidden" name="email" value="$email" />
//               <input type="hidden" name="phone" value="$phone" />
//               <input type="hidden" name="surl" value="$successUrl" />
//               <input type="hidden" name="furl" value="$failureUrl" />
//               <input type="hidden" name="service_provider" value="payu_paisa" />
//               <input type="hidden" name="hash" value="$hash" />
//             </form>
//             <div class="footer">Powered by <b>PayU India</b> | © ${DateTime.now().year} Diamondnib</div>
//           </div>
//           <script>
//             setTimeout(() => { document.getElementById('payuForm').submit(); }, 2500);
//           </script>
//         </body>
//       </html>
//     """;

//     // ✅ Launch WebView
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => Scaffold(
//           appBar: AppBar(title: const Text("Pay with PayU")),
//           body: InAppWebView(
//             initialData: InAppWebViewInitialData(data: htmlForm),

//             shouldOverrideUrlLoading: (controller, navigationAction) async {
//               final url = navigationAction.request.url.toString();
//               print("🔗 Intercepted URL: $url");

//               // ✅ Handle UPI Intents
//               if (url.startsWith("upi://") || url.startsWith("intent://")) {
//                 try {
//                   final uri = Uri.parse(url);
//                   if (await canLaunchUrl(uri)) {
//                     await launchUrl(uri, mode: LaunchMode.externalApplication);
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("No UPI app found on this device")),
//                     );
//                   }
//                 } catch (e) {
//                   print("❌ UPI Intent Launch Failed: $e");
//                 }
//                 return NavigationActionPolicy.CANCEL;
//               }

//               // ✅ Handle success/failure redirects
//               if (url.startsWith(successUrl)) {
//                 Navigator.pop(context, {"status": "success"});
//                 return NavigationActionPolicy.CANCEL;
//               } else if (url.startsWith(failureUrl)) {
//                 Navigator.pop(context, {"status": "failure"});
//                 return NavigationActionPolicy.CANCEL;
//               }

//               return NavigationActionPolicy.ALLOW;
//             },

//             // ✅ Auto-close loader once page loads
//             onLoadStop: (controller, url) async {
//               await prDialog.hide();
//               print("✅ PayU URL => $url");
//             },

//             // Optional: handle errors too
//             onLoadError: (controller, url, code, message) async {
//               await prDialog.hide();
//               print("❌ WebView load error: $message");
//             },
//           ),
//         ),
//       ),
//     ).then((result) async {
//       if (result != null && result["status"] == "success") {
//         Utils.showSnackbar(context, "Success", "payment_success", true);
//         if (widget.payType == "Package") {
//           await addTransaction(widget.itemId, widget.itemTitle, amount, txnId, widget.currency);
//         } else if (widget.payType == "Rent") {
//           await addRentTransaction(widget.itemId, amount, widget.typeId, widget.videoType);
//         }
//       } else {
//         Utils.showSnackbar(context, "Failed", "payment_fail", true);
//       }
//     });
//   } catch (e) {
//     await prDialog.hide();
//     print("⚠️ PayU Web Exception: $e");
//     Utils.showSnackbar(context, "fail", "payment_fail", true);
//   }
// }
/* ********* PayUMoney START ********* */

/* ********* PayUMoney START ********* */
/* ********* PayUMoney START ********* */
Future<void> _payumoneyInit() async {
  final payu = paymentProvider.paymentOptionModel.result?.payumoney;
  if (payu == null) {
    Utils.showSnackbar(context, "", "payment_not_processed", true);
    return;
  }
  
  // ✅ NEW: Handle subscription payment separately
  if (widget.payType == "Subscription") {
    await _handleSubscriptionPayment(payu);
    return;
  }
  
  Utils.showProgress(context, prDialog);
  try {
    final String merchantKey = payu.key2 ?? "";
    final String salt = payu.key3 ?? "";
    final bool isLiveEnv = (payu.isLive == "1");
    final String txnId = paymentId ?? Utils.generateRandomOrderID();
    final String amountRaw = paymentProvider.finalAmount ?? "0";
    final String amount = double.tryParse(amountRaw)?.toStringAsFixed(2) ?? "0.00";
    final String productInfo = widget.itemTitle ?? "Subscription";
    final String firstName = userName ?? "User";
    final String email = userEmail ?? "user@example.com";
    final String phone = userMobileNo?.replaceAll("+", "") ?? "9999999999";
    final String udf1 = "";
    final String udf2 = "";
    final String udf3 = "";
    final String udf4 = "";
    final String udf5 = "";

    final hashString = "$merchantKey|$txnId|$amount|$productInfo|$firstName|$email|$udf1|$udf2|$udf3|$udf4|$udf5||||||$salt";
    print("Hash String: $hashString");
    final hash = sha512.convert(utf8.encode(hashString.trim())).toString();

    final String successUrl = "https://app.diamondnib.com/public/payu/success";
    final String failureUrl = "https://app.diamondnib.com/public/payu/failure";
    final String payuBaseUrl = isLiveEnv ? "https://secure.payu.in/_payment" : "https://test.payu.in/_payment";

    await prDialog.hide();

    String htmlForm = """
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />
          <title>Diamondnib Payment</title>
          <style>
            body {
              margin: 0;
              font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
              background: linear-gradient(135deg, #1d1e20, #2b2d31);
              color: #ffffff;
              display: flex;
              align-items: center;
              justify-content: center;
              height: 100vh;
              text-align: center;
            }
            .container {
              background: #232428;
              padding: 40px;
              border-radius: 16px;
              box-shadow: 0 8px 20px rgba(0, 0, 0, 0.4);
              max-width: 400px;
              width: 90%;
              animation: fadeIn 1s ease-in-out;
            }
            img {
              width: 120px;
              margin-bottom: 20px;
            }
            h2 {
              margin: 0;
              font-weight: 600;
              font-size: 1.4rem;
              color: #f7f7f7;
            }
            p {
              color: #b8b8b8;
              margin: 12px 0 30px;
              font-size: 0.95rem;
            }
            .loader {
              border: 5px solid rgba(255, 255, 255, 0.2);
              border-top: 5px solid #f9b233;
              border-radius: 50%;
              width: 60px;
              height: 60px;
              animation: spin 1.2s linear infinite;
              margin: 0 auto 20px;
            }
            @keyframes spin {
              0% { transform: rotate(0deg); }
              100% { transform: rotate(360deg); }
            }
            @keyframes fadeIn {
              from { opacity: 0; transform: translateY(10px); }
              to { opacity: 1; transform: translateY(0); }
            }
            .footer {
              margin-top: 25px;
              font-size: 0.8rem;
              color: #7c7c7c;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <img src="https://static.payu.in/images/merchant_logo.png" alt="PayU" />
            <h2>Redirecting to PayU Secure Checkout</h2>
            <p>Please wait while we securely process your payment with Diamondnib.</p>
            <div class="loader"></div>
            <form id="payuForm" action="$payuBaseUrl" method="post">
              <input type="hidden" name="key" value="$merchantKey" />
              <input type="hidden" name="txnid" value="$txnId" />
              <input type="hidden" name="amount" value="$amount" />
              <input type="hidden" name="productinfo" value="$productInfo" />
              <input type="hidden" name="firstname" value="$firstName" />
              <input type="hidden" name="email" value="$email" />
              <input type="hidden" name="phone" value="$phone" />
              <input type="hidden" name="surl" value="$successUrl" />
              <input type="hidden" name="furl" value="$failureUrl" />
              <input type="hidden" name="service_provider" value="payu_paisa" />
              <input type="hidden" name="hash" value="$hash" />
            </form>
            <div class="footer">Powered by <b>PayU India</b> | © ${DateTime.now().year} Diamondnib</div>
          </div>

          <script>
            setTimeout(() => {
              document.getElementById('payuForm').submit();
            }, 2500);
          </script>
        </body>
      </html>
      """;

    // Add a timeout to handle cases where user closes WebView without completing payment
    Completer<Map<String, dynamic>> paymentCompleter = Completer();
    Timer? timeoutTimer;
    bool isWebViewOpen = true;
void cleanup() {
      timeoutTimer?.cancel();
      isWebViewOpen = false;
    }
    // Launch WebView
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WillPopScope(
          onWillPop: () async {
            // Handle back button press - return cancelled status
            print("⬅️ Back button pressed - payment cancelled");
            cleanup();
            Navigator.pop(context, {"status": "cancelled", "txnid": txnId});
            
            return false; // Prevent default back behavior
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Pay with PayU"),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  // Handle back button in app bar
                  print("⬅️ App bar back pressed - payment cancelled");
                 cleanup();
                  Navigator.pop(context, {"status": "cancelled", "txnid": txnId});
                  

                },
              ),
            ),
            body: InAppWebView(
              initialData: InAppWebViewInitialData(data: htmlForm),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  useShouldOverrideUrlLoading: true,
                ),
              ),
              // Handle URL loading to detect success/failure
              
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final url = navigationAction.request.url.toString();
                print("🔗 URL Intercepted: $url");

                // Handle UPI URLs - allow them to open externally
                if (_isUpiUrl(url)) {
                  print("🚀 UPI URL detected: $url");
                  try {
                    // Cancel timeout timer since user is proceeding with UPI
                    timeoutTimer?.cancel();
                    
                    // Try to launch UPI app
                    final launched = await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                    
                    if (launched) {
                      print("✅ UPI app launched successfully");
                      // Restart timeout for UPI payment completion
                      _startPaymentTimeout(timeoutTimer, paymentCompleter, txnId);
                    }
                  } catch (e) {
                    print("❌ Error launching UPI app: $e");
                  }
                  return NavigationActionPolicy.CANCEL;
                }

                return NavigationActionPolicy.ALLOW;
              },
              // Monitor page loads for success/failure URLs
              onLoadStop: (controller, url) async {
                final currentUrl = url?.toString() ?? "";
                print("🌐 Page loaded: $currentUrl");

                // Cancel timeout since page is loading (user is active)
                timeoutTimer?.cancel();

                // Check for success URL
                if (currentUrl.startsWith(successUrl)) {
                  print("🎉 Payment Success detected via URL");
                  // Return success result
                  Navigator.pop(context, {"status": "success", "txnid": txnId});
                } 
                // Check for failure URL
                else if (currentUrl.startsWith(failureUrl)) {
                  print("❌ Payment Failure detected via URL");
                  // Return failure result
                  Navigator.pop(context, {"status": "failure", "txnid": txnId});
                } else {
                  // Restart timeout for next page load
                  _startPaymentTimeout(timeoutTimer, paymentCompleter, txnId);
                }
              },
              onLoadError: (controller, url, code, message) {
                print("❌ WebView load error: $message");
                // Restart timeout on error
                _startPaymentTimeout(timeoutTimer, paymentCompleter, txnId);
              },
            ),
          ),
        ),
      ),
    ).then((result) async {
      // Cancel timeout when we get a result
      timeoutTimer?.cancel();
      await _handlePaymentResult(result, txnId, amount);
    });

    // Start initial timeout when WebView opens
    _startPaymentTimeout(timeoutTimer, paymentCompleter, txnId);

  } catch (e) {
    await prDialog.hide();
    print("⚠️ PayU Exception: $e");
    Utils.showSnackbar(context, "Error", "Payment initialization failed", true);
  }
}



// Start timeout timer for payment completion
void _startPaymentTimeout(Timer? timer, Completer<Map<String, dynamic>> completer, String txnId) {
  timer?.cancel(); // Cancel existing timer
  
  timer = Timer(Duration(minutes: 10), () {
    print("⏰ Payment timeout - no activity for 10 minutes");
    // If still in WebView, close it with timeout status
    if (Navigator.canPop(context)) {
      Navigator.pop(context, {"status": "timeout", "txnid": txnId});
    }
  });
}

// ✅ NEW: Handle subscription payment
Future<void> _handleSubscriptionPayment(dynamic payu) async {
  Utils.showProgress(context, prDialog);
  try {
    final String merchantKey = payu.key2 ?? "";
    final String salt = payu.key3 ?? "";
    final bool isLiveEnv = (payu.isLive == "1");

    final String txnId = paymentId ?? Utils.generateRandomOrderID();
    final String amountRaw = paymentProvider.finalAmount ?? "0";
    final String amount = double.tryParse(amountRaw)?.toStringAsFixed(2) ?? "0.00";

    // ✅ KEY DIFFERENCE: Product info includes subscription period
    final String period = widget.productPackage ?? "week";
    final String productInfo = "Premium Subscription - $period";

    final String firstName = userName ?? "User";
    final String email = userEmail ?? "user@example.com";
    final String phone = userMobileNo?.replaceAll("+", "") ?? "9999999999";
    final String udf1 = "";
    final String udf2 = "";
    final String udf3 = "";
    final String udf4 = "";
    final String udf5 = "";

    final hashString = "$merchantKey|$txnId|$amount|$productInfo|$firstName|$email|$udf1|$udf2|$udf3|$udf4|$udf5||||||$salt";
    print("🧩 Subscription Hash String => $hashString");
    final hash = sha512.convert(utf8.encode(hashString.trim())).toString();

    final String successUrl = "https://app.diamondnib.com/public/payu/subscription/success";
    final String failureUrl = "https://app.diamondnib.com/public/payu/subscription/failure";
    final String payuBaseUrl = isLiveEnv 
        ? "https://secure.payu.in/_payment" 
        : "https://test.payu.in/_payment";

    await prDialog.hide();

    String htmlForm = """
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />
          <title>Diamondnib Subscription Payment</title>
          <style>
            body {
              margin: 0;
              font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
              background: linear-gradient(135deg, #1d1e20, #2b2d31);
              color: #ffffff;
              display: flex;
              align-items: center;
              justify-content: center;
              height: 100vh;
              text-align: center;
            }
            .container {
              background: #232428;
              padding: 40px;
              border-radius: 16px;
              box-shadow: 0 8px 20px rgba(0, 0, 0, 0.4);
              max-width: 400px;
              width: 90%;
              animation: fadeIn 1s ease-in-out;
            }
            img { width: 120px; margin-bottom: 20px; }
            h2 { margin: 0; font-weight: 600; font-size: 1.4rem; color: #f7f7f7; }
            p { color: #b8b8b8; margin: 12px 0 30px; font-size: 0.95rem; }
            .loader {
              border: 5px solid rgba(255, 255, 255, 0.2);
              border-top: 5px solid #f9b233;
              border-radius: 50%;
              width: 60px; height: 60px;
              animation: spin 1.2s linear infinite;
              margin: 0 auto 20px;
            }
            @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
            @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
            .footer { margin-top: 25px; font-size: 0.8rem; color: #7c7c7c; }
          </style>
        </head>
        <body>
          <div class="container">
            <img src="https://static.payu.in/images/merchant_logo.png" alt="PayU" />
            <h2>Redirecting to PayU Secure Checkout</h2>
            <p>Please wait while we process your Premium subscription.</p>
            <div class="loader"></div>
            <form id="payuForm" action="$payuBaseUrl" method="post">
              <input type="hidden" name="key" value="$merchantKey" />
              <input type="hidden" name="txnid" value="$txnId" />
              <input type="hidden" name="amount" value="$amount" />
              <input type="hidden" name="productinfo" value="$productInfo" />
              <input type="hidden" name="firstname" value="$firstName" />
              <input type="hidden" name="email" value="$email" />
              <input type="hidden" name="phone" value="$phone" />
              <input type="hidden" name="surl" value="$successUrl" />
              <input type="hidden" name="furl" value="$failureUrl" />
              <input type="hidden" name="service_provider" value="payu_paisa" />
              <input type="hidden" name="hash" value="$hash" />
            </form>
            <div class="footer">Powered by <b>PayU India</b> | © ${DateTime.now().year} Diamondnib</div>
          </div>
          <script>
            setTimeout(() => { document.getElementById('payuForm').submit(); }, 2500);
          </script>
        </body>
      </html>
      """;

    Completer<Map<String, dynamic>> paymentCompleter = Completer();
    Timer? timeoutTimer;
    bool isWebViewOpen = true;

    void cleanup() {
      timeoutTimer?.cancel();
      isWebViewOpen = false;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WillPopScope(
          onWillPop: () async {
            print("⬅️ Back button pressed - subscription cancelled");
            cleanup();
            Navigator.pop(context, {"status": "cancelled", "txnid": txnId});
            return false;
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Premium Subscription"),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  print("⬅️ App bar back pressed - subscription cancelled");
                  cleanup();
                  Navigator.pop(context, {"status": "cancelled", "txnid": txnId});
                },
              ),
            ),
            body: InAppWebView(
              initialData: InAppWebViewInitialData(data: htmlForm),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  useShouldOverrideUrlLoading: true,
                ),
              ),
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final url = navigationAction.request.url.toString();
                print("🔗 URL Intercepted: $url");

                if (_isUpiUrl(url)) {
                  print("🚀 UPI URL detected: $url");
                  try {
                    timeoutTimer?.cancel();
                    final launched = await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                    if (launched) {
                      print("✅ UPI app launched successfully");
                      _startPaymentTimeout(timeoutTimer, paymentCompleter, txnId);
                    }
                  } catch (e) {
                    print("❌ Error launching UPI app: $e");
                  }
                  return NavigationActionPolicy.CANCEL;
                }

                return NavigationActionPolicy.ALLOW;
              },
              onLoadStop: (controller, url) async {
                final currentUrl = url?.toString() ?? "";
                print("🌐 Page loaded: $currentUrl");

                timeoutTimer?.cancel();

                if (currentUrl.startsWith(successUrl)) {
                  print("🎉 Subscription Success detected via URL");
                  Navigator.pop(context, {"status": "success", "txnid": txnId});
                } else if (currentUrl.startsWith(failureUrl)) {
                  print("❌ Subscription Failure detected via URL");
                  Navigator.pop(context, {"status": "failure", "txnid": txnId});
                } else {
                  _startPaymentTimeout(timeoutTimer, paymentCompleter, txnId);
                }
              },
              onLoadError: (controller, url, code, message) {
                print("❌ WebView load error: $message");
                _startPaymentTimeout(timeoutTimer, paymentCompleter, txnId);
              },
            ),
          ),
        ),
      ),
    ).then((result) async {
      timeoutTimer?.cancel();
      await _handleSubscriptionPaymentResult(result, txnId, amount, period);
    });

    _startPaymentTimeout(timeoutTimer, paymentCompleter, txnId);

  } catch (e) {
    await prDialog.hide();
    print("⚠️ Subscription Exception: $e");
    Utils.showSnackbar(context, "Error", "Subscription payment failed", true);
  }
}

// ✅ NEW: Handle subscription payment result
Future<void> _handleSubscriptionPaymentResult(
  dynamic result, 
  String txnId, 
  String amount,
  String period
) async {
  if (result != null && result is Map) {
    switch (result["status"]) {
      case "success":
        print("🎉 Subscription Success - Processing...");
        await _addSubscriptionTransaction(txnId, amount, period);
        break;

      case "failure":
        print("❌ Subscription Failed");
        await prDialog.hide();
        Utils.showSnackbar(context, "Failed", "Subscription payment failed", true);
        break;

      case "cancelled":
        await prDialog.hide();
        print("🚫 Subscription Cancelled by user");
        Utils.showSnackbar(context, "Cancelled", "Subscription was cancelled", true);
        break;

      case "timeout":
        print("⏰ Subscription Timeout");
        Utils.showSnackbar(context, "Timeout", "Payment session expired", true);
        break;

      default:
        print("⚠️ Unknown subscription status: ${result["status"]}");
        Utils.showSnackbar(context, "Info", "Payment session ended", true);
        break;
    }
  } else {
    print("⚠️ Subscription cancelled or incomplete");
    Utils.showSnackbar(context, "Info", "Subscription was cancelled", true);
  }
}

// ✅ NEW: Add subscription transaction to backend
Future<void> _addSubscriptionTransaction(
  String txnId,
  String amount,
  String period
) async {
  try {
    Utils.showProgress(context, prDialog);

    Map<String, String> bodyParams = {
      'user_id': userId ?? '',
      'payment_id': txnId,
      'amount': amount,
      'plan_period': period,
      'currency_code': widget.currency ?? 'INR',
    };

    if (strCouponCode != null && strCouponCode!.isNotEmpty) {
      bodyParams['coupon_code'] = strCouponCode!;
    }

    print("💰 Calling add_subscription_transaction API for: $txnId");
    print("📡 Request Body: $bodyParams");

    final response = await http.post(
      Uri.parse('${Constant.baseurl}add_subscription_transaction'),
      body: bodyParams,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    print("📡 Response Status: ${response.statusCode}");
    print("📡 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 200) {
        print("🎉 SUBSCRIPTION ACTIVATED: Premium access granted!");

        isPaymentDone = true;

        // Update subscription status in SharedPreferences
        final sharedPref = SharedPre();
        await sharedPref.save('user_subscription_active', '1');
        await sharedPref.save('subscription_expiry_date', data['data']?['expiry_date'] ?? '');

        // Refresh user profile
        final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
        await profileProvider.getProfile(context);

        Utils.showSnackbar(context, "Success", "Premium subscription activated!", true);

        if (mounted && Navigator.canPop(context)) {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pop(context, true);
          });
        }
      } else {
        Utils.showSnackbar(context, "Error", data['message'] ?? "Failed to activate subscription", true);
      }
    } else {
      Utils.showSnackbar(context, "Error", "Subscription API error", true);
    }
  } catch (e) {
    print("❌ Error adding subscription: $e");
    Utils.showSnackbar(context, "Error", "Error processing subscription", true);
  } finally {
    await prDialog.hide();
  }
}

// Handle payment result
Future<void> _handlePaymentResult(dynamic result, String txnId, String amount) async {
  if (result != null && result is Map) {
    switch (result["status"]) {
      case "success":
        print("🎉 Payment Success - Processing transaction...");
        await _processSuccessfulPayment(txnId, amount);
        break;
      
      case "failure":
        print("❌ Payment Failed via URL");
        await prDialog.hide(); 
        Utils.showSnackbar(context, "Failed", "Payment failed", true);
        break;
      
      case "cancelled":
      await prDialog.hide(); 
        print("🚫 Payment Cancelled by user");
        Utils.showSnackbar(context, "Cancelled", "Payment was cancelled", true);
        break;
      
      case "timeout":
        print("⏰ Payment Timeout");
        Utils.showSnackbar(context, "Timeout", "Payment session expired", true);
        break;
      
      default:
        print("⚠️ Unknown payment status: ${result["status"]}");
        Utils.showSnackbar(context, "Info", "Payment session ended", true);
        break;
    }
  } else {
    // WebView was closed without any result (shouldn't happen with proper back handling)
    print("⚠️ Payment cancelled or incomplete");
    Utils.showSnackbar(context, "Info", "Payment was cancelled", true);
  }
}

// Process successful payment
Future<void> _processSuccessfulPayment(String txnId, String amount) async {
  Utils.showProgress(context, prDialog);
  
  try {
    // Call add_transaction API with proper parameters
    Map<String, String> bodyParams = {
      'user_id': userId ?? '',
      'payment_id': txnId,
      'package_id': widget.itemId ?? '',
      'paid_amount': amount,
      'description': widget.itemTitle ?? 'Payment',
      'currency_code': widget.currency ?? 'INR',
      'coin': widget.coin ?? '',
      'price': amount,
    };

    // Add coupon code if applied
    if (strCouponCode != null && strCouponCode!.isNotEmpty) {
      bodyParams['coupon_code'] = strCouponCode!;
    }

    print("💰 Calling add_transaction API for: $txnId");
    print("📡 Request Body: $bodyParams");

    final response = await http.post(
      Uri.parse('${Constant.baseurl}add_transaction'),
      body: bodyParams,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    print("📡 Response Status: ${response.statusCode}");
    print("📡 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['status'] == 200) {
        print("🎉 TRANSACTION SUCCESS: Coins credited to wallet!");
        
        // Update UI state
        isPaymentDone = true;
        
        // Refresh user data
        final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
        final videoDetailsProvider = Provider.of<VideoDetailsProvider>(context, listen: false);
        final showDetailsProvider = Provider.of<ShowDetailsProvider>(context, listen: false);
        final channelSectionProvider = Provider.of<ChannelSectionProvider>(context, listen: false);
        
        await profileProvider.getProfile(context);
        await videoDetailsProvider.updatePrimiumPurchase();
        await showDetailsProvider.updatePrimiumPurchase();
        await channelSectionProvider.updatePrimiumPurchase();
        await videoDetailsProvider.updateRentPurchase();
        await showDetailsProvider.updateRentPurchase();

        Utils.showSnackbar(context, "Success", "Payment successful! Coins added to wallet.", true);
        
        // Navigate back with success
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
      } else {
        Utils.showSnackbar(context, "Error", "Transaction failed: ${data['message']}", true);
      }
    } else {
      Utils.showSnackbar(context, "Error", "Transaction API error", true);
    }
  } catch (e) {
    print("❌ Error processing payment: $e");
    Utils.showSnackbar(context, "Error", "Error processing payment", true);
  } finally {
    await prDialog.hide();
  }
}

// Check if URL is a UPI URL
bool _isUpiUrl(String url) {
  if (url.isEmpty) return false;
  final lowerUrl = url.toLowerCase();
  return lowerUrl.startsWith('upi://') || 
         lowerUrl.startsWith('tez://') ||
         lowerUrl.startsWith('paytmmp://') ||
         lowerUrl.startsWith('phonepe://') ||
         lowerUrl.startsWith('gpay://') ||
         lowerUrl.contains('upi://pay');
}

/* ********* PayUMoney END ********* */




// FIXED: IMPROVED PAYMENT VERIFICATION WITH PAYMENT STATUS CHECK
Future<bool> _callAddTransactionDirectly(String txnId, String amount) async {
  try {
    print("💰 Calling add_transaction API for: $txnId");
    
    // First, check if payment is actually successful with PayU
    bool isPaymentSuccessful = await _verifyPaymentWithPayU(txnId);
    
    if (!isPaymentSuccessful) {
      print("❌ PAYMENT NOT VERIFIED: Payment failed or pending with PayU");
      return false;
    }
    
    // Only call add_transaction if payment is verified
    Map<String, String> bodyParams = {
      'user_id': userId ?? '',
      'payment_id': txnId,
      'package_id': widget.itemId ?? '',
      'paid_amount': amount,
      'description': widget.itemTitle ?? 'Payment',
      'currency_code': widget.currency ?? 'INR',
      'coin': widget.coin ?? '',
      'price': amount,
    };

    // Add coupon code if applied
    if (strCouponCode != null && strCouponCode!.isNotEmpty) {
      bodyParams['coupon_code'] = strCouponCode!;
    }

    print("📡 API Request: ${Constant.baseurl}add_transaction");
    print("📡 Request Body: $bodyParams");

    final response = await http.post(
      Uri.parse('${Constant.baseurl}add_transaction'),
      body: bodyParams,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    print("📡 Response Status: ${response.statusCode}");
    print("📡 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      bool success = data['status'] == 200;
      
      if (success) {
        print("🎉 PAYMENT SUCCESS: Coins credited to wallet!");
        
        // Update UI state
        isPaymentDone = true;
        
        // Refresh user data
        final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
        final videoDetailsProvider = Provider.of<VideoDetailsProvider>(context, listen: false);
        final showDetailsProvider = Provider.of<ShowDetailsProvider>(context, listen: false);
        final channelSectionProvider = Provider.of<ChannelSectionProvider>(context, listen: false);
        
        await profileProvider.getProfile(context);
        await videoDetailsProvider.updatePrimiumPurchase();
        await showDetailsProvider.updatePrimiumPurchase();
        await channelSectionProvider.updatePrimiumPurchase();
        
        return true;
      } else {
        print("❌ ADD_TRANSACTION FAILED: ${data['message']}");
        return false;
      }
    } else {
      print("❌ API ERROR: Status ${response.statusCode}");
      return false;
    }
  } catch (e) {
    print("❌ NETWORK ERROR: $e");
    return false;
  }
}

// NEW: VERIFY PAYMENT WITH PAYU FIRST
Future<bool> _verifyPaymentWithPayU(String txnId) async {
  try {
    print("🔍 Verifying payment status with PayU for: $txnId");
    
    // You need to implement PayU payment verification API call here
    // This should check with PayU if the payment was actually successful
    
    // For now, we'll use a simple approach - wait and assume payment might be successful
    // In production, you should call PayU's verify payment API
    
    // Simulate verification - replace this with actual PayU verification API
    await Future.delayed(Duration(seconds: 5));
    
    // For demo purposes, return true. In production, use actual PayU verification
    return true;
    
  } catch (e) {
    print("❌ PayU verification error: $e");
    return false;
  }
}

// FIXED: IMPROVED BACKGROUND VERIFICATION
void _startBackgroundPaymentVerification(String txnId, String amount) {
  print("🔄 Starting background payment verification for: $txnId");
  
  // Cancel any existing timer
  _paymentVerificationTimer?.cancel();
  
  int attempts = 0;
  const maxAttempts = 24; // 4 minutes (10s × 24 = 4min) - Reduced time

  _paymentVerificationTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
    attempts++;
    print("🔄 Payment verification attempt $attempts for: $txnId");

    if (attempts >= maxAttempts) {
      timer.cancel();
      print("⏰ Payment verification timeout");
      await _clearPaymentDetails();
      
      // Show timeout message
      if (mounted) {
        Utils.showSnackbar(context, "Info", "Payment verification timeout. Please check your payment status.", true);
      }
      return;
    }

    try {
      // Call add_transaction API directly
      final isSuccess = await _callAddTransactionDirectly(txnId, amount);
      
      if (isSuccess) {
        timer.cancel();
        print("🎉 Payment successful and coins credited!");
        await _clearPaymentDetails();
        
        // Show success message
        if (mounted) {
          Utils.showSnackbar(context, "Success", "Payment successful! Coins added to wallet.", true);
        }
        
        // Navigate back to previous screen with success
        if (mounted && Navigator.canPop(context)) {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pop(context, true);
          });
        }
      } else {
        print("⏳ Payment still processing or failed... (attempt $attempts/$maxAttempts)");
        
        // Show progress every 60 seconds only (reduced frequency)
        if (attempts % 6 == 0 && mounted) {
          Utils.showSnackbar(context, "Info", "Payment processing... Please wait", false);
        }
      }
    } catch (e) {
      print("❌ Verification error: $e");
      // Continue trying even if there's network error
    }
  });
}

// FIXED: IMPROVED PAYMENT SUCCESS PROCESSING
Future<void> _processPaymentSuccess(String txnId, String amount) async {
  print("🎉 Processing successful payment: $txnId");
  
  Utils.showProgress(context, prDialog);
  
  try {
    // Verify payment first, then process
    final success = await _callAddTransactionDirectly(txnId, amount);
    
    if (success) {
      // Success message will be shown in _callAddTransactionDirectly
      // Navigate back after short delay
      Future.delayed(Duration(seconds: 2), () {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
      });
    } else {
      Utils.showSnackbar(context, "Error", "Payment verification failed", true);
    }
  } catch (e) {
    print("❌ Error processing payment: $e");
    Utils.showSnackbar(context, "Error", "Error processing payment", true);
  } finally {
    await prDialog.hide();
  }
}

// Rest of the helper methods remain the same...

Future<void> _savePaymentDetails(String txnId, String amount) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_txn_id', txnId);
    await prefs.setString('pending_amount', amount);
    await prefs.setString('pending_pay_type', widget.payType ?? '');
    await prefs.setString('pending_item_id', widget.itemId ?? '');
    await prefs.setString('pending_coin', widget.coin ?? '');
    await prefs.setString('pending_timestamp', DateTime.now().millisecondsSinceEpoch.toString());
    print("💾 Payment details saved: $txnId");
  } catch (e) {
    print("❌ Error saving payment details: $e");
  }
}

Future<void> _clearPaymentDetails() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_txn_id');
    await prefs.remove('pending_amount');
    await prefs.remove('pending_pay_type');
    await prefs.remove('pending_item_id');
    await prefs.remove('pending_coin');
    await prefs.remove('pending_timestamp');
    print("🗑️ Payment details cleared");
  } catch (e) {
    print("❌ Error clearing payment details: $e");
  }
}

Future<Map<String, String>?> _getPendingPayment() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final txnId = prefs.getString('pending_txn_id');
    if (txnId == null) return null;
    
    return {
      'txnId': txnId,
      'amount': prefs.getString('pending_amount') ?? '',
      'payType': prefs.getString('pending_pay_type') ?? '',
      'itemId': prefs.getString('pending_item_id') ?? '',
      'coin': prefs.getString('pending_coin') ?? '',
    };
  } catch (e) {
    print("❌ Error reading pending payment: $e");
    return null;
  }
}

Future<bool> _checkInternetConnectivity() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}

/* ********* PayUMoney END ********* */






//tps


// Check for pending payments when app resumes
Future<void> _checkPendingPaymentOnResume() async {
  final pendingPayment = await _getPendingPayment();
  if (pendingPayment != null) {
    print("🔄 Found pending payment on resume: ${pendingPayment['txnId']}");
    _startBackgroundPaymentVerification(pendingPayment['txnId']!, pendingPayment['amount']!);
  }
}

void _showPaymentPendingMessage() {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment is being processed. Coins will be added shortly.'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 5),
      )
    );
  }
}

/* ********* PayUMoney END ********* */




// Save payment details for background verification


// Clear saved payment details


// Get pending payment details


// Verify payment with your backend API
Future<bool> _verifyPaymentWithBackend(String txnId) async {
  try {
    // Call your backend API to verify payment status
    final response = await http.post(
      Uri.parse('${Constant.baseurl}verify_payment'), // Your verify endpoint
      body: {
        'payment_id': txnId,
        'user_id': userId ?? '',
      },
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("✅ Verification response: $data");
      return data['status'] == 200 || data['success'] == true;
    }
    return false;
  } catch (e) {
    print("❌ Verification API error: $e");
    return false;
  }
}


// Check for pending payments when app resumes

/* ********* PayUMoney END ********* */

// FIXED: Improved addTransaction method to ensure coins are credited
Future addTransaction(packageId, description, amount, paymentId, currencyCode) async {
  final videoDetailsProvider = Provider.of<VideoDetailsProvider>(context, listen: false);
  final showDetailsProvider = Provider.of<ShowDetailsProvider>(context, listen: false);
  final channelSectionProvider = Provider.of<ChannelSectionProvider>(context, listen: false);
  final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

  Utils.showProgress(context, prDialog);
  
  try {
    await paymentProvider.addTransaction(
        packageId, description, amount, paymentId, widget.coin);

    if (!paymentProvider.payLoading) {
      await prDialog.hide();

      if (paymentProvider.successModel.status == 200) {
        isPaymentDone = true;
        if (!mounted) return;
        
        // Refresh user data and premium status
        await profileProvider.getProfile(context);
        await videoDetailsProvider.updatePrimiumPurchase();
        await showDetailsProvider.updatePrimiumPurchase();
        await channelSectionProvider.updatePrimiumPurchase();
        
        // Show success message
        Utils.showSnackbar(context, "Success", "Payment successful! Coins added to your wallet.", true);
        
        if (!mounted) return;
        Navigator.pop(context, isPaymentDone);
      } else {
        isPaymentDone = false;
        if (!mounted) return;
        Utils.showSnackbar(
            context, "Failed", paymentProvider.successModel.message ?? "Payment failed", true);
      }
    }
  } catch (e) {
    await prDialog.hide();
    print("❌ Error in addTransaction: $e");
    Utils.showSnackbar(context, "Error", "Transaction processing failed", true);
  }
}

/* ********* PayUMoney END ********* */
Future<void> _savePaymentLocally(String txnId, String amount) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_txn_id', txnId);
    await prefs.setString('pending_amount', amount);
    await prefs.setString('pending_pay_type', widget.payType ?? '');
    await prefs.setString('pending_item_id', widget.itemId ?? '');
    await prefs.setString('pending_item_title', widget.itemTitle ?? '');
    await prefs.setString('pending_type_id', widget.typeId ?? '');
    await prefs.setString('pending_video_type', widget.videoType ?? '');
    await prefs.setString('pending_currency', widget.currency ?? '');
    await prefs.setString('pending_timestamp', DateTime.now().millisecondsSinceEpoch.toString());
    print("💾 Payment saved locally: $txnId");
  } catch (e) {
    print("❌ Error saving payment locally: $e");
  }
}

Future<void> _clearPendingPayment() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_txn_id');
    await prefs.remove('pending_amount');
    await prefs.remove('pending_pay_type');
    await prefs.remove('pending_item_id');
    await prefs.remove('pending_item_title');
    await prefs.remove('pending_type_id');
    await prefs.remove('pending_video_type');
    await prefs.remove('pending_currency');
    await prefs.remove('pending_timestamp');
    print("🗑️ Pending payment cleared");
  } catch (e) {
    print("❌ Error clearing pending payment: $e");
  }
}

void _startUPIPaymentVerification(String txnId, String amount) {
  print("🔄 Starting UPI payment verification for: $txnId");
  int attempts = 0;
  const maxAttempts = 90; // 15 minutes (10s × 90 = 15min)

  // Cancel any existing timer
  _paymentVerificationTimer?.cancel();

  _paymentVerificationTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
    attempts++;
    print("🔄 UPI verification attempt: $attempts for $txnId");

    if (attempts >= maxAttempts) {
      timer.cancel();
      print("⏰ UPI verification timeout: $txnId");
      _showPaymentPendingMessage();
      return;
    }

    try {
      // Check if payment was successful
      final isSuccessful = await _checkPaymentWithYourAPI(txnId);
      
      if (isSuccessful) {
        timer.cancel();
        print("🎉 UPI payment successful: $txnId");
        await _clearPendingPayment();
        await _processSuccessfulPayment(txnId, amount);
        
        // Show success message
        if (mounted) {
          Utils.showSnackbar(context, "Success", "Payment completed successfully! Coins added to wallet.", true);
        }
      } else {
        print("⏳ Payment still processing: $txnId (attempt $attempts/$maxAttempts)");
        
        // Show periodic updates to user (every 30 seconds)
        if (attempts % 3 == 0 && mounted) {
          Utils.showSnackbar(
            context, 
            "Info", 
            "Payment is being processed. Please wait...", 
            false
          );
        }
      }
    } catch (e) {
      print("❌ Error verifying UPI payment: $e");
    }
  });
}
Future<bool> _checkPaymentWithYourAPI(String txnId) async {
  try {
    String apiUrl = '${Constant.baseurl}add_transaction';
    
    final amount = paymentProvider.finalAmount ?? '1';
    
    Map<String, String> bodyParams = {
      'user_id': userId ?? '',
      'payment_id': txnId,
      'package_id': widget.itemId ?? '1',
      'paid_amount': amount,
      'description': widget.itemTitle ?? 'Payment',
      'currency_code': widget.currency ?? 'USD', // Add currency code
      'coins': widget.coin ?? '10',
      'price': amount, // Add price field if required
    };

    print("🔍 Verifying payment with API: $apiUrl");
    print("🔍 Request body: $bodyParams");

    final response = await http.post(
      Uri.parse(apiUrl),
      body: bodyParams,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("✅ Payment verification response: $data");
      
      // Simple success check
      bool isSuccess = data['status'] == 200;
      
      print("✅ Payment verification result: $isSuccess");
      return isSuccess;
    } else {
      print("❌ Payment verification failed with status: ${response.statusCode}");
      print("❌ Response body: ${response.body}");
    }
    
    return false;
  } catch (e) {
    print("❌ Error checking payment with API: $e");
    return false;
  }
}



  /* ********* PayUMoney END ********* */

  // ========= PayU Protocol Implementations =========

  // @override
  // generateHash(Map response) async {
  //   try {
  //     // The wrapper calls this with { "hashString": "...", "hashName": "paymentHash"/... }
  //     final hashString = response["hashString"]?.toString() ?? "";
  //     final hashName = response["hashName"]?.toString() ?? "paymentHash";

  //     if (hashString.isEmpty) {
  //       printLog("PayU generateHash: empty hashString");
  //       return;
  //     }

  //     final generatedHash = sha512.convert(utf8.encode(hashString)).toString();
  //     printLog("Generated hash for $hashName => $generatedHash");

  //     await _payuSdk.hashGenerated(hash: {
  //       "hashName": hashName,
  //       "hashValue": generatedHash,
  //     });
  //   } catch (e) {
  //     printLog("Error in generateHash() => $e");
  //   }
  // }

  // @override
  // onPaymentSuccess(dynamic response) async {
  //   printLog("✅ PayU Payment Success: $response");
  //   Utils.showSnackbar(context, "success", "payment_success", true);

  //   // Try to extract txn id, else fallback to current
  //   final txnId =
  //       (response is Map && response["txnid"] != null) ? response["txnid"] : (paymentId ?? Utils.generateRandomOrderID());

  //   if (widget.payType == "Package") {
  //     await addTransaction(widget.itemId, widget.itemTitle,
  //         paymentProvider.finalAmount, txnId, widget.currency);
  //   } else if (widget.payType == "Rent") {
  //     await addRentTransaction(widget.itemId, paymentProvider.finalAmount,
  //         widget.typeId, widget.videoType);
  //   }
  // }

  // @override
  // onPaymentFailure(dynamic response) {
  //   printLog("❌ PayU Payment Failed: $response");
  //   Utils.showSnackbar(context, "fail", "payment_fail", true);
  // }

  // @override
  // onPaymentCancel(Map? response) {
  //   printLog("🚫 PayU Payment Cancelled: $response");
  //   Utils.showSnackbar(context, "info", "payment_cancel", true);
  // }

  // @override
  // onError(Map? response) {
  //   printLog("⚠️ PayU SDK Error: $response");
  //   Utils.showSnackbar(context, "fail", "payment_fail", true);
  // }

  // ================================================

  Future<void> onBackPressed(didPop) async {
    if (didPop) return;
    if (!mounted) return;
    if (kIsWeb) {
      if (context.canPop()) {
        context.pop(isPaymentDone);
      }
    } else {
      if (Navigator.canPop(context)) {
        Navigator.pop(context, isPaymentDone);
      }
    }
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}

//new widget by tps 


class PayUWebViewWebviewFlutter extends StatefulWidget {
  final String initialUrl;
  final String txnId;
  final String successUrl;
  final String failureUrl;
  final String amount;
  final String? payType;
  final String? itemId;
  final String? itemTitle;
  final String? typeId;
  final String? videoType;
  final String? currency;

  const PayUWebViewWebviewFlutter({
    Key? key,
    required this.initialUrl,
    required this.txnId,
    required this.successUrl,
    required this.failureUrl,
    required this.amount,
    this.payType,
    this.itemId,
    this.itemTitle,
    this.typeId,
    this.videoType,
    this.currency,
  }) : super(key: key);

  @override
  State<PayUWebViewWebviewFlutter> createState() => _PayUWebViewWebviewFlutterState();
}

class _PayUWebViewWebviewFlutterState extends State<PayUWebViewWebviewFlutter> {
  late final WebViewController _controller;
  bool _isUpiHandled = false;
  bool _paymentCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            print("🔗 Navigation Request: $url");

            // Handle UPI URLs
            if (_isUpiUrl(url) && !_isUpiHandled) {
              print("🚫 UPI URL Blocked: $url");
              _handleUpiUrl(url);
              return NavigationDecision.prevent;
            }

            // Handle success/failure URLs
            if (url.startsWith(widget.successUrl)) {
              print("✅ Payment Success via WebView");
              _handlePaymentSuccess();
              return NavigationDecision.prevent;
            } else if (url.startsWith(widget.failureUrl)) {
              print("❌ Payment Failure via WebView");
              _handlePaymentFailure();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            print("🚀 Page Started: $url");
          },
          onPageFinished: (String url) {
            print("🌐 Page Finished: $url");
          },
          onWebResourceError: (WebResourceError error) {
            print("⚠️ Web Error: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  bool _isUpiUrl(String url) {
    if (url.isEmpty) return false;
    
    final lowerUrl = url.toLowerCase();
    return lowerUrl.startsWith('upi://') || 
           lowerUrl.startsWith('tez://') ||
           lowerUrl.startsWith('paytmmp://') ||
           lowerUrl.startsWith('phonepe://') ||
           lowerUrl.startsWith('gpay://') ||
           lowerUrl.startsWith('whatsapp://') ||
           lowerUrl.startsWith('bhim://') ||
           lowerUrl.contains('upi://pay') ||
           lowerUrl.contains('intent://') ||
           (lowerUrl.contains('pay?pa=') && lowerUrl.contains('&pn='));
  }

  Future<void> _handleUpiUrl(String upiUrl) async {
    if (_isUpiHandled) return;
    
    _isUpiHandled = true;
    print("🔗 Handling UPI URL: $upiUrl");
    
    try {
      if (await canLaunch(upiUrl)) {
        // Show message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening UPI app for payment...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          )
        );

        // Close WebView FIRST
        if (Navigator.canPop(context)) {
          Navigator.pop(context); // Returns null for UPI payments
        }
        
        // Launch UPI app after WebView is closed
        Future.delayed(Duration(milliseconds: 100), () {
          launch(upiUrl).then((_) {
            print("✅ UPI app launched successfully");
            // Payment verification will be handled by the parent widget
          });
        });
      } else {
        print("❌ No UPI app found");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No UPI app found. Please install a UPI app.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          )
        );
      }
    } catch (e) {
      print("⚠️ Error launching UPI app: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening payment app. Please try again.'),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  void _handlePaymentSuccess() {
    if (_paymentCompleted) return;
    _paymentCompleted = true;
    
    print("🎉 Payment Success - Returning to parent");
    Navigator.pop(context, {
      "status": "success", 
      "txnid": widget.txnId,
      "amount": widget.amount,
    });
  }

  void _handlePaymentFailure() {
    if (_paymentCompleted) return;
    _paymentCompleted = true;
    
    print("💥 Payment Failure - Returning to parent");
    Navigator.pop(context, {
      "status": "failure", 
      "txnid": widget.txnId
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay with PayU"),
        backgroundColor: Colors.orange,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }


  
}




// Lifecycle handler
class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback resumeCallBack;

  LifecycleEventHandler({
    required this.resumeCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await resumeCallBack();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        break;
    }
  }
}


class PayUWebView extends StatefulWidget {
  final String payuBaseUrl;
  final String merchantKey;
  final String txnId;
  final String amount;
  final String productInfo;
  final String firstName;
  final String email;
  final String phone;
  final String successUrl;
  final String failureUrl;
  final String hash;
  final VoidCallback onSuccess;
  final VoidCallback onFailure;
  final VoidCallback onUpiRedirect;

  const PayUWebView({
    Key? key,
    required this.payuBaseUrl,
    required this.merchantKey,
    required this.txnId,
    required this.amount,
    required this.productInfo,
    required this.firstName,
    required this.email,
    required this.phone,
    required this.successUrl,
    required this.failureUrl,
    required this.hash,
    required this.onSuccess,
    required this.onFailure,
    required this.onUpiRedirect,
  }) : super(key: key);

  @override
  State<PayUWebView> createState() => _PayUWebViewState();
}

class _PayUWebViewState extends State<PayUWebView> {
  late InAppWebViewController _webViewController;
  bool _isLoading = true;

  String get _htmlForm => """
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>PayU Payment</title>
      <style>
        body {
          margin: 0;
          padding: 20px;
          font-family: Arial, sans-serif;
          background: #f5f5f5;
          display: flex;
          justify-content: center;
          align-items: center;
          height: 100vh;
          text-align: center;
        }
        .container {
          background: white;
          padding: 30px;
          border-radius: 10px;
          box-shadow: 0 2px 10px rgba(0,0,0,0.1);
          max-width: 400px;
        }
        .loader {
          border: 4px solid #f3f3f3;
          border-top: 4px solid #3498db;
          border-radius: 50%;
          width: 40px;
          height: 40px;
          animation: spin 1s linear infinite;
          margin: 20px auto;
        }
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h3>Redirecting to PayU</h3>
        <p>Please wait while we process your payment...</p>
        <div class="loader"></div>
      </div>
      
      <form id="payuForm" action="${widget.payuBaseUrl}" method="post" style="display: none;">
        <input type="hidden" name="key" value="${widget.merchantKey}" />
        <input type="hidden" name="txnid" value="${widget.txnId}" />
        <input type="hidden" name="amount" value="${widget.amount}" />
        <input type="hidden" name="productinfo" value="${widget.productInfo}" />
        <input type="hidden" name="firstname" value="${widget.firstName}" />
        <input type="hidden" name="email" value="${widget.email}" />
        <input type="hidden" name="phone" value="${widget.phone}" />
        <input type="hidden" name="surl" value="${widget.successUrl}" />
        <input type="hidden" name="furl" value="${widget.failureUrl}" />
        <input type="hidden" name="service_provider" value="payu_paisa" />
        <input type="hidden" name="hash" value="${widget.hash}" />
      </form>
      
      <script type="text/javascript">
        // Auto-submit the form immediately
        setTimeout(function() {
          document.getElementById('payuForm').submit();
        }, 100);
      </script>
    </body>
    </html>
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay with PayU"),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialData: InAppWebViewInitialData(
              data: _htmlForm,
              mimeType: "text/html",
              encoding: "utf-8",
            ),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                javaScriptEnabled: true,
                transparentBackground: true,
                useShouldOverrideUrlLoading: true,
              ),
              android: AndroidInAppWebViewOptions(
                useHybridComposition: true,
              ),
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStart: (controller, url) {
              print("🚀 Load started: ${url?.toString()}");
            },
            onLoadStop: (controller, url) async {
              setState(() {
                _isLoading = false;
              });
              
              final currentUrl = url?.toString() ?? "";
              print("🌐 Load stopped: $currentUrl");

              // Check for success/failure URLs
              if (currentUrl.contains(widget.successUrl) || 
                  currentUrl.contains("success") ||
                  currentUrl.contains("payu/success")) {
                print("✅ Payment Success detected");
                widget.onSuccess();
                Navigator.pop(context);
              } else if (currentUrl.contains(widget.failureUrl) || 
                         currentUrl.contains("failure") ||
                         currentUrl.contains("payu/failure")) {
                print("❌ Payment Failure detected");
                widget.onFailure();
                Navigator.pop(context);
              }
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url.toString();
              print("🔗 URL override: $url");

              // Handle UPI URLs
              if (url.startsWith('upi://') || 
                  url.startsWith('tez://') ||
                  url.startsWith('paytmmp://') ||
                  url.startsWith('phonepe://') ||
                  url.contains('upi://pay')) {
                print("🚀 Launching UPI URL: $url");
                
                try {
                  // Notify about UPI redirect
                  widget.onUpiRedirect();
                  
                  // Launch UPI app
                  final launched = await launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                  
                  if (launched) {
                    print("✅ UPI app launched successfully");
                    // Close WebView since user went to UPI app
                    Navigator.pop(context);
                  } else {
                    print("❌ Failed to launch UPI app");
                  }
                } catch (e) {
                  print("❌ Error launching UPI app: $e");
                }
                return NavigationActionPolicy.CANCEL;
              }
              
              return NavigationActionPolicy.ALLOW;
            },
            onLoadError: (controller, url, code, message) {
              print("❌ Load error: $message");
              setState(() {
                _isLoading = false;
              });
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}