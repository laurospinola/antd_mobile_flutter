# antd_mobile_flutter

A Flutter UI component library inspired by [ant-design-mobile](https://ant-design-mobile.antgroup.com/), providing a complete set of mobile-first widgets with a token-based design system — the first Ant Design Mobile port for Flutter.

> **Internal package** — install directly from GitHub, no pub.dev required.

---

## Table of Contents

- [Installation](#installation)
  - [From GitHub (recommended)](#from-github-recommended)
  - [Pin to a version](#pin-to-a-version)
  - [Private repository](#private-repository)
  - [Local path (development)](#local-path-development)
  - [CI / GitHub Actions](#ci--github-actions)
- [Quick Start](#quick-start)
- [Theme Customization](#theme-customization)
- [Components](#components)
- [Token Reference](#token-reference)
- [Running the Example](#running-the-example)

---

## Installation

### From GitHub (recommended)

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  antd_mobile_flutter:
    git:
      url: https://github.com/your-org/antd_mobile_flutter.git
      ref: main
```

Then run:

```bash
flutter pub get
```

---

### Pin to a version

Using `main` always pulls the latest commit. For a stable build, pin to a **tag** or **commit SHA** instead:

```yaml
# Pin to a release tag (recommended for production)
antd_mobile_flutter:
  git:
    url: https://github.com/your-org/antd_mobile_flutter.git
    ref: v0.1.0

# Pin to an exact commit SHA (maximum reproducibility)
antd_mobile_flutter:
  git:
    url: https://github.com/your-org/antd_mobile_flutter.git
    ref: a3f9c2d1b4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9
```

To create a release tag on GitHub:

```bash
git tag v0.1.0
git push origin v0.1.0
```

---

### Private repository

If your repo is private, Flutter's Git dependency uses SSH for authentication.

**Step 1 — Generate an SSH key** (skip if you already have one):

```bash
ssh-keygen -t ed25519 -C "flutter-deploy" -f ~/.ssh/antd_deploy
```

**Step 2 — Add the public key as a Deploy Key** on GitHub:

> GitHub → your repo → **Settings** → **Deploy keys** → **Add deploy key**

Paste the contents of `~/.ssh/antd_deploy.pub`. Read-only access is sufficient.

**Step 3 — Use the SSH URL** in `pubspec.yaml`:

```yaml
antd_mobile_flutter:
  git:
    url: git@github.com:your-org/antd_mobile_flutter.git
    ref: main
```

**Step 4 — Make sure your SSH agent has the key loaded:**

```bash
ssh-add ~/.ssh/antd_deploy
flutter pub get
```

---

### Local path (development)

When you are actively developing the package alongside your app, use a local path reference so changes are reflected immediately without pushing to GitHub:

```yaml
antd_mobile_flutter:
  path: ../antd_mobile_flutter   # relative path to the package folder
```

Switch back to the Git reference when you are done developing.

---

### CI / GitHub Actions

To pull a private GitHub dependency inside a CI pipeline, inject your deploy key using the `webfactory/ssh-agent` action before running `flutter pub get`:

```yaml
# .github/workflows/build.yml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: webfactory/ssh-agent@v0.9.0
        with:
          ssh-private-key: ${{ secrets.DEPLOY_KEY }}

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'

      - run: flutter pub get
      - run: flutter build apk --release
```

Add the private key (`~/.ssh/antd_deploy`) as a repository secret named `DEPLOY_KEY` in:

> GitHub → your app repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

---

## Quick Start

### 1. Import the package

```dart
import 'package:antd_mobile_flutter/antd_mobile_flutter.dart';
```

### 2. Wrap your app with `AdmTheme`

```dart
void main() {
  runApp(
    AdmTheme(
      data: const AdmThemeData(),        // light theme
      // data: const AdmThemeData.dark(), // dark theme
      child: MaterialApp(
        theme: const AdmThemeData().toMaterialTheme(),
        home: const MyHomePage(),
      ),
    ),
  );
}
```

Or use the `AdmApp` convenience wrapper which handles both for you:

```dart
void main() {
  runApp(
    AdmApp(
      themeData: const AdmThemeData(),
      home: const MyHomePage(),
    ),
  );
}
```

### 3. Use components

```dart
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AdmNavBar(title: const Text('Home')),
          AdmButton.primary(
            onPressed: () {},
            child: const Text('Get Started'),
          ),
          AdmCard(
            header: const Text('Welcome'),
            child: const Text('Built with antd_mobile_flutter.'),
          ),
        ],
      ),
    );
  }
}
```

---

## Theme Customization

`AdmTheme` is the Flutter equivalent of ant-design-mobile's `ConfigProvider`. Wrap any subtree to apply a custom theme — tokens that are not overridden inherit from the parent.

```dart
AdmTheme(
  data: AdmThemeData(
    tokens: AdmTokens(
      colorPrimary: Color(0xFF06C755),  // brand green
      buttonBorderRadius: 8.0,
      fontSizeMd: 15.0,
      navBarHeight: 50.0,
    ),
  ),
  child: MyFeatureScreen(),
)
```

**Switch between light and dark at runtime:**

```dart
class _AppState extends State<App> {
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    return AdmTheme(
      data: _dark ? const AdmThemeData.dark() : const AdmThemeData(),
      child: MaterialApp(
        theme: (_dark ? const AdmThemeData.dark() : const AdmThemeData())
            .toMaterialTheme(),
        home: MyHome(onToggle: () => setState(() => _dark = !_dark)),
      ),
    );
  }
}
```

**Read tokens anywhere in the widget tree:**

```dart
final tokens = AdmTheme.tokensOf(context);

Container(
  color: tokens.colorPrimary,
  padding: EdgeInsets.all(tokens.spaceLg),
  child: Text(
    'Hello',
    style: TextStyle(
      fontSize: tokens.fontSizeLg,
      color: tokens.colorTextWhite,
    ),
  ),
)
```

---

## Components

### General
| Widget | Description |
|--------|-------------|
| `AdmButton` | Solid / outline / ghost · primary / danger / success / warning · 4 sizes · loading state |
| `AdmAvatar` | Image / text initial / icon · circle or square · 5 sizes |
| `AdmBadge` | Count badge or red dot overlay on any widget |
| `AdmTag` | Colored labels · closeable · pill / rounded variants |
| `AdmDivider` | Horizontal or vertical separator with optional center label |
| `AdmSpace` | Uniform-gap flex row/column/wrap container |
| `AdmGrid` | Responsive N-column grid |

### Navigation
| Widget | Description |
|--------|-------------|
| `AdmNavBar` | Top bar with title, back button, and right action slot |
| `AdmTabBar` | Bottom navigation bar with badge/dot per tab |
| `AdmTabs` | Horizontal scrollable tab strip with animated underline indicator |

### Data Display
| Widget | Description |
|--------|-------------|
| `AdmCard` | Header + body + footer card with shadow |
| `AdmList` / `AdmListItem` | iOS-style list — prefix icon, description, extra, arrow, disabled |
| `AdmSkeleton` | Shimmer loading placeholder — line, title, paragraph, avatar, wrap modes |
| `AdmSteps` | Horizontal and vertical step tracker — finish / process / error states |
| `AdmProgress` | Linear progress bar and circle ring with status variants |
| `AdmEmpty` | Empty state with custom illustration and CTA slot |
| `AdmResult` | Full-screen result view — success / error / info / waiting |
| `AdmImage` | Network image with shimmer loading and broken-image fallback |
| `AdmCollapse` | Expandable accordion panels with animated open/close · accordion mode |
| `AdmNoticeBar` | Dismissable notice banner with custom color and icon |

### Data Entry
| Widget | Description |
|--------|-------------|
| `AdmInput` | Text field — label, prefix/suffix, clearable, password toggle, error message |
| `AdmSearchBar` | Search field with animated cancel button |
| `AdmCheckbox` / `AdmCheckboxGroup` | Checkbox with indeterminate state and horizontal/vertical group |
| `AdmRadio` / `AdmRadioGroup` | Radio button with horizontal/vertical group |
| `AdmSwitch` | iOS-style animated toggle with loading state |
| `AdmStepper` | Numeric stepper with min / max / step constraints |
| `AdmForm` / `AdmFormItem` | Form layout with `AdmFormController` for validation and field tracking |

### Feedback
| Widget | Description |
|--------|-------------|
| `AdmToast` | Auto-dismissing overlay — info / success / fail / loading |
| `AdmModal` | Alert, confirm, and custom dialog with configurable action buttons |
| `AdmActionSheet` | iOS-style bottom action menu with danger / disabled / description |
| `AdmLoading` | Spinning circle (`AdmLoading()`) and bouncing dots (`AdmLoading.dots()`) |
| `AdmPopup` | Animated sheet from bottom / top / left / right / center |
| `AdmMask` | Animated semi-transparent full-screen overlay |

### Interaction
| Widget | Description |
|--------|-------------|
| `AdmSwipeAction` | Left and right swipe-to-reveal action buttons on any widget |
| `AdmPullToRefresh` | Pull-down-to-refresh wrapper around any scrollable |
| `AdmInfiniteScroll` | Auto-trigger load-more footer with error and no-more states |

---

## Token Reference

All tokens live in `AdmTokens` and map 1:1 to ant-design-mobile's `--adm-*` CSS variables.

```dart
// ── Brand colors ──────────────────────────────────────────────────────────
colorPrimary        // Color(0xFF1677FF)
colorSuccess        // Color(0xFF00B578)
colorWarning        // Color(0xFFFF8F1F)
colorDanger         // Color(0xFFFF3141)

// ── Text ──────────────────────────────────────────────────────────────────
colorTextBase       // Color(0xFF333333)
colorTextSecondary  // Color(0xFF666666)
colorTextTertiary   // Color(0xFF999999)
colorTextDisabled   // Color(0xFFCCCCCC)
colorTextWhite      // Color(0xFFFFFFFF)
colorTextLink       // Color(0xFF1677FF)

// ── Surface ───────────────────────────────────────────────────────────────
colorBackground     // Color(0xFFFFFFFF)
colorBackgroundBody // Color(0xFFF5F5F5)
colorBorder         // Color(0xFFEEEEEE)
colorFill           // Color(0xFFF5F5F5)

// ── Spacing ───────────────────────────────────────────────────────────────
spaceXs   //  4px
spaceSm   //  8px
spaceMd   // 12px
spaceLg   // 16px
spaceXl   // 24px
spaceXxl  // 32px

// ── Font sizes ────────────────────────────────────────────────────────────
fontSizeXs   // 10px
fontSizeSm   // 12px
fontSizeMd   // 14px  (body default)
fontSizeLg   // 16px
fontSizeXl   // 18px
fontSizeXxl  // 22px

// ── Border radius ─────────────────────────────────────────────────────────
radiusXs    //  2px
radiusSm    //  4px
radiusMd    //  6px
radiusLg    //  8px
radiusXl    // 12px
radiusPill  // 999px

// ── Animation ─────────────────────────────────────────────────────────────
animationDurationFast  // 100ms
animationDurationMid   // 200ms
animationDurationSlow  // 300ms
animationCurveDefault  // Curves.easeInOut

// ── Component-specific ────────────────────────────────────────────────────
buttonBorderRadius     //  4px
buttonDefaultHeight    // 44px
navBarHeight           // 45px
tabBarHeight           // 50px
tabBarActiveColor      // colorPrimary
listItemMinHeight      // 44px
```

---

## Running the Example

```bash
git clone https://github.com/your-org/antd_mobile_flutter.git
cd antd_mobile_flutter/example
flutter pub get
flutter run
```

The example app is a 4-tab showcase covering every component with a live light/dark mode toggle.

---

## Requirements

| Dependency | Version |
|---|---|
| Flutter | ≥ 3.10.0 |
| Dart SDK | ≥ 3.0.0 |
| External packages | None |

---

## License

Internal use only — do not publish publicly without permission.