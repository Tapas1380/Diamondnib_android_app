import 'dart:io';

import 'package:diamondnib/utils/color.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyFileImage extends StatelessWidget {
  double? height;
  double? width;
  String? imagePath;
  Color? color;
  dynamic fit;
  bool? withShaderMask;

  MyFileImage({
    super.key,
    this.width,
    this.height,
    required this.imagePath,
    this.color,
    this.fit,
    this.withShaderMask,
  });

  @override
  Widget build(BuildContext context) {
    if (withShaderMask != null && withShaderMask == true) {
      return ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorPrimaryDark, yellow],
          ).createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          );
        },
        child: Image.file(
          File(imagePath ?? ""),
          height: height,
          color: color,
          width: width,
          fit: fit,
          errorBuilder: (context, url, error) {
            return Image.asset(
              "assets/images/no_image_port.png",
              width: width,
              height: height,
              fit: BoxFit.cover,
            );
          },
        ),
      );
    } else {
      printLog("Image Path is === $imagePath");
      return Image.file(
        File(imagePath ?? ""),
        height: height,
        color: color,
        width: width,
        fit: fit,
        errorBuilder: (context, url, error) {
          return Image.asset(
            "assets/images/no_image_port.png",
            width: width,
            height: height,
            fit: BoxFit.cover,
          );
        },
      );
    }
  }
}
