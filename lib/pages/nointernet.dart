import 'package:diamondnib/pages/bottombar.dart';
import 'package:diamondnib/pages/mydownloads.dart';
import 'package:diamondnib/provider/connectivityprovider.dart';
import 'package:diamondnib/utils/color.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/widget/myimage.dart';
import 'package:diamondnib/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoInternet extends StatefulWidget {
  const NoInternet({super.key});

  @override
  State<NoInternet> createState() => NoInternetState();
}

class NoInternetState extends State<NoInternet> {
  late ConnectivityProvider connectivityProvider;

  @override
  void initState() {
    connectivityProvider =
        Provider.of<ConnectivityProvider>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              yellow.withOpacity(0.3),
              yellow.withOpacity(0.2),
              yellow.withOpacity(0.1),
              colorPrimary.withOpacity(0.1),
              colorPrimary,
            ],
          ),
          borderRadius: BorderRadius.circular(0),
          shape: BoxShape.rectangle,
        ),
        child: SafeArea(
          child: _buildPage(),
        ),
      ),
    );
  }

  Widget _buildPage() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: MyImage(
                height: 200,
                fit: BoxFit.contain,
                imagePath: "ic_no_internet.png",
              ),
            ),
            const SizedBox(height: 25),
            MyText(
              color: white,
              text: "no_internet",
              fontsizeNormal: 20,
              fontsizeWeb: 22,
              maxline: 5,
              multilanguage: true,
              overflow: TextOverflow.ellipsis,
              fontweight: FontWeight.w600,
              textalign: TextAlign.center,
              fontstyle: FontStyle.normal,
            ),
            const SizedBox(height: 5),
            MyText(
              color: gray,
              text: "no_internet_desc",
              fontsizeNormal: 13,
              fontsizeWeb: 15,
              maxline: 5,
              multilanguage: true,
              overflow: TextOverflow.ellipsis,
              fontweight: FontWeight.w400,
              textalign: TextAlign.center,
              fontstyle: FontStyle.normal,
            ),
            /* Login Button */
            const SizedBox(height: 40),
            _buildRetryBtn(),
            const SizedBox(height: 20),
            _buildDownloadBtn(),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryBtn() {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        if (connectivityProvider.isOnline) {
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const Bottombar()),
            (Route<dynamic> route) => route.isFirst,
          );
        }
      },
      child: Container(
        height: 45,
        constraints:
            BoxConstraints(minWidth: MediaQuery.of(context).size.width * 0.5),
        alignment: Alignment.center,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        decoration: Utils.setGradientBGWithCenter(
            yellow, yellow.withOpacity(0.6), yellow.withOpacity(0.4), 8),
        child: MyText(
          color: white,
          text: "retry",
          fontsizeNormal: 15,
          fontsizeWeb: 17,
          maxline: 5,
          multilanguage: true,
          overflow: TextOverflow.ellipsis,
          fontweight: FontWeight.w600,
          textalign: TextAlign.center,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }

  Widget _buildDownloadBtn() {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const MyDownloads();
            },
          ),
        );
      },
      child: FittedBox(
        child: Container(
          height: 45,
          constraints:
              BoxConstraints(minWidth: MediaQuery.of(context).size.width * 0.5),
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: MyText(
            color: white,
            text: "open_download",
            fontsizeNormal: 15,
            fontsizeWeb: 17,
            maxline: 5,
            multilanguage: true,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w600,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
        ),
      ),
    );
  }
}
