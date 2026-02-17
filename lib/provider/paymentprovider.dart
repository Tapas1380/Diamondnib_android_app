import 'package:diamondnib/model/couponmodel.dart';
import 'package:diamondnib/model/paymentoptionmodel.dart';
import 'package:diamondnib/model/paytmmodel.dart';
import 'package:diamondnib/model/successmodel.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/webservice/apiservices.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';


class PaymentProvider extends ChangeNotifier {
  PaymentOptionModel paymentOptionModel = PaymentOptionModel();
  PayTmModel payTmModel = PayTmModel();
  SuccessModel successModel = SuccessModel();
  CouponModel couponModel = CouponModel();

  bool loading = false, payLoading = false, couponLoading = false;
  String? currentPayment = "", finalAmount = "";

  Future<void> getPaymentOption() async {
    loading = true;
    paymentOptionModel = await ApiService().getPaymentOption();
    printLog("getPaymentOption status :==> ${paymentOptionModel.status}");
    printLog("getPaymentOption message :==> ${paymentOptionModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> applyPackageCouponCode(couponCode, packageId) async {
    printLog("applyPackageCouponCode couponCode :==> $couponCode");
    printLog("applyPackageCouponCode packageId :==> $packageId");
    couponLoading = true;
    couponModel = await ApiService().applyPackageCoupon(couponCode, packageId);
    printLog("applyPackageCouponCode status :==> ${couponModel.status}");
    printLog("applyPackageCouponCode message :==> ${couponModel.message}");
    couponLoading = false;
    notifyListeners();
  }
    /// Fetch PayU Money hash from your backend API
    /// Generate PayU Money hash locally (temporary fallback).
  Future<Map<String, dynamic>> getPayUMoneyHash(
    String merchantKey,
    String salt,
    String txnId,
    String amount,
    String productInfo,
    String firstName,
    String email,
  ) async {
    try {
      // Ensure amount has 2 decimal places
      final formattedAmount = double.parse(amount).toStringAsFixed(2);

      // Build the hash string
      final hashSequence =
          "$merchantKey|$txnId|$formattedAmount|$productInfo|$firstName|$email|||||||||||$salt";
      printLog("PayU Hash String => $hashSequence");

      // Generate SHA-512 hash
      final bytes = utf8.encode(hashSequence);
      final hash = sha512.convert(bytes).toString();

      printLog("Generated PayU Hash => $hash");

      // Return simulated response
      return {
        "status": true,
        "hash": hash,
      };
    } catch (e) {
      printLog("getPayUMoneyHash Error => $e");
      return {"status": false};
    }
  }




  Future<void> applyRentCouponCode(
      couponCode, videoId, typeId, videoType, price) async {
    printLog("applyRentCouponCode couponCode :==> $couponCode");
    printLog("applyRentCouponCode videoId :==> $videoId");
    printLog("applyRentCouponCode typeId :==> $typeId");
    printLog("applyRentCouponCode videoType :==> $videoType");
    printLog("applyRentCouponCode price :==> $price");
    couponLoading = true;
    couponModel = await ApiService()
        .applyRentCoupon(couponCode, videoId, typeId, videoType, price);
    printLog("applyRentCouponCode status :==> ${couponModel.status}");
    printLog("applyRentCouponCode message :==> ${couponModel.message}");
    couponLoading = false;
    notifyListeners();
  }

  setFinalAmount(String? amount) {
    finalAmount = amount;
    printLog("setFinalAmount finalAmount :==> $finalAmount");
    notifyListeners();
  }

  Future<void> getPaytmToken(merchantID, orderId, custmoreID, channelID,
      txnAmount, website, callbackURL, industryTypeID) async {
    printLog("getPaytmToken merchantID :=======> $merchantID");
    printLog("getPaytmToken orderId :==========> $orderId");
    printLog("getPaytmToken custmoreID :=======> $custmoreID");
    printLog("getPaytmToken channelID :========> $channelID");
    printLog("getPaytmToken txnAmount :========> $txnAmount");
    printLog("getPaytmToken website :==========> $merchantID");
    printLog("getPaytmToken callbackURL :======> $merchantID");
    printLog("getPaytmToken industryTypeID :===> $industryTypeID");
    loading = true;
    payTmModel = await ApiService().getPaytmToken(merchantID, orderId,
        custmoreID, channelID, txnAmount, website, callbackURL, industryTypeID);
    printLog("getPaytmToken status :===> ${payTmModel.status}");
    printLog("getPaytmToken message :==> ${payTmModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> addTransaction(
    packageId,
    description,
    amount,
    transactionId,
    coin,
  ) async {
    printLog("addTransaction userID :==> ${Constant.userID}");
    printLog("addTransaction packageId :==> $packageId");
    payLoading = true;
    successModel = await ApiService().addTransaction(
      packageId,
      description,
      amount,
      transactionId,
      coin,
    );
    printLog("addTransaction status :==> ${successModel.status}");
    printLog("addTransaction message :==> ${successModel.message}");
    payLoading = false;
    notifyListeners();
  }

  Future<void> addRentTransaction(
      videoId, amount, typeId, videoType, couponCode) async {
    printLog("addRentTransaction userID :==> ${Constant.userID}");
    printLog("addRentTransaction videoId :==> $videoId");
    printLog("addRentTransaction couponCode :==> $couponCode");
    payLoading = true;
    successModel = await ApiService()
        .addRentTransaction(videoId, amount, typeId, videoType, couponCode);
    printLog("addRentTransaction status :==> ${successModel.status}");
    printLog("addRentTransaction message :==> ${successModel.message}");
    payLoading = false;
    notifyListeners();
  }

  setCurrentPayment(String? payment) {
    currentPayment = payment;
    notifyListeners();
  }

  clearProvider() {
    printLog("<================ clearProvider ================>");
    currentPayment = "";
    finalAmount = "";
    paymentOptionModel = PaymentOptionModel();
    successModel = SuccessModel();
  }
}
