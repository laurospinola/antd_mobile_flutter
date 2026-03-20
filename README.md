# antd_mobile_flutter

A Flutter UI component library inspired by [ant-design-mobile](https://ant-design-mobile.antgroup.com/), providing a complete set of mobile-first widgets with a token-based design system.

> **Internal package** — designed to be dropped into any Flutter project via a local path or private Git dependency.

---

## Features

- 🎨 **Token-based theming** — mirrors ant-design-mobile's CSS variable system  
- 🌙 **Dark mode** — built-in dark theme, switchable at runtime  
- 📱 **30+ components** — buttons, lists, cards, tabs, forms, feedback, and more  
- ⚡ **Atomic & composable** — each component does exactly one thing  
- 🔧 **Zero dependencies** — only Flutter SDK, no third-party packages  

---

## Quick Start

### 1. Add to `pubspec.yaml`

```yaml
dependencies:
  antd_mobile_flutter:
    path: ../antd_mobile_flutter   # local path
    # OR
    git:
      url: https://github.com/your-org/antd_mobile_flutter.git
```

### 2. Wrap your app

```dart
import 'package:antd_mobile_flutter/antd_mobile_flutter.dart';

void main() {
  runApp(
    AdmTheme(
      data: const AdmThemeData(),  // light
      // data: const AdmThemeData.dark(),  // dark
      child: MaterialApp(
        theme: const AdmThemeData().toMaterialTheme(),
        home: MyHomePage(),
      ),
    ),
  );
}
```

Or use the convenience wrapper:

```dart
AdmApp(
  themeData: const AdmThemeData(),
  home: MyHomePage(),
)
```

---

## Theme Customization

Override any design token — identical concept to ant-design-mobile's `ConfigProvider`:

```dart
AdmTheme(
  data: AdmThemeData(
    tokens: AdmTokens(
      colorPrimary: Color(0xFF06C755),   // LINE green
      buttonBorderRadius: 8.0,
      navBarHeight: 50.0,
    ),
  ),
  child: child,
)
```

Access tokens anywhere in the tree:

```dart
final tokens = AdmTheme.tokensOf(context);
Container(color: tokens.colorPrimary)
```

---

## Components

### General
| Widget | Description |
|--------|-------------|
| `AdmButton` | Primary / danger / success / warning / outline / ghost, 4 sizes |
| `AdmAvatar` | Image / text / icon, circle or square |
| `AdmBadge` | Count or dot overlay |
| `AdmTag` | Colored labels, closeable, pill shape |
| `AdmDivider` | Horizontal/vertical separator with optional label |
| `AdmSpace` | Flex gap container (horizontal/vertical/wrap) |
| `AdmGrid` | N-column uniform grid |

### Navigation
| Widget | Description |
|--------|-------------|
| `AdmNavBar` | Top navigation bar (title, back, right actions) |
| `AdmTabBar` | Bottom tab bar with badge/dot support |
| `AdmTabs` | Horizontal scrollable tabs with animated indicator |

### Data Display
| Widget | Description |
|--------|-------------|
| `AdmCard` | Header + body + footer card |
| `AdmList` / `AdmListItem` | iOS-style list with prefix, extra, arrow, swipe |
| `AdmSkeleton` | Shimmer placeholder (title / paragraph / avatar / wrap) |
| `AdmSteps` | Horizontal/vertical step tracker |
| `AdmProgress` | Linear bar + circle ring variants |
| `AdmEmpty` | Empty state illustration + CTA |
| `AdmResult` | Success / error / info / waiting result screen |
| `AdmImage` | Network image with skeleton + error fallback |
| `AdmCollapse` | Expandable accordion panels |
| `AdmNoticeBar` | Dismissable notice banner |

### Data Entry
| Widget | Description |
|--------|-------------|
| `AdmInput` | Text field with label, prefix, suffix, clearable, password |
| `AdmSearchBar` | Search field with cancel button |
| `AdmCheckbox` / `AdmCheckboxGroup` | Checkbox with group support |
| `AdmRadio` / `AdmRadioGroup` | Radio button with group support |
| `AdmSwitch` | iOS-style toggle |
| `AdmStepper` | Numeric increment/decrement |
| `AdmForm` / `AdmFormItem` | Form wrapper with validation |

### Feedback
| Widget | Description |
|--------|-------------|
| `AdmToast` | Auto-dismiss overlay (info/success/fail/loading) |
| `AdmModal` | Alert / confirm / custom dialog |
| `AdmActionSheet` | iOS-style bottom action menu |
| `AdmLoading` | Spinning circle + bouncing dots |
| `AdmPopup` | Bottom/top/left/right/center sheet |
| `AdmMask` | Semi-transparent overlay |

### Interaction
| Widget | Description |
|--------|-------------|
| `AdmSwipeAction` | Swipeable list item with action buttons |
| `AdmPullToRefresh` | Pull-down refresh wrapper |
| `AdmInfiniteScroll` | Infinite scroll footer trigger |

---

## Token Reference

Key tokens in `AdmTokens` (all have defaults matching ant-design-mobile):

```dart
// Colors
colorPrimary       // #1677FF
colorSuccess       // #00B578
colorWarning       // #FF8F1F
colorDanger        // #FF3141
colorTextBase      // #333333
colorTextSecondary // #666666
colorBackground    // #FFFFFF
colorBackgroundBody// #F5F5F5
colorBorder        // #EEEEEE

// Spacing
spaceXs / spaceSm / spaceMd / spaceLg / spaceXl / spaceXxl

// Font sizes
fontSizeXs(10) / fontSizeSm(12) / fontSizeMd(14) / fontSizeLg(16) / fontSizeXl(18) / fontSizeXxl(22)

// Radius
radiusSm(4) / radiusMd(6) / radiusLg(8) / radiusXl(12) / radiusPill(999)

// Animation
animationDurationFast(100ms) / animationDurationMid(200ms) / animationDurationSlow(300ms)
```

---

## Running the Example

```bash
cd example
flutter pub get
flutter run
```

---

## License

Internal use only — do not publish publicly without permission.
