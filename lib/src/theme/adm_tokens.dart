import 'package:flutter/material.dart';

/// [AdmTokens] mirrors the CSS variable design-token system from ant-design-mobile.
///
/// Each field here is the Flutter equivalent of an `--adm-*` CSS variable.
/// Override via [AdmThemeData] to create custom themes.
class AdmTokens {
  // ── Brand Colors ────────────────────────────────────────────────────────────
  final Color colorPrimary;
  final Color colorSuccess;
  final Color colorWarning;
  final Color colorDanger;

  // ── Text ────────────────────────────────────────────────────────────────────
  final Color colorTextBase;
  final Color colorTextSecondary;
  final Color colorTextTertiary;
  final Color colorTextPlaceholder;
  final Color colorTextDisabled;
  final Color colorTextWhite;
  final Color colorTextLink;

  // ── Fill / Surface ──────────────────────────────────────────────────────────
  final Color colorBackground;
  final Color colorBackgroundBody;
  final Color colorBorder;
  final Color colorBoxShadow;
  final Color colorFill;
  final Color colorFillSecondary;
  final Color colorFillTertiary;

  // ── Border Radius ───────────────────────────────────────────────────────────
  final double radiusXs;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;
  final double radiusPill;

  // ── Spacing ─────────────────────────────────────────────────────────────────
  final double spaceXs;
  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double spaceXl;
  final double spaceXxl;

  // ── Font ────────────────────────────────────────────────────────────────────
  final double fontSizeXs;
  final double fontSizeSm;
  final double fontSizeMd;
  final double fontSizeLg;
  final double fontSizeXl;
  final double fontSizeXxl;
  final double lineHeightBase;
  final FontWeight fontWeightNormal;
  final FontWeight fontWeightMedium;
  final FontWeight fontWeightBold;

  // ── Component-specific ──────────────────────────────────────────────────────
  final double buttonBorderRadius;
  final double buttonMiniHeight;
  final double buttonSmallHeight;
  final double buttonDefaultHeight;
  final double buttonLargeHeight;

  final double navBarHeight;
  final Color navBarBackground;
  final Color navBarTextColor;
  final double navBarFontSize;
  final FontWeight navBarFontWeight;

  final double tabBarHeight;
  final Color tabBarBackground;
  final Color tabBarActiveColor;
  final Color tabBarInactiveColor;
  final double tabBarFontSize;

  final double listItemPaddingVertical;
  final double listItemPaddingHorizontal;
  final double listItemMinHeight;
  final Color listBorderColor;

  final Duration animationDurationFast;
  final Duration animationDurationMid;
  final Duration animationDurationSlow;
  final Curve animationCurveDefault;

