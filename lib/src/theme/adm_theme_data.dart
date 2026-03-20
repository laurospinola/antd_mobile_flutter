import 'package:flutter/material.dart';
import 'adm_tokens.dart';

/// Top-level theme config passed into [AdmTheme].
class AdmThemeData {
  final AdmTokens tokens;
  final Brightness brightness;

  const AdmThemeData({
    this.tokens = const AdmTokens(),
    this.brightness = Brightness.light,
  });

  const AdmThemeData.dark()
      : tokens = AdmTokens.dark,
        brightness = Brightness.dark;

  /// Build a Material [ThemeData] that keeps Material widgets consistent.
  ThemeData toMaterialTheme() {
    final t = tokens;
    return ThemeData(
      brightness: brightness,
      primaryColor: t.colorPrimary,
      scaffoldBackgroundColor: t.colorBackgroundBody,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: t.colorPrimary,
        onPrimary: t.colorTextWhite,
        secondary: t.colorPrimary,
        onSecondary: t.colorTextWhite,
        error: t.colorDanger,
        onError: t.colorTextWhite,
        surface: t.colorBackground,
        onSurface: t.colorTextBase,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          fontSize: t.fontSizeMd,
          color: t.colorTextBase,
          fontWeight: t.fontWeightNormal,
        ),
        bodyMedium: TextStyle(
          fontSize: t.fontSizeSm,
          color: t.colorTextSecondary,
          fontWeight: t.fontWeightNormal,
        ),
        titleMedium: TextStyle(
          fontSize: t.fontSizeLg,
          color: t.colorTextBase,
          fontWeight: t.fontWeightMedium,
        ),
      ),
      dividerColor: t.colorBorder,
      splashColor: t.colorPrimary.withOpacity(0.08),
      highlightColor: t.colorPrimary.withOpacity(0.04),
    );
  }
}
