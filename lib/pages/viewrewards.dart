import 'package:diamondnib/provider/rewardprovider.dart';
import 'package:diamondnib/shimmer/shimmerwidget.dart';
import 'package:diamondnib/utils/adhelper.dart';
import 'package:diamondnib/utils/color.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/utils/dimens.dart';
import 'package:diamondnib/utils/sharedpre.dart';
import 'package:diamondnib/utils/strings.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/widget/myimage.dart';
import 'package:diamondnib/widget/mytext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class ViewRewards extends StatefulWidget {
  const ViewRewards({super.key});

  @override
  State<ViewRewards> createState() => _ViewRewardsState();
}

class _ViewRewardsState extends State<ViewRewards> {
  late RewardProvider rewardProvider;
  late ScrollController _scrollController;
  late ProgressDialog prDialog;
  dynamic progress;
  SharedPre sharedPre = SharedPre();
  int? daysSinceLastClaim;
  String userId = Constant.userID.toString();

  int watchedAdsCount = 0;
int maxAdsPerDay = 10;
String? lastWatchDate;
int checkInStreak = 0;


  @override
  void initState() {
    prDialog = ProgressDialog(context);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    rewardProvider = Provider.of<RewardProvider>(context, listen: false);
    rewardProvider.setLoading(true);
    _getData();
    super.initState();
  }

  _scrollListener() async {
    printLog("scroll controll ");
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (rewardProvider.currentPage ?? 0) < (rewardProvider.totalPage ?? 0)) {
      printLog("load more====>");
      rewardProvider.setLoadMore(true);
      await _fetchData((rewardProvider.currentPage ?? 0));
    }
  }

  /* Section Data Api */
  Future<void> _fetchData(int? nextPage) async {
    await rewardProvider.getEarnTransactionsList((nextPage ?? 0) + 1);
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  Future<void> _getData() async {
 String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
String userId = Constant.userID.toString();

// ✅ Use user-specific keys
lastWatchDate = await sharedPre.read('${userId}_lastWatchDate');
String? count = await sharedPre.read('${userId}_watchedAdsCount');

// ✅ Reset daily if new date
if (lastWatchDate != today) {
  watchedAdsCount = 0;
  await sharedPre.save('${userId}_watchedAdsCount', '0');
  await sharedPre.save('${userId}_lastWatchDate', today);
} else {
  watchedAdsCount = int.tryParse(count ?? '0') ?? 0;
}

 //  String userId = Constant.userID.toString();

// ✅ Load user-specific data
String streakVal = await sharedPre.read('${userId}_checkInStreak') ?? "0";
checkInStreak = int.tryParse(streakVal) ?? 0;

String? progressVal = await sharedPre.read('${userId}_progress');
progress = progressVal ?? 0.0;

printLog("User $userId progress == $progress");
await rewardProvider.getEarnCoins();


    await _fetchData(0);
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    rewardProvider.cleaProvider();
    super.dispose();
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd-MMM-yyyy').format(dateTime);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: AppBar(
        leading: InkWell(
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
            padding: const EdgeInsets.all(18.0),
            child: Utils().backBtn(18, 18, 12),
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: colorPrimary,
        centerTitle: false,
        elevation: 0,
        title: MyText(
          multilanguage: true,
          color: white,
          text: "my_rewards",
          fontsizeNormal: 16,
          fontsizeWeb: 15,
          fontweight: FontWeight.w500,
        ),
      ),
      body: bonusdata(),
    );
  }

  Widget bonusdata() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(children: [
            MyImage(
              imagePath: "bonus_bg.png",
              height: Dimens.bonusBgImgheight,
              // width: Dimens.bonusBgImgwidth,
              fit: BoxFit.cover,
              width: kIsWeb
                  ? MediaQuery.of(context).size.width * 0.65
                  : Dimens.bonusBgImgwidth,
            ),
          ]),
          Container(
            transform: Matrix4.translationValues(0, -105, 0),
            child: Column(
              children: [
                SizedBox(
                    width: kIsWeb
                        ? MediaQuery.of(context).size.width * 0.5
                        : Dimens.bonusBgImgwidth,
                    child: dayReward()),
                    watchAdSection(),
                rewardProvider.isLoading
                    ? kIsWeb
                        ? webRewardListShimmer()
                        : rewardListShimmer()
                    : kIsWeb
                        ? webRewardsList()
                        : rewardsList()
              ],
            ),
          )
        ],
      ),
    );
  }
