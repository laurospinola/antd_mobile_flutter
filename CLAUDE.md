# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`antd_mobile_flutter` is an internal Flutter UI component library that ports [ant-design-mobile](https://ant-design-mobile.antgroup.com/) to Flutter. It is consumed as a path or Git dependency, never published. SDK constraints: Dart `>=3.0.0 <4.0.0`, Flutter `>=3.10.0`. Runtime deps are intentionally minimal: only `flutter_svg` and `qr_flutter`.

## Common commands

```bash
flutter pub get                 # fetch deps at repo root
flutter analyze                 # lint (rules in analysis_options.yaml)
flutter test                    # run unit/widget tests (test/ is currently empty)
flutter test test/foo_test.dart # run a single test file
flutter test --name "pattern"   # run tests matching name

# Showcase app (depends on the library via path)
cd example && flutter pub get && flutter run

# Regenerate icon doc previews after editing lib/src/theme/adm_icons.dart
dart tool/update_icon_docs.dart
```

The `example/` directory is a standalone Flutter app used as a manual showcase / smoke test for components. There is no automated visual-regression suite, so when changing a component, run the example app and exercise the relevant page.

## Architecture

### Token-driven theming is the spine

Everything visual flows from `AdmTokens` (`lib/src/theme/adm_tokens.dart`) — a single immutable value class that mirrors ant-design-mobile's `--adm-*` CSS variables (colors, spacing, radii, font sizes, animation durations, plus per-component tokens like `buttonDefaultHeight`, `navBarHeight`, `listItemPaddingVertical`).

- `AdmTheme` (`adm_theme.dart`) is an `InheritedWidget` that injects `AdmThemeData` into the tree. It is the Flutter analogue of antd-mobile's `ConfigProvider`.
- Components read tokens via `AdmTheme.tokensOf(context)` — **never hardcode colors, radii, font sizes, or spacing**. If a value isn't on `AdmTokens`, add it there rather than inlining a literal.
- `AdmThemeData.toMaterialTheme()` projects tokens onto a `ThemeData` so Material widgets used inside a consumer app stay visually consistent.
- Dark mode is `const AdmThemeData.dark()`; it swaps in `AdmTokens.dark`. New tokens must have a sensible dark-mode value too.
- `AdmApp` is a convenience that wraps `AdmTheme` + `MaterialApp` with `theme: themeData.toMaterialTheme()` already wired.

### Component conventions

- One component per directory under `lib/src/components/<name>/adm_<name>.dart`. Each new component must be re-exported from `lib/antd_mobile_flutter.dart` (the single public barrel) — that file is the public API surface.
- All public types are prefixed `Adm` (`AdmButton`, `AdmListItem`, `AdmFormController`, `AdmButtonColor` enums, …). Keep this prefix for anything exported.
- Components are stateless / `StatefulWidget` with no third-party state-management dependency. Form state is managed by `AdmFormController` (a `ChangeNotifier`) — see `lib/src/components/form/adm_form.dart` for the pattern: a controller holds values, errors, validators, and submitters keyed by field name; `AdmFormItem` registers itself on mount.
- "Atomic & composable — each component does exactly one thing" is a stated design rule (README). Prefer composing existing widgets over adding flags to old ones.
- Variants follow antd-mobile vocabulary: `color` (primary / success / warning / danger / default), `fill` (solid / outline / none / ghost / link), `size` (mini / small / middle / large). Mirror these names when adding new components rather than inventing new ones.
- Named factory constructors (e.g. `AdmButton.primary`, `AdmButton.icon`) are the preferred ergonomic API for common variants — keep adding them when a config is repeated often.

### Icons

`lib/src/theme/adm_icons.dart` is a generated-ish file: ~1500 `IconData` constants backed by `assets/fonts/AdmIcons.ttf` (font family `AdmIcons`, package `antd_mobile_flutter`). Each icon has a base64-inlined SVG preview in its dartdoc comment — those previews are produced by `dart tool/update_icon_docs.dart`, which rewrites `/// ![](https://raw.githubusercontent.com/lucide-icons/lucide/...)` lines into inline `data:image/svg+xml;base64,...` URIs. Don't hand-edit the base64 blobs; if icons are added/removed, regenerate via the tool. Source set is lucide (https://icons.obra.studio/).

### Lint rules in force

`analysis_options.yaml` extends `package:flutter_lints/flutter.yaml` and additionally enforces:
`prefer_const_constructors`, `prefer_const_declarations`, `avoid_unnecessary_containers`, `use_key_in_widget_constructors`, `sized_box_for_whitespace`. Run `flutter analyze` before considering a change done.

## When adding or modifying a component

1. Read an existing similar component first — patterns (token lookup, variant enums, factory constructors, dark-mode handling) are consistent across the library and should stay that way.
2. Any new visual constant goes on `AdmTokens` with a default + a dark counterpart in `AdmTokens.dark`.
3. Re-export from `lib/antd_mobile_flutter.dart`.
4. Add or update a page in `example/main.dart` so the showcase exercises the new surface, then `cd example && flutter run` and verify both light and dark mode using the toggle in the showcase home.
