import 'dart:io';
import 'package:diamondnib/provider/profileprovider.dart';
import 'package:diamondnib/routes/routes_constant.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/widget/mynetworkimg.dart';
import 'package:diamondnib/widget/mytextformfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:diamondnib/utils/color.dart';
import 'package:diamondnib/utils/sharedpre.dart';
import 'package:diamondnib/utils/strings.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/widget/mytext.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileEditWeb extends StatefulWidget {
  const ProfileEditWeb({super.key});

  @override
  State<ProfileEditWeb> createState() => _ProfileEditWebState();
}

class _ProfileEditWebState extends State<ProfileEditWeb> {
  SharedPre sharePref = SharedPre();
  final ImagePicker imagePicker = ImagePicker();
  File? pickedImageFile;
  String? userId, userName;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final bioController = TextEditingController();
  late ProfileProvider profileProvider;

  @override
  void initState() {
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    getUserData();
    super.initState();
  }

  void getUserData() async {
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.getProfile(context);
    profileData();
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  profileData() async {
    await profileProvider.getProfile(context);

    if (!profileProvider.loading) {
      if (profileProvider.profileModel.status == 200) {
        if (profileProvider.profileModel.result != null) {
          if (nameController.text.toString() == "") {
            if ((profileProvider.profileModel.result?[0].userName ?? "") !=
                "") {
              (profileProvider.profileModel.result?[0].fullName ?? "")
                          .isEmpty ||
                      (profileProvider.profileModel.result?[0].fullName ?? "")
                          .contains("null")
                  ? (profileProvider.profileModel.result?[0].userName ?? "")
                  : profileProvider.profileModel.result?[0].fullName ?? "";
              emailController.text =
                  profileProvider.profileModel.result?[0].email ?? "";
              passwordController.text =
                  profileProvider.profileModel.result?[0].mobile ?? "";
              bioController.text =
                  profileProvider.profileModel.result?[0].bio ?? "";
            }
          }
        }
      }
    }
    printLog("nameController.text == ${nameController.text.toString()}");
    // Future.delayed(Duration.zero).then((value) {
    //   if (!mounted) return;
    //   setState(() {});
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      constraints: const BoxConstraints(
        minWidth: 300,
        minHeight: 0,
        maxWidth: 350,
      ),
      child: SingleChildScrollView(
          child: Consumer<ProfileProvider>(builder: (context, value, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
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
                  alignment: Alignment.centerRight,
                  child: Utils().closeBtn(white, 18),
                ),
              ),
            ),

            /* Profile Image */
            Consumer<ProfileProvider>(
              builder: (context, value, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(45),
                  clipBehavior: Clip.antiAlias,
                  child: pickedImageFile != null
                      ? Image.network(
                          pickedImageFile?.path ?? "",
                          fit: BoxFit.cover,
                          height: 90,
                          width: 90,
                        )
                      : MyNetworkImage(
                          imageUrl: profileProvider.profileModel.status == 200
                              ? profileProvider.profileModel.result != null
                                  ? (profileProvider
                                          .profileModel.result?[0].image ??
                                      "")
                                  : ""
                              : "",
                          fit: BoxFit.fill,
                          imgHeight: 90,
                          imgWidth: 90,
                        ),
                );
              },
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                if (Constant.userID == null) {
                  Utils.buildWebAlertDialog(context, "login", "");
                } else {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => const MyProfile(
                  //               type: 'myProfile',
                  //             )));
                  context.pushNamed(
                    RoutesConstant.myProfilePage,
                    extra: {'type': "myProfile"},
                  );
                }
              },
              child: Container(
                  height: 35,
                  decoration: BoxDecoration(
                      color: colorAccent,
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  margin: const EdgeInsets.all(5),
                  alignment: Alignment.center,
                  child: MyText(
                    color: white,
                    text: 'Profile Page',
                    fontweight: FontWeight.w600,
                    fontsizeWeb: 14,
                  )),
            ),
            /* Change Button */
            // Container(
            //   height: 35,
            //   padding: const EdgeInsets.only(left: 10, right: 10),
            //   alignment: Alignment.center,
            //   child: InkWell(
            //     borderRadius: BorderRadius.circular(5),
            //     onTap: () {
            //       getFromGallery();
            //     },
            //     focusColor: white.withOpacity(0.5),
            //     child: Container(
            //       constraints: const BoxConstraints(
            //         minHeight: 35,
            //         maxWidth: 100,
            //       ),
            //       alignment: Alignment.center,
            //       child: MyText(
            //         text: "chnage",
            //         fontsizeNormal: 16,
            //         fontsizeWeb: 16,
            //         multilanguage: true,
            //         maxline: 1,
            //         overflow: TextOverflow.ellipsis,
            //         fontweight: FontWeight.w500,
            //         fontstyle: FontStyle.normal,
            //         textalign: TextAlign.center,
            //         color: gray,
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 18),

            /* Name */
            Container(
              height: 35,
              color: colorPrimary,
              padding: const EdgeInsets.only(left: 10, right: 10),
              alignment: Alignment.center,
              child: MyTextFormField(
                mHint: nameController.text,
                mController: nameController,
                mObscureText: false,
                mMaxLine: 1,
                mHintTextColor: white,
                mTextColor: white,
                mkeyboardType: TextInputType.name,
                mTextInputAction: TextInputAction.next,
                mInputBorder: InputBorder.none,
                mTextAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            /* Email */
            Container(
              height: 35,
              color: colorPrimary,
              padding: const EdgeInsets.only(left: 10, right: 10),
              alignment: Alignment.center,
              child: MyTextFormField(
                mHint: emailController.text,
                mController: emailController,
                mObscureText: false,
                mMaxLine: 1,
                mHintTextColor: white,
                mTextColor: white,
                mkeyboardType: TextInputType.name,
                mTextInputAction: TextInputAction.next,
                mInputBorder: InputBorder.none,
                mTextAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            /* Mobile */
            Container(
              height: 35,
              color: colorPrimary,
              padding: const EdgeInsets.only(left: 10, right: 10),
              alignment: Alignment.center,
              child: MyTextFormField(
                mHint: passwordController.text.toString(),
                mController: passwordController,
                mObscureText: false,
                mMaxLine: 1,
                mHintTextColor: white,
                mTextColor: white,
                mkeyboardType: TextInputType.name,
                mTextInputAction: TextInputAction.next,
                mInputBorder: InputBorder.none,
                mTextAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            /* Bio */
            Container(
              height: 35,
              color: colorPrimary,
              padding: const EdgeInsets.only(left: 10, right: 10),
              alignment: Alignment.center,
              child: MyTextFormField(
                mHint: bioController.text,
                mController: bioController,
                mObscureText: false,
                mMaxLine: 1,
                mHintTextColor: white,
                mTextColor: white,
                mkeyboardType: TextInputType.name,
                mTextInputAction: TextInputAction.next,
                mInputBorder: InputBorder.none,
                mTextAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),

            /* Save */
            Container(
              alignment: Alignment.center,
              constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              child: InkWell(
                borderRadius: BorderRadius.circular(5),
                focusColor: white.withOpacity(0.5),
                onTap: () async {
                  printLog(
                      "nameController Name ==> ${nameController.text.toString()}");
                  printLog(
                      "pickedImageFile ==> ${pickedImageFile?.path ?? "not picked"}");
                  if (nameController.text.toString().isEmpty) {
                    return Utils.showSnackbar(
                        context, "info", enterName, false);
                  }
                  await sharePref.save(
                      "username", nameController.text.toString());
                  if (pickedImageFile != null) {
                    await profileProvider.getImageUpload(pickedImageFile);
                  }
                  await profileProvider.getUpdateProfile(
                      nameController.text.toString(),
                      emailController.text.toString(),
                      emailController.text.toString(),
                      bioController.text.toString(),
                      pickedImageFile);
                  if (!context.mounted) return;
                  await profileProvider.getProfile(context);
                  Utils.saveUserCreds(
                    userID:
                        profileProvider.profileModel.result?[0].id.toString(),
                    userName: profileProvider.profileModel.result?[0].fullName
                        .toString(),
                    userEmail: profileProvider.profileModel.result?[0].email
                        .toString(),
                    userMobile: profileProvider.profileModel.result?[0].mobile
                        .toString(),
                    userImage: profileProvider.profileModel.result?[0].image
                        .toString(),
                    userPremium: profileProvider.profileModel.result?[0].isBuy
                        .toString(),
                    userType:
                        profileProvider.profileModel.result?[0].type.toString(),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    height: 35,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    decoration: BoxDecoration(
                      color: colorAccent,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: MyText(
                      color: white,
                      text: "save",
                      multilanguage: true,
                      textalign: TextAlign.center,
                      fontsizeNormal: 15,
                      fontsizeWeb: 15,
                      fontweight: FontWeight.w600,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      })),
    );
  }

  /// Get from gallery
  void getFromGallery() async {
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 100,
    );
    if (pickedFile != null) {
      setState(() {
        pickedImageFile = File(pickedFile.path);
        printLog("Gallery pickedImageFile ==> ${pickedImageFile?.path}");
      });
    }
  }
}