  const AdmTokens({
    // brand
    this.colorPrimary = const Color(0xFF1677FF),
    this.colorSuccess = const Color(0xFF00B578),
    this.colorWarning = const Color(0xFFFF8F1F),
    this.colorDanger = const Color(0xFFFF3141),
    // text
    this.colorTextBase = const Color(0xFF333333),
    this.colorTextSecondary = const Color(0xFF666666),
    this.colorTextTertiary = const Color(0xFF999999),
    this.colorTextPlaceholder = const Color(0xFFBBBBBB),
    this.colorTextDisabled = const Color(0xFFCCCCCC),
    this.colorTextWhite = const Color(0xFFFFFFFF),
    this.colorTextLink = const Color(0xFF1677FF),
    // fill
    this.colorBackground = const Color(0xFFFFFFFF),
    this.colorBackgroundBody = const Color(0xFFF5F5F5),
    this.colorBorder = const Color(0xFFEEEEEE),
    this.colorBoxShadow = const Color(0x1A000000),
    this.colorFill = const Color(0xFFF5F5F5),
    this.colorFillSecondary = const Color(0xFFFAFAFA),
    this.colorFillTertiary = const Color(0xFFFFFFFF),
    // radius
    this.radiusXs = 2.0,
    this.radiusSm = 4.0,
    this.radiusMd = 6.0,
    this.radiusLg = 8.0,
    this.radiusXl = 12.0,
    this.radiusPill = 999.0,
    // spacing
    this.spaceXs = 4.0,
    this.spaceSm = 8.0,
    this.spaceMd = 12.0,
    this.spaceLg = 16.0,
    this.spaceXl = 24.0,
    this.spaceXxl = 32.0,
    // font sizes
    this.fontSizeXs = 10.0,
    this.fontSizeSm = 12.0,
    this.fontSizeMd = 14.0,
    this.fontSizeLg = 16.0,
    this.fontSizeXl = 18.0,
    this.fontSizeXxl = 22.0,
    this.lineHeightBase = 1.5,
    this.fontWeightNormal = FontWeight.w400,
    this.fontWeightMedium = FontWeight.w500,
    this.fontWeightBold = FontWeight.w600,
    // button
    this.buttonBorderRadius = 4.0,
    this.buttonMiniHeight = 26.0,
    this.buttonSmallHeight = 32.0,
    this.buttonDefaultHeight = 44.0,
    this.buttonLargeHeight = 54.0,
    // navbar
    this.navBarHeight = 45.0,
    this.navBarBackground = const Color(0xFFFFFFFF),
    this.navBarTextColor = const Color(0xFF333333),
    this.navBarFontSize = 17.0,
    this.navBarFontWeight = FontWeight.w600,
    // tab bar
    this.tabBarHeight = 50.0,
    this.tabBarBackground = const Color(0xFFFFFFFF),
    this.tabBarActiveColor = const Color(0xFF1677FF),
    this.tabBarInactiveColor = const Color(0xFF999999),
    this.tabBarFontSize = 10.0,
    // list
    this.listItemPaddingVertical = 12.0,
    this.listItemPaddingHorizontal = 12.0,
    this.listItemMinHeight = 44.0,
    this.listBorderColor = const Color(0xFFEEEEEE),
    // animation
    this.animationDurationFast = const Duration(milliseconds: 100),
    this.animationDurationMid = const Duration(milliseconds: 200),
    this.animationDurationSlow = const Duration(milliseconds: 300),
    this.animationCurveDefault = Curves.easeInOut,
  });

  /// Dark theme token overrides.
  static const AdmTokens dark = AdmTokens(
    colorPrimary: Color(0xFF3D8AFF),
    colorSuccess: Color(0xFF34C759),
    colorWarning: Color(0xFFFF9F0A),
    colorDanger: Color(0xFFFF453A),
    colorTextBase: Color(0xFFFFFFFF),
    colorTextSecondary: Color(0xFFAAAAAA),
    colorTextTertiary: Color(0xFF666666),
    colorTextPlaceholder: Color(0xFF555555),
    colorTextDisabled: Color(0xFF444444),
    colorBackground: Color(0xFF1C1C1E),
    colorBackgroundBody: Color(0xFF000000),
    colorBorder: Color(0xFF2C2C2E),
    colorFill: Color(0xFF2C2C2E),
    colorFillSecondary: Color(0xFF1C1C1E),
    navBarBackground: Color(0xFF1C1C1E),
    navBarTextColor: Color(0xFFFFFFFF),
    tabBarBackground: Color(0xFF1C1C1E),
    tabBarActiveColor: Color(0xFF3D8AFF),
    tabBarInactiveColor: Color(0xFF666666),
  );

  AdmTokens copyWith({
    Color? colorPrimary,
    Color? colorSuccess,
    Color? colorWarning,
    Color? colorDanger,
    Color? colorTextBase,
    Color? colorTextSecondary,
    double? buttonBorderRadius,
    double? navBarHeight,
    // ... extend as needed
  }) {
    return AdmTokens(
      colorPrimary: colorPrimary ?? this.colorPrimary,
      colorSuccess: colorSuccess ?? this.colorSuccess,
      colorWarning: colorWarning ?? this.colorWarning,
      colorDanger: colorDanger ?? this.colorDanger,
      colorTextBase: colorTextBase ?? this.colorTextBase,
      colorTextSecondary: colorTextSecondary ?? this.colorTextSecondary,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      navBarHeight: navBarHeight ?? this.navBarHeight,
    );
  }
}
