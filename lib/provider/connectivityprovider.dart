import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:flutter/services.dart';

class ConnectivityProvider extends ChangeNotifier {
  // final flutterBGService = FlutterBackgroundService();
  List<ConnectivityResult> connectivityResult = [ConnectivityResult.none];
  bool isOnline = true, isBGSyncing = false;
  final Connectivity connectivity = Connectivity();

  Future<void> initConnectivity(BuildContext context) async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      printLog('Couldn\'t check connectivity status ======> $e');
      result = connectivityResult;
    }
    if (context.mounted) {
      checkStatus(result);
    }
    connectivity.onConnectivityChanged.listen(checkStatus);
  }

  Future<void> checkStatus(List<ConnectivityResult> result) async {
    connectivityResult = result;
    for (var i = 0; i < connectivityResult.length; i++) {
      printLog('connectivityResult =======> ${connectivityResult[i].name}');
      if (connectivityResult[i] == ConnectivityResult.mobile ||
          connectivityResult[i] == ConnectivityResult.wifi) {
        isOnline = true;
      } else {
        isOnline = false;
      }
    }
    printLog('checkStatus isOnline =========> $isOnline');

    notifyListeners();

    /* Backgruond Service */
    // if (!isOnline) {
    //   flutterBGService.invoke("stopService");
    // }
    /* Backgruond Service */
  }

  setBGSyncing({required bool isSyncing}) async {
    isBGSyncing = isSyncing;
    printLog("isBGSyncing =======> $isBGSyncing");
  }

  clearProvider() {
    isBGSyncing = false;
  }
}
