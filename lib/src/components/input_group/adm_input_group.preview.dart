// Widget previews for [AdmInputGroup]. Run with `flutter widget-preview start`
// at the package root. This file is preview-only and is not exported from the
// public barrel.
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../theme/adm_icons.dart';
import '../../theme/adm_theme.dart';
import '../../theme/adm_theme_data.dart';
import 'adm_input_group.dart';

Widget _stage(Widget child, {bool dark = false}) {
  return AdmApp(
    themeData: dark ? const AdmThemeData.dark() : const AdmThemeData(),
    home: Builder(
      builder: (context) {
        final tokens = AdmTheme.tokensOf(context);
        return Scaffold(
          backgroundColor: tokens.colorBackgroundBody,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        );
      },
    ),
  );
}

Widget _searchGroup() => AdmInputGroup(
      borderRadius: 16,
      children: [
        const Expanded(
          child: AdmInputGroupInput(placeholder: 'Enter search query'),
        ),
        AdmInputGroupAddon(
          align: AdmAddonAlign.inlineEnd,
          child: AdmInputGroupButton(
            'Search In...',
            icon: AdmIcons.chevron_down,
            onPressed: () {},
          ),
        ),
      ],
    );

Widget _urlGroup() => AdmInputGroup(
      children: [
        const AdmInputGroupAddon(child: Text('https://')),
        const Expanded(
          child: AdmInputGroupInput(placeholder: 'example.com'),
        ),
        AdmInputGroupAddon(
          align: AdmAddonAlign.inlineEnd,
          child: AdmInputGroupButton('Send', filled: true, onPressed: () {}),
        ),
      ],
    );

@Preview(name: 'InputGroup — Search (light)')
Widget inputGroupSearchLight() => _stage(_searchGroup());

@Preview(name: 'InputGroup — Search (dark)')
Widget inputGroupSearchDark() => _stage(_searchGroup(), dark: true);

@Preview(name: 'InputGroup — URL + Send (light)')
Widget inputGroupUrlLight() => _stage(_urlGroup());

@Preview(name: 'InputGroup — URL + Send (dark)')
Widget inputGroupUrlDark() => _stage(_urlGroup(), dark: true);