Widget watchAdSection() {
  bool canWatchAd = watchedAdsCount < maxAdsPerDay;
  bool adsAvailable = AdHelper.isRewardedAdAvailable();

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
    child: InkWell(
      onTap: canWatchAd && adsAvailable
          ? () async {
              if (Constant.userID != null) {
                final earntransaction =
                    Provider.of<RewardProvider>(context, listen: false);

                // ✅ identical to check-in flow
                AdHelper.rewardedAd(context, () async {
                  Utils.showProgress(context, prDialog);

                  await earntransaction.getEarnTransactions(
                    rewardProvider.earncoinsModel.dailyLogin?[0].value,
                    2,
                  );

                  if (rewardProvider.earntransactionmodel.status == 200) {
                    if (!context.mounted) return;
                    Utils().hideProgress(context);
                    Utils.showToast(rewardgetsuccessfully);

                    // ✅ increment ad count and save
                   String userId = Constant.userID.toString();

watchedAdsCount++;
await sharedPre.save('${userId}_watchedAdsCount', watchedAdsCount.toString());
await sharedPre.save('${userId}_lastWatchDate',
    DateFormat('yyyy-MM-dd').format(DateTime.now()));
// store current date

                    setState(() {});
                  } else {
                    if (!context.mounted) return;
                    Utils().hideProgress(context);
                    Utils.showToast(somethingwentwrong);
                  }
                });
              } else {
                Utils.openLogin(
                    context: context, isHome: false, isReplace: false);
              }
            }
          : canWatchAd
              ? () {
                  Utils.showToast("Ad is not available right now");
                }
              : null, // disabled after limit
      child: Opacity(
        opacity: canWatchAd ? 1.0 : 0.5,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF007A), Color(0xFFFF7A00)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "AD",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                canWatchAd
                    ? (adsAvailable
                        ? "Watch Ad to earn coins (${watchedAdsCount}/$maxAdsPerDay)"
                        : "Ad is not available right now")
                    : "Limit reached (${watchedAdsCount}/$maxAdsPerDay)",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget dayReward() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
            side: BorderSide(color: gray.withOpacity(0.5), width: 0.2)),
        shadowColor: gray,
        elevation: 3,
        child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(10),
            height: Dimens.dailyrewardHeight,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13), color: colorPrimary),
            child: Consumer<RewardProvider>(
              builder: (context, rewardProvider, child) {
                if (rewardProvider.isLoading) {
                  return coinsShimmer();
                } else {
                  if (rewardProvider.earncoinsModel.status == 200 &&
                      (rewardProvider.earncoinsModel.dailyLogin?.length ?? 0) >
                          0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      MyText(
  fontsizeWeb: 15,
  multilanguage: false,
  color: yellow,
  text: "Check-in Streak: $checkInStreak Day${checkInStreak == 1 ? '' : 's'}",
  fontsizeNormal: 16,
  fontweight: FontWeight.w500,
),
                        const SizedBox(
                          height: 20,
                        ),
                        Stack(children: [
                          SizedBox(
                            height: 130,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: rewardProvider
                                      .earncoinsModel.dailyLogin?.length ??
                                  0,
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              separatorBuilder: (context, index) {
                                return const SizedBox(
                                  width: 12,
                                );
                              },
                             itemBuilder: (BuildContext context, int index) {
  bool isCompleted = index < checkInStreak; // ✅ days already checked in
  return Column(
    children: [
      Stack(
        alignment: Alignment.center,
        children: [
          MyImage(
            imagePath: "rewardCoin.png",
            height: Dimens.coinImgHeight,
            width: Dimens.coinImgWidth,
            color: isCompleted ? Colors.grey.withOpacity(0.3) : null,
          ),
          if (isCompleted)
            const Icon(Icons.check_circle, color: Colors.greenAccent, size: 24),
        ],
      ),
      const SizedBox(height: 10),
      MyText(
        fontsizeWeb: 14,
        multilanguage: false,
        color: isCompleted ? Colors.greenAccent : white,
        text:
            "${rewardProvider.earncoinsModel.dailyLogin?[index].value.toString() ?? ""} coins",
        fontsizeNormal: 12,
        fontweight: FontWeight.w500,
      ),
      const SizedBox(height: 50),
      MyText(
        fontsizeWeb: 12,
        multilanguage: false,
        color: gray,
        text: rewardProvider.earncoinsModel.dailyLogin?[index].key.toString() ?? "",
        fontsizeNormal: 10,
        fontweight: FontWeight.w500,
      ),
    ],
  );
},

                            ),
                          ),
                        ]),
                        Center(
                          child: InkWell(
                            onTap: () async {
                              if (Constant.userID != null) {
                                final earntransaction =
                                    Provider.of<RewardProvider>(context,
                                        listen: false);
String userId = Constant.userID.toString();

int lastClaimedTimestamp =
    int.tryParse(await sharedPre.read('${userId}_lastClaimedTimestamp') ?? '0') ?? 0;
int lastClaimedDay =
    int.tryParse(await sharedPre.read('${userId}_lastClaimedDay') ?? '0') ?? 0;
int lastIndex =
    int.tryParse(await sharedPre.read('${userId}_lastIndex') ?? '0') ?? 0;

                                int currentTimestamp =
                                    DateTime.now().millisecondsSinceEpoch;

                                int hoursDifference =
                                    (currentTimestamp - lastClaimedTimestamp) ~/
                                        (1000 * 60 * 60);

                                int newDay = lastClaimedDay;
                                int newIndex = lastIndex;

                                if (hoursDifference >= 24) {
                                  // ✅ Check if ads are available
                                  if (!AdHelper.isRewardedAdAvailable()) {
                                    Utils.showToast("Ad is not available right now");
                                    return;
                                  }
                                  
                                  newDay = (lastClaimedDay % 7) + 1;
                                  newIndex = (lastIndex % 7) + 1;
                                  if (!context.mounted) return;
                                  AdHelper.rewardedAd(context, () async {
                                    Utils.showProgress(context, prDialog);
                                    await earntransaction.getEarnTransactions(
                                        rewardProvider.earncoinsModel
                                            .dailyLogin?[newIndex - 1].value,
                                        2);
                                 if (rewardProvider.earntransactionmodel.status == 200) {
  if (!context.mounted) return;
  Utils().hideProgress(context);
  Utils.showToast(rewardgetsuccessfully);

  // ✅ Make sure we have the correct userId
  String userId = Constant.userID.toString();

  // ✅ Save user-specific values
  await sharedPre.save('${userId}_lastClaimedTimestamp', currentTimestamp.toString());
  await sharedPre.save('${userId}_lastClaimedDay', newDay.toString());
  await sharedPre.save('${userId}_lastIndex', newIndex.toString());

  progress = 14.2857142857 * newIndex;
  await sharedPre.save('${userId}_progress', progress.toString());

  // ✅ Update streak per user
  checkInStreak = newDay;
  await sharedPre.save('${userId}_checkInStreak', checkInStreak.toString());

  setState(() {});
}
 else {
                                      if (!context.mounted) return;
                                      Utils().hideProgress(context);
                                      Utils.showToast(somethingwentwrong);
                                    }
                                  });
                                  // API Calling
                                } else {
                                  int remainingHours = 24 - hoursDifference;
                                  Utils.showToast(
                                      "You can claim your reward after $remainingHours hours");
                                }
                              } else {
                                Utils.openLogin(
                                    context: context,
                                    isHome: false,
                                    isReplace: false);
                              }
                            },
                            child: Container(
                              constraints: const BoxConstraints(
                                minHeight: 0,
                                maxHeight: 45,
                                minWidth: 0,
                                maxWidth: 150,
                              ),
                              padding: const EdgeInsets.all(10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient:
                                    LinearGradient(colors: lightOrange.colors),
                                borderRadius: BorderRadius.circular(44),
                                shape: BoxShape.rectangle,
                              ),
                              child: MyText(
                                color: white,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                multilanguage: true,
                                text: "checkin",
                                textalign: TextAlign.center,
                                fontsizeNormal: 14,
                                fontsizeWeb: 16,
                                fontweight: FontWeight.w500,
                                fontstyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }
              },
            )),
      ),
    );
  }

  Widget coinsShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerWidget.roundcorner(
          height: 20,
          width: 120,
          shimmerBgColor: grayDark,
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            separatorBuilder: (context, index) {
              return const SizedBox(
                width: 12,
              );
            },
            itemBuilder: (BuildContext context, int index) {
              return Stack(children: [
                Column(
                  children: [
                    ShimmerWidget.circular(
                      height: Dimens.coinImgHeight,
                      width: Dimens.coinImgWidth,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const ShimmerWidget.roundcorner(
                      height: 15,
                      width: 40,
                      shimmerBgColor: grayDark,
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    const ShimmerWidget.roundcorner(
                      height: 12,
                      width: 40,
                      shimmerBgColor: grayDark,
                    ),
                  ],
                ),
                Positioned(
                    top: 60,
                    child: Container(
                      color: colorPrimaryDark,
                      height: 20,
                      width: MediaQuery.of(context).size.width,
                    ))
              ]);
            },
          ),
        ),
        const Center(
          child: ShimmerWidget.roundcorner(
            height: 45,
            width: 150,
          ),
        ),
      ],
    );
  }

  Widget rewardsList() {
    return Consumer<RewardProvider>(
      builder: (context, rewardProvider, child) {
        if (rewardProvider.earntransactionlistmodel.status == 200 &&
            (rewardProvider.transactionlist?.length ?? 0) > 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: MyText(
                  fontsizeWeb: 15,
                  multilanguage: true,
                  color: yellow,
                  text: "rewards_list",
                  fontsizeNormal: 15,
                  fontweight: FontWeight.w600,
                ),
              ),
              ListView.separated(
                padding: const EdgeInsets.all(15),
                itemCount: rewardProvider.transactionlist?.length ?? 0,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    height: 10,
                  );
                },
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.center,
                    height: Dimens.coinPacksContHeight,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: appbgcolor,
                        border: Border.all(
                          width: 0.2,
                          color: white,
                        ),
                        borderRadius: BorderRadius.circular(5)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  MyImage(
                                    imagePath: "coin.png",
                                    height: Dimens.coinImgHeight,
                                    width: Dimens.coinImgWidth,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  MyText(
                                    fontsizeWeb: 15,
                                    color: white,
                                    multilanguage: false,
                                    text:
                                        "${rewardProvider.transactionlist?[index].coin.toString() ?? ""} Coins",
                                    fontsizeNormal: 14,
                                    fontweight: FontWeight.w600,
                                  ),
                                ],
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                height: 22,
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                child: MyText(
                                  color: gray,
                                  text: formatDate(rewardProvider
                                          .transactionlist?[index].createdAt
                                          .toString() ??
                                      ""),
                                  fontsizeNormal: 10,
                                  fontsizeWeb: 12,
                                  fontweight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          alignment: Alignment.center,
                          height: Dimens.coinPriceContHeight,
                          // width: Dimens.coinPriceContWidth,
                          decoration: BoxDecoration(
                            color: colorPrimaryDark,
                            borderRadius: BorderRadius.circular(38),
                          ),
                          child: MyText(
                            color: white,
                            multilanguage: false,
                            fontsizeWeb: 15,
                            text:
                                "${rewardProvider.transactionlist?[index].coin.toString() ?? ""} Coins",
                            fontsizeNormal: 14,
                            fontweight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
              Consumer<RewardProvider>(
                builder: (context, rewardProvider, child) {
                  if (rewardProvider.loadmore) {
                    return Container(
                      height: 50,
                      margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                      child: Utils.pageLoader(),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget webRewardsList() {
    return Consumer<RewardProvider>(
      builder: (context, rewardProvider, child) {
        if (rewardProvider.earntransactionlistmodel.status == 200 &&
            (rewardProvider.transactionlist?.length ?? 0) > 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: MyText(
                  fontsizeWeb: 15,
                  multilanguage: true,
                  color: yellow,
                  text: "rewards_list",
                  fontsizeNormal: 15,
                  fontweight: FontWeight.w600,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ResponsiveGridList(
                  minItemWidth: 500,
                  minItemsPerRow: 1,
                  maxItemsPerRow: 2,
                  horizontalGridSpacing: 10,
                  verticalGridSpacing: 10,
                  listViewBuilderOptions: ListViewBuilderOptions(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                  children: List.generate(
                    rewardProvider.transactionlist?.length ?? 0,
                    (index) {
                      return Container(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        alignment: Alignment.center,
                        height: Dimens.coinPacksContHeight,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: appbgcolor,
                            border: Border.all(
                              width: 0.2,
                              color: white,
                            ),
                            borderRadius: BorderRadius.circular(5)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      MyImage(
                                        imagePath: "coin.png",
                                        height: Dimens.coinImgHeight,
                                        width: Dimens.coinImgWidth,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      MyText(
                                        fontsizeWeb: 15,
                                        color: white,
                                        multilanguage: false,
                                        text:
                                            "${rewardProvider.transactionlist?[index].coin.toString() ?? ""} Coins",
                                        fontsizeNormal: 14,
                                        fontweight: FontWeight.w600,
                                      ),
                                    ],
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    height: 22,
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                    child: MyText(
                                      color: gray,
                                      text: formatDate(rewardProvider
                                              .transactionlist?[index].createdAt
                                              .toString() ??
                                          ""),
                                      fontsizeNormal: 10,
                                      fontsizeWeb: 12,
                                      fontweight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              alignment: Alignment.center,
                              height: Dimens.coinPriceContHeight,
                              // width: Dimens.coinPriceContWidth,
                              decoration: BoxDecoration(
                                color: colorPrimaryDark,
                                borderRadius: BorderRadius.circular(38),
                              ),
                              child: MyText(
                                color: white,
                                multilanguage: false,
                                fontsizeWeb: 15,
                                text:
                                    "${rewardProvider.transactionlist?[index].coin.toString() ?? ""} Coins",
                                fontsizeNormal: 14,
                                fontweight: FontWeight.w600,
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Consumer<RewardProvider>(
                builder: (context, rewardProvider, child) {
                  if (rewardProvider.loadmore) {
                    return Container(
                      height: 50,
                      margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                      child: Utils.pageLoader(),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget rewardListShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(15.0),
          child: ShimmerWidget.roundcorner(
            height: 20,
            width: 120,
          ),
        ),
        ListView.separated(
          padding: const EdgeInsets.all(15),
          itemCount: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(
              height: 10,
            );
          },
          itemBuilder: (BuildContext context, int index) {
            return Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              alignment: Alignment.center,
              height: Dimens.coinPacksContHeight,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: appbgcolor,
                  border: Border.all(
                    width: 0.2,
                    color: white,
                  ),
                  borderRadius: BorderRadius.circular(5)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ShimmerWidget.circular(
                              height: Dimens.coinImgHeight,
                              width: Dimens.coinImgWidth,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const ShimmerWidget.roundcorner(
                              height: 20,
                              width: 80,
                            ),
                          ],
                        ),
                        Container(
                            alignment: Alignment.centerLeft,
                            height: 22,
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: const ShimmerWidget.roundcorner(
                              height: 12,
                              width: 80,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.center,
                    height: Dimens.coinPriceContHeight,
                    // width: Dimens.coinPriceContWidth,
                    decoration: BoxDecoration(
                      color: colorPrimaryDark,
                      borderRadius: BorderRadius.circular(38),
                    ),
                    child: const ShimmerWidget.roundcorner(
                      height: 15,
                      width: 30,
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget webRewardListShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(15.0),
          child: ShimmerWidget.roundcorner(
            height: 20,
            width: 120,
          ),
        ),
        ResponsiveGridList(
          minItemWidth: 500,
          minItemsPerRow: 1,
          maxItemsPerRow: 2,
          horizontalGridSpacing: 10,
          verticalGridSpacing: 10,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(
            5,
            (index) {
              return Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                alignment: Alignment.center,
                height: Dimens.coinPacksContHeight,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: appbgcolor,
                    border: Border.all(
                      width: 0.2,
                      color: white,
                    ),
                    borderRadius: BorderRadius.circular(5)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ShimmerWidget.circular(
                                height: Dimens.coinImgHeight,
                                width: Dimens.coinImgWidth,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const ShimmerWidget.roundcorner(
                                height: 20,
                                width: 80,
                              ),
                            ],
                          ),
                          Container(
                              alignment: Alignment.centerLeft,
                              height: 22,
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                              child: const ShimmerWidget.roundcorner(
                                height: 12,
                                width: 80,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      alignment: Alignment.center,
                      height: Dimens.coinPriceContHeight,
                      // width: Dimens.coinPriceContWidth,
                      decoration: BoxDecoration(
                        color: colorPrimaryDark,
                        borderRadius: BorderRadius.circular(38),
                      ),
                      child: const ShimmerWidget.roundcorner(
                        height: 15,
                        width: 30,
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
