import 'dart:io';

import 'package:diamondnib/model/generalsettingmodel.dart';
import 'package:diamondnib/model/loginregistermodel.dart';
import 'package:diamondnib/model/pagesmodel.dart';
import 'package:diamondnib/model/successmodel.dart';
import 'package:diamondnib/utils/adhelper.dart';
import 'package:diamondnib/utils/sharedpre.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/webservice/apiservices.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GeneralProvider extends ChangeNotifier {
  GeneralSettingModel generalSettingModel = GeneralSettingModel();
  PagesModel pagesModel = PagesModel();
  LoginRegisterModel loginSocialModel = LoginRegisterModel();
  LoginRegisterModel loginOTPModel = LoginRegisterModel();
  LoginRegisterModel loginEmailModel = LoginRegisterModel();
  LoginRegisterModel loginTVModel = LoginRegisterModel();
  SuccessModel logoutmodel = SuccessModel();
  SuccessModel forgotPasswordModel = SuccessModel();

  bool loading = false;
  String? appDescription;

  SharedPre sharedPre = SharedPre();

  Future<void> getGeneralsetting(BuildContext context) async {
    loading = true;
    try {
      // Add web-specific handling to prevent infinite loops
      if (kIsWeb) {
        // For web, use a timeout and fallback to prevent CORS infinite loops
        generalSettingModel = await ApiService().genaralSetting().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            printLog("generalSetting timeout - using fallback for web");
            // Return a mock/empty model to prevent infinite retries
            return GeneralSettingModel();
          },
        );
      } else {
        generalSettingModel = await ApiService().genaralSetting();
      }
      printLog('generalSettingData status ==> ${generalSettingModel.status}');
      if (generalSettingModel.status == 200) {
        if (generalSettingModel.result != null) {
          for (var i = 0; i < (generalSettingModel.result?.length ?? 0); i++) {
            await sharedPre.save(
              generalSettingModel.result?[i].key.toString() ?? "",
              generalSettingModel.result?[i].value.toString() ?? "",
            );
            printLog(
                '${generalSettingModel.result?[i].key.toString()} ==> ${generalSettingModel.result?[i].value.toString()}');
          }

          appDescription = await sharedPre.read("app_desripation") ?? "";
          printLog("appDescription ===========> $appDescription");
          /* Get Ads Init */
          if (context.mounted && !kIsWeb) {
            AdHelper.getAds(context);
          }
        }
      }
    } catch (e) {
      printLog("generalSetting error :==> $e");
      // Prevent infinite retries by setting empty model
      generalSettingModel = GeneralSettingModel();
    }
    loading = false;
    notifyListeners();
  }

  Future<void> getPages() async {
    loading = true;
    pagesModel = await ApiService().getPages();
    printLog("getPages status :==> ${pagesModel.status}");
    loading = false;
    notifyListeners();
  }

  Future<void> getsignout() async {
    loading = true;
    logoutmodel = await ApiService().logout();
    printLog("getlogoutmodelPages status :==> ${logoutmodel.status}");
    loading = false;
    notifyListeners();
  }

  Future<void> loginWithSocial(
      email, name, type, deviceType, File? profileImg) async {
    printLog("loginWithSocial email :==> $email");
    printLog("loginWithSocial name :==> $name");
    printLog("loginWithSocial type :==> $type");
    printLog("loginWithSocial profileImg :==> ${profileImg?.path}");

    loading = true;
    loginSocialModel = await ApiService().loginWithSocial(
      email,
      name,
      type,
      deviceType,
      profileImg,
    );
    printLog("loginWithSocial status :==> ${loginSocialModel.status}");
    printLog("loginWithSocial message :==> ${loginSocialModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> loginWithOTP(mobile) async {
    printLog("getLoginOTP mobile :==> $mobile");

    loading = true;
    loginOTPModel = await ApiService().loginWithOTP(mobile);
    printLog("login status :==> ${loginOTPModel.status}");
    printLog("login message :==> ${loginOTPModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> loginWithEmailPassword(
    String email,
    String password,
    String? fullName,
    String? deviceType,
    String? deviceToken,
    bool isRegister,
  ) async {
    printLog("loginWithEmailPassword email :==> $email");

    loading = true;
    loginEmailModel = await ApiService().loginWithEmailPassword(
      email,
      password,
      fullName,
      deviceType,
      deviceToken,
      isRegister,
    );
    printLog("loginWithEmailPassword status :==> ${loginEmailModel.status}");
    printLog("loginWithEmailPassword message :==> ${loginEmailModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> forgotPassword(String email) async {
    printLog("forgotPassword email :==> $email");

    loading = true;
    forgotPasswordModel = await ApiService().forgotPassword(email);
    printLog("forgotPassword status :==> ${forgotPasswordModel.status}");
    printLog("forgotPassword message :==> ${forgotPasswordModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<SuccessModel> verifyResetCode(
    String email,
    String code,
    String newPassword,
    String confirmPassword,
  ) async {
    loading = true;
    SuccessModel result = await ApiService().verifyResetCode(
      email,
      code,
      newPassword,
      confirmPassword,
    );
    loading = false;
    notifyListeners();
    return result;
  }
}
