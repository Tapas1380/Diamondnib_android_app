import 'package:flutter/material.dart';

// Primary colors matching the Nib logo
const colorPrimary = Color(0xFF000000);        // Pure black for primary
const colorPrimaryDark = Color(0xFF000000);     // Pure black for dark variant
const colorAccent = Color(0xFF8B5CF6);          // Purple/violet from logo

// Background and supporting colors
const appbgcolor = Color(0xFF121212);           // Dark gray background
const transparentColor = Color(0x00000000);
const black = Color(0xff000000);
const gray = Color(0xffa9aaac);
const grayDark = Color(0xff454545);
const white = Color(0xffffffff);
const colorPrimaryLight = Color(0xFF2D2D2D);    // Light gray for contrast
const yellow = Color(0xffFFC805);

// Random Color //
const primaryLight = Color(0xffc8f85d);
const lanBgColor1 = Color(0xff872C9B);
const lanBgColor2 = Color(0xffE191F2);
const lightGreen = Color(0xff10b982);
const primaryTras75 = Color(0xBFbafa34);
const blue = Color(0xff00B0FC);
// Pop Up color
const red = Color(0xffFB2D2D);
const successBG = Color(0xff007c60);

Gradient lightOrange = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      red.withOpacity(1.0),
      yellow.withOpacity(1.0),
    ]);
