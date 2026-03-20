import 'package:flutter/material.dart';
import 'adm_tokens.dart';

/// Convenience class for building [TextStyle]s from [AdmTokens].
class AdmTypography {
  final AdmTokens tokens;
  const AdmTypography(this.tokens);

  TextStyle get xs => TextStyle(
        fontSize: tokens.fontSizeXs,
        color: tokens.colorTextBase,
        height: tokens.lineHeightBase,
      );

  TextStyle get small => TextStyle(
        fontSize: tokens.fontSizeSm,
        color: tokens.colorTextBase,
        height: tokens.lineHeightBase,
      );

  TextStyle get body => TextStyle(
        fontSize: tokens.fontSizeMd,
        color: tokens.colorTextBase,
        height: tokens.lineHeightBase,
      );

  TextStyle get bodySecondary => TextStyle(
        fontSize: tokens.fontSizeMd,
        color: tokens.colorTextSecondary,
        height: tokens.lineHeightBase,
      );

  TextStyle get large => TextStyle(
        fontSize: tokens.fontSizeLg,
        color: tokens.colorTextBase,
        fontWeight: tokens.fontWeightMedium,
        height: tokens.lineHeightBase,
      );

  TextStyle get title => TextStyle(
        fontSize: tokens.fontSizeXl,
        color: tokens.colorTextBase,
        fontWeight: tokens.fontWeightBold,
        height: tokens.lineHeightBase,
      );

  TextStyle get headline => TextStyle(
        fontSize: tokens.fontSizeXxl,
        color: tokens.colorTextBase,
        fontWeight: tokens.fontWeightBold,
        height: tokens.lineHeightBase,
      );

  TextStyle get navBarTitle => TextStyle(
        fontSize: tokens.navBarFontSize,
        color: tokens.navBarTextColor,
        fontWeight: tokens.navBarFontWeight,
      );
}
