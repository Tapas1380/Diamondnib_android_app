import 'package:diamondnib/pages/bottombar.dart';
import 'package:diamondnib/pages/intro.dart';
import 'package:diamondnib/pages/audiobookdetails.dart';
import 'package:diamondnib/provider/homeprovider.dart';
import 'package:diamondnib/tvpages/webhome.dart';
import 'package:diamondnib/utils/color.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/widget/myimage.dart';
import 'package:diamondnib/utils/sharedpre.dart';
import 'package:diamondnib/utils/deeplinkhandler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => SplashState();
}

class SplashState extends State<Splash> {
  String? seen;
  SharedPre sharedPre = SharedPre();

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2)).then((value) {
      if (!mounted) return;
      isFirstCheck();
    });
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        color: colorPrimary,
        child: MyImage(
          imagePath: (kIsWeb || Constant.isTV) ? "appicon.png" : "splash.png",
          fit: (kIsWeb || Constant.isTV) ? BoxFit.contain : BoxFit.cover,
        ),
      ),
    );
  }

  Future<void> isFirstCheck() async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    await homeProvider.setLoading(true);

    seen = await sharedPre.read('seen') ?? "0";
    Constant.userID = await sharedPre.read('userid');

    printLog('seen ==> $seen');
    printLog('Constant userID ==> ${Constant.userID}');
    
    if (!mounted) return;
    
    // ===== CHECK FOR DEEP LINK - GO DIRECTLY TO AUDIO =====
    if (Constant.shouldOpenAudioDetails && 
        Constant.deepLinkContentId != null) {
      
      printLog('Deep link detected in Splash: ${Constant.deepLinkContentId}');
      
      // First, navigate to home to establish base
      Widget homeScreen;
      if (kIsWeb || Constant.isTV) {
        homeScreen = const WebHome(pageName: "home");
      } else {
        homeScreen = seen == "1" ? const Bottombar() : const Intro();
      }
      
      // Replace Splash with Home (establishes the base for back navigation)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => homeScreen),
      );
      
      // Then immediately push audio on top
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AudioBookDetails(
                Constant.deepLinkContentId!,
                Constant.deepLinkContentType ?? 1,
              ),
            ),
          );
          Constant.shouldOpenAudioDetails = false;
        }
      });
      
      return;
    }
    
    // ===== NORMAL NAVIGATION (NO DEEP LINK) =====
    if (kIsWeb || Constant.isTV) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const WebHome(pageName: "home");
          },
        ),
      );
    } else {
      if (seen == "1") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const Bottombar();
            },
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const Intro();
            },
          ),
        );
      }
    }
  }
  
  void _navigateToHome() {
    // Check for pending deep links first
    if (Constant.shouldOpenAudioDetails && Constant.deepLinkContentId != null) {
      DeepLinkHandler.checkPendingDeepLink(context);
      return; // Don't navigate to home, deep link handler will navigate
    }
    
    // Normal navigation logic
    if (kIsWeb || Constant.isTV) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const WebHome(pageName: "home");
          },
        ),
      );
    } else {
      if (seen == "1") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const Bottombar();
            },
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const Intro();
            },
          ),
        );
      }
    }
  }
}
