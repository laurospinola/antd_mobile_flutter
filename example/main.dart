import 'package:antd_mobile_flutter/antd_mobile_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ShowcaseApp());
}

class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key});

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return AdmTheme(
      data: _darkMode ? const AdmThemeData.dark() : const AdmThemeData(),
      child: MaterialApp(
        title: 'ADM Flutter Showcase',
        theme: (_darkMode ? const AdmThemeData.dark() : const AdmThemeData()).toMaterialTheme(),
        debugShowCheckedModeBanner: false,
        home: ShowcaseHome(
          darkMode: _darkMode,
          onToggleDark: () => setState(() => _darkMode = !_darkMode),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class ShowcaseHome extends StatefulWidget {
  final bool darkMode;
  final VoidCallback onToggleDark;

  const ShowcaseHome({super.key, required this.darkMode, required this.onToggleDark});

  @override
  State<ShowcaseHome> createState() => _ShowcaseHomeState();
}

class _ShowcaseHomeState extends State<ShowcaseHome> {
  int _tabIndex = 0;

  final _pages = const [
    _ComponentsPage(),
    _FormsPage(),
    _FeedbackPage(),
    _ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);

    return Scaffold(
      backgroundColor: tokens.colorBackgroundBody,
      body: Column(
        children: [
          AdmNavBar(
            title: const Text('ADM Flutter'),
            right: GestureDetector(
              onTap: widget.onToggleDark,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(AdmIcons.airplay),
              ),
            ),
          ),
          // AdmNavBar(
          //   title: const Text('ADM Flutter'),
          //   right: GestureDetector(
          //     onTap: widget.onToggleDark,
          //     child: Padding(
          //       padding: const EdgeInsets.only(right: 16),
          //       child: AdmIcon(
          //         widget.darkMode ? AppSvgIcons.sun : AppSvgIcons.moon,
          //         size: 22,
          //         color: tokens.colorTextBase,
          //       ),
          //     ),
          //   ),
          // ),
          Expanded(child: _pages[_tabIndex]),
          AdmTabBar(
            activeIndex: _tabIndex,
            onChange: (i) => setState(() => _tabIndex = i),
            items: const [
              AdmTabBarItem(
                icon: Icon(AdmIcons.layout_grid),
                activeIcon: Icon(AdmIcons.layout_grid),
                title: Text('Components'),
              ),
              AdmTabBarItem(
                icon: Icon(AdmIcons.pencil),
                activeIcon: Icon(AdmIcons.pencil),
                title: Text('Forms'),
              ),
              AdmTabBarItem(
                icon: Icon(AdmIcons.bell),
                activeIcon: Icon(AdmIcons.bell_ring),
                title: Text('Feedback'),
                dot: true,
              ),
              AdmTabBarItem(
                icon: Icon(AdmIcons.user),
                activeIcon: Icon(AdmIcons.user),
                title: Text('Profile'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Components Page
// ─────────────────────────────────────────────────────────────────────────────

class _ComponentsPage extends StatefulWidget {
  const _ComponentsPage();

  @override
  State<_ComponentsPage> createState() => _ComponentsPageState();
}

class _ComponentsPageState extends State<_ComponentsPage> {
  int _tabIndex = 0;
  int _stepIndex = 1;

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Buttons'),
          AdmSpace(direction: Axis.vertical, gap: tokens.spaceSm, children: [
            AdmSpace(wrap: true, gap: tokens.spaceSm, children: [
              AdmButton.primary(child: const Text('Primary'), onPressed: () {}),
              AdmButton(color: AdmButtonColor.success, child: const Text('Success'), onPressed: () {}),
              AdmButton(color: AdmButtonColor.warning, child: const Text('Warning'), onPressed: () {}),
              AdmButton.danger(child: const Text('Danger'), onPressed: () {}),
              AdmButton(child: const Text('Default'), onPressed: () {}),
            ]),
            AdmSpace(wrap: true, gap: tokens.spaceSm, children: [
              AdmButton(
                  fill: AdmButtonFill.outline,
                  color: AdmButtonColor.primary,
                  child: const Text('Outline'),
                  onPressed: () {}),
              AdmButton(
                  fill: AdmButtonFill.none,
                  color: AdmButtonColor.primary,
                  child: const Text('Ghost'),
                  onPressed: () {}),
              AdmButton(size: AdmButtonSize.small, child: const Text('Small'), onPressed: () {}),
              AdmButton(
                  size: AdmButtonSize.mini, color: AdmButtonColor.primary, child: const Text('Mini'), onPressed: () {}),
              AdmButton(disabled: true, child: const Text('Disabled'), onPressed: () {}),
              AdmButton(loading: true, color: AdmButtonColor.primary, child: const Text('Loading'), onPressed: () {}),
            ]),
            AdmButton.primary(
                block: true, size: AdmButtonSize.large, child: const Text('Block Button'), onPressed: () {}),
          ]),
          SizedBox(height: tokens.spaceXl),
          const _SectionTitle('Tags & Badges'),
          AdmSpace(wrap: true, gap: tokens.spaceSm, children: const [
            AdmTag(color: AdmTagColor.primary, child: Text('Primary')),
            AdmTag(color: AdmTagColor.success, child: Text('Success')),
            AdmTag(color: AdmTagColor.warning, child: Text('Warning')),
            AdmTag(color: AdmTagColor.danger, child: Text('Danger')),
            AdmTag(fill: AdmTagFill.outline, color: AdmTagColor.primary, child: Text('Outline')),
            AdmTag(round: true, color: AdmTagColor.success, child: Text('Pill')),
            AdmTag(closeable: true, color: AdmTagColor.primary, child: Text('Close me')),
          ]),
          SizedBox(height: tokens.spaceMd),
          AdmSpace(gap: tokens.spaceXl, children: const [
            AdmBadge(
              content: Text('5'),
              child: Icon(AdmIcons.bell, size: 28),
            ),
            AdmBadge(
              content: Text('99+'),
              child: Icon(AdmIcons.mail, size: 28),
            ),
            AdmBadge(
              content: AdmBadge.dot,
              child: Icon(AdmIcons.message_circle, size: 28),
            ),
          ]),
          SizedBox(height: tokens.spaceXl),
          const _SectionTitle('Avatars'),
          AdmSpace(gap: tokens.spaceMd, children: [
            AdmAvatar(text: 'AK', backgroundColor: tokens.colorPrimary, size: AdmAvatarSize.small),
            AdmAvatar(text: 'BC', backgroundColor: tokens.colorSuccess, size: AdmAvatarSize.middle),
            AdmAvatar(text: 'DE', backgroundColor: tokens.colorWarning, size: AdmAvatarSize.large),
            AdmAvatar(text: 'FG', backgroundColor: tokens.colorDanger, size: AdmAvatarSize.xl),
            AdmAvatar(icon: Icon(AdmIcons.user), backgroundColor: AdmColors.grey6, size: AdmAvatarSize.large),
            AdmAvatar(
                text: 'SQ',
                shape: AdmAvatarShape.square,
                backgroundColor: tokens.colorPrimary,
                size: AdmAvatarSize.large),
          ]),
          SizedBox(height: tokens.spaceXl),
          const _SectionTitle('Tabs'),
          SizedBox(
            height: 300,
            child: AdmTabs(
              tabs: const [
                AdmTabItem(title: Text('All')),
                AdmTabItem(title: Text('Active'), dot: true),
                AdmTabItem(title: Text('Pending')),
                AdmTabItem(title: Text('Done')),
              ],
              activeIndex: _tabIndex,
              onChange: (i) => setState(() => _tabIndex = i),
              tabViewHeight: 120,
              children: List.generate(4, (i) {
                const labels = ['All', 'Active', 'Pending', 'Done'];
                return Container(
                  padding: EdgeInsets.all(tokens.spaceMd),
                  decoration: BoxDecoration(
                    color: tokens.colorBackground,
                    border: Border(
                      top: BorderSide(color: tokens.colorBorder),
                    ),
                  ),
                  child: Center(child: Text('Content for "${labels[i]}" tab')),
                );
              }),
            ),
          ),
          SizedBox(height: tokens.spaceXl),
          const _SectionTitle('Steps'),
          AdmSteps(
            current: _stepIndex,
            items: const [
              AdmStepItem(title: Text('Order Placed'), description: Text('Jan 1')),
              AdmStepItem(title: Text('Processing'), description: Text('Jan 2')),
              AdmStepItem(title: Text('Shipped'), description: Text('Pending')),
              AdmStepItem(title: Text('Delivered')),
            ],
          ),
          SizedBox(height: tokens.spaceSm),
          AdmSpace(gap: tokens.spaceSm, children: [
            AdmButton(
                size: AdmButtonSize.small,
                disabled: _stepIndex == 0,
                onPressed: () => setState(() => _stepIndex = (_stepIndex - 1).clamp(0, 3)),
                child: const Text('Back')),
            AdmButton(
                size: AdmButtonSize.small,
                color: AdmButtonColor.primary,
                disabled: _stepIndex == 3,
                onPressed: () => setState(() => _stepIndex = (_stepIndex + 1).clamp(0, 3)),
                child: const Text('Next')),
          ]),
          SizedBox(height: tokens.spaceXl),
          const _SectionTitle('Progress'),
          AdmSpace(direction: Axis.vertical, gap: tokens.spaceMd, children: [
            const AdmProgress(percent: 0.3),
            const AdmProgress(percent: 0.6, status: AdmProgressStatus.active),
            const AdmProgress(percent: 1.0, status: AdmProgressStatus.success),
            const AdmProgress(percent: 0.5, status: AdmProgressStatus.error),
            AdmSpace(gap: tokens.spaceXl, children: [
              AdmProgress.circle(percent: 0.75, size: 64),
              AdmProgress.circle(percent: 1.0, size: 64, status: AdmProgressStatus.success),
              AdmProgress.circle(percent: 0.4, size: 64, status: AdmProgressStatus.error),
            ]),
          ]),
          SizedBox(height: tokens.spaceXl),
          const _SectionTitle('Card'),
          AdmCard(
            header: const Text('Order Summary'),
            headerExtra: const AdmTag(color: AdmTagColor.success, child: Text('Paid')),
            footer: const Text('Updated just now'),
            footerExtra: const Text('View all →'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('3 items  •  \$129.00',
                    style: TextStyle(
                        fontSize: tokens.fontSizeLg, fontWeight: tokens.fontWeightBold, color: tokens.colorTextBase)),
                SizedBox(height: tokens.spaceXs),
                Text('Estimated delivery: Jan 10',
                    style: TextStyle(fontSize: tokens.fontSizeSm, color: tokens.colorTextSecondary)),
              ],
            ),
          ),
          SizedBox(height: tokens.spaceXl),
          const _SectionTitle('List'),
          AdmList(
            header: const Text('Settings'),
            footer: const Text('Version 1.0.0'),
            children: [
              AdmListItem(
                prefix: Icon(AdmIcons.user, size: 20),
                title: const Text('Profile'),
                extra: const Text('Edit'),
                arrow: true,
                onTap: () {},
              ),
              AdmListItem(
                prefix: Icon(AdmIcons.bell, size: 20),
                title: const Text('Notifications'),
                extra: AdmSwitch(checked: true, onChange: (_) {}),
              ),
              AdmListItem(
                prefix: Icon(AdmIcons.globe, size: 20),
                title: const Text('Language'),
                extra: const Text('English'),
                arrow: true,
                onTap: () {},
              ),
              AdmListItem(
                prefix: Icon(AdmIcons.circle_help, size: 20),
                title: const Text('Help Center'),
                arrow: true,
                disabled: false,
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: tokens.spaceXl),
          const _SectionTitle('Swipe Actions'),
          AdmList(
            children: [
              AdmSwipeAction(
                rightActions: [
                  AdmSwipeActionButton(
                    text: const Text('Archive'),
                    color: AdmColors.blue6,
                    onPress: () {},
                  ),
                  AdmSwipeActionButton(
                    text: const Text('Delete'),
                    color: AdmColors.red5,
                    onPress: () {},
                  ),
                ],
                child: AdmListItem(
                  prefix: Icon(AdmIcons.mail, size: 20),
                  title: const Text('Swipe me left'),
                  description: const Text('Reveal archive & delete actions'),
                ),
              ),
              AdmSwipeAction(
                leftActions: [
                  AdmSwipeActionButton(
                    text: const Text('Pin'),
                    color: AdmColors.orange6,
                    onPress: () {},
                  ),
                ],
                rightActions: [
                  AdmSwipeActionButton(
                    text: const Text('Delete'),
                    color: AdmColors.red5,
                    onPress: () {},
                  ),
                ],
                child: AdmListItem(
                  prefix: Icon(AdmIcons.star, size: 20),
                  title: const Text('Swipe either way'),
                  description: const Text('Left or right'),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceXl),
          const _SectionTitle('Skeleton'),
          AdmSkeleton.wrap(loading: true, child: const SizedBox.shrink()),
          SizedBox(height: tokens.spaceXl),
          const _SectionTitle('Empty'),
          AdmEmpty(
            description: const Text('No orders yet'),
            child: AdmButton.primary(size: AdmButtonSize.small, child: const Text('Start Shopping'), onPressed: () {}),
          ),
          SizedBox(height: tokens.spaceXl),
          const _SectionTitle('Result'),
          AdmResult(
            status: AdmResultStatus.success,
            title: const Text('Payment Complete'),
            description: const Text('Your order #1234 has been placed successfully.'),
            child: AdmButton(
                fill: AdmButtonFill.outline,
                color: AdmButtonColor.primary,
                child: const Text('View Order'),
                onPressed: () {}),
          ),
          SizedBox(height: tokens.spaceXxl),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Forms Page
// ─────────────────────────────────────────────────────────────────────────────

class _FormsPage extends StatefulWidget {
  const _FormsPage();

  @override
  State<_FormsPage> createState() => _FormsPageState();
}

class _FormsPageState extends State<_FormsPage> {
  final _formCtrl = AdmFormController();
  bool _switchVal = false;
  bool _checkA = false;
  bool _checkB = true;
  String _radio = 'option1';
  int _qty = 1;
  List<String> _cascaderLabels = [];
  List<String> _cascaderValues = [];

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spaceLg),
      child: AdmForm(
        controller: _formCtrl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Input'),
            AdmFormItem(
              name: 'email',
              label: const Text('Email'),
              required: true,
              rules: [(v) => (v == null || v.isEmpty) ? 'Email is required' : null],
              child: AdmInput(
                placeholder: 'Enter your email',
                prefix: Icon(AdmIcons.mail, size: 20),
                clearable: true,
                keyboardType: TextInputType.emailAddress,
                onChanged: (v) => _formCtrl.setField('email', v),
              ),
            ),
            AdmFormItem(
              name: 'password',
              label: const Text('Password'),
              required: true,
              child: AdmInput(
                placeholder: 'Enter password',
                prefix: Icon(AdmIcons.lock, size: 20),
                password: true,
                onChanged: (v) => _formCtrl.setField('password', v),
              ),
            ),
            AdmFormItem(
              name: 'search',
              label: const Text('Search Bar'),
              child: AdmSearchBar(
                placeholder: 'Search something...',
                showCancelButton: true,
                onChanged: (v) => _formCtrl.setField('search', v),
              ),
            ),
            AdmFormItem(
              name: 'bio',
              label: const Text('Bio'),
              help: 'Max 200 characters',
              child: AdmInput(
                placeholder: 'Tell us about yourself...',
                maxLines: 4,
                maxLength: 200,
                onChanged: (v) => _formCtrl.setField('bio', v),
              ),
            ),
            AdmFormItem(
                name: 'bio',
                label: const Text('Bio'),
                help: 'Max 200 characters',
                child: AdmOtpInput(
                  length: 6,
                )),
            const _SectionTitle('Switch'),
            AdmFormItem(
              label: const Text('Enable notifications'),
              child: Row(children: [
                AdmSwitch(
                  checked: _switchVal,
                  onChange: (v) => setState(() => _switchVal = v),
                ),
                SizedBox(width: tokens.spaceSm),
                Text(
                  _switchVal ? 'On' : 'Off',
                  style: TextStyle(color: tokens.colorTextSecondary),
                ),
              ]),
            ),
            const _SectionTitle('Checkbox'),
            AdmFormItem(
              label: const Text('Interests'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdmCheckbox(
                    checked: _checkA,
                    onChange: (v) => setState(() => _checkA = v),
                    child: const Text('Technology'),
                  ),
                  SizedBox(height: tokens.spaceSm),
                  AdmCheckbox(
                    checked: _checkB,
                    onChange: (v) => setState(() => _checkB = v),
                    child: const Text('Design'),
                  ),
                ],
              ),
            ),
            const _SectionTitle('Radio'),
            AdmFormItem(
              label: const Text('Subscription plan'),
              child: AdmRadioGroup<String>(
                value: _radio,
                onChange: (v) => setState(() => _radio = v),
                options: const [
                  AdmRadioOption(value: 'option1', label: Text('Free')),
                  AdmRadioOption(value: 'option2', label: Text('Pro')),
                  AdmRadioOption(value: 'option3', label: Text('Enterprise')),
                ],
              ),
            ),
            const _SectionTitle('Stepper'),
            AdmFormItem(
              label: const Text('Quantity'),
              child: AdmStepper(
                value: _qty,
                min: 1,
                max: 10,
                onChange: (v) => setState(() => _qty = v),
              ),
            ),
            const _SectionTitle('Cascader'),
            GestureDetector(
              onTap: () async {
                final result = await AdmCascader.show(
                  context,
                  title: const Text('Select Category'),
                  defaultValue: _cascaderValues.isEmpty ? null : _cascaderValues,
                  options: const [
                    AdmCascaderOption(
                      value: 'electronics',
                      label: 'Electronics',
                      children: [
                        AdmCascaderOption(
                          value: 'phones',
                          label: 'Phones',
                          children: [
                            AdmCascaderOption(value: 'apple', label: 'Apple'),
                            AdmCascaderOption(value: 'samsung', label: 'Samsung'),
                            AdmCascaderOption(value: 'google', label: 'Google'),
                          ],
                        ),
                        AdmCascaderOption(
                          value: 'computers',
                          label: 'Computers',
                          children: [
                            AdmCascaderOption(value: 'laptops', label: 'Laptops'),
                            AdmCascaderOption(value: 'desktops', label: 'Desktops'),
                          ],
                        ),
                        AdmCascaderOption(
                          value: 'audio',
                          label: 'Audio',
                          children: [
                            AdmCascaderOption(value: 'headphones', label: 'Headphones'),
                            AdmCascaderOption(value: 'speakers', label: 'Speakers'),
                          ],
                        ),
                      ],
                    ),
                    AdmCascaderOption(
                      value: 'clothing',
                      label: 'Clothing',
                      children: [
                        AdmCascaderOption(
                          value: 'men',
                          label: 'Men',
                          children: [
                            AdmCascaderOption(value: 'shirts', label: 'Shirts'),
                            AdmCascaderOption(value: 'pants', label: 'Pants'),
                            AdmCascaderOption(value: 'shoes', label: 'Shoes'),
                          ],
                        ),
                        AdmCascaderOption(
                          value: 'women',
                          label: 'Women',
                          children: [
                            AdmCascaderOption(value: 'dresses', label: 'Dresses'),
                            AdmCascaderOption(value: 'tops', label: 'Tops'),
                            AdmCascaderOption(value: 'shoes_w', label: 'Shoes'),
                          ],
                        ),
                      ],
                    ),
                    AdmCascaderOption(
                      value: 'sports',
                      label: 'Sports',
                      children: [
                        AdmCascaderOption(
                          value: 'outdoor',
                          label: 'Outdoor',
                          children: [
                            AdmCascaderOption(value: 'camping', label: 'Camping'),
                            AdmCascaderOption(value: 'hiking', label: 'Hiking'),
                          ],
                        ),
                        AdmCascaderOption(
                          value: 'fitness',
                          label: 'Fitness',
                          children: [
                            AdmCascaderOption(value: 'gym', label: 'Gym'),
                            AdmCascaderOption(value: 'yoga', label: 'Yoga'),
                          ],
                        ),
                      ],
                    ),
                  ],
                  onConfirm: (values, items) {
                    setState(() {
                      _cascaderValues = values;
                      _cascaderLabels = items.map((e) => e.label).toList();
                    });
                  },
                );
                if (result != null && mounted) {
                  // result already handled in onConfirm
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spaceMd,
                  vertical: tokens.spaceMd,
                ),
                decoration: BoxDecoration(
                  color: tokens.colorBackground,
                  border: Border.all(color: tokens.colorBorder),
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _cascaderLabels.isEmpty
                            ? 'Select category...'
                            : _cascaderLabels.join(' / '),
                        style: TextStyle(
                          fontSize: tokens.fontSizeMd,
                          color: _cascaderLabels.isEmpty
                              ? tokens.colorTextPlaceholder
                              : tokens.colorTextBase,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_right,
                      size: 18,
                      color: tokens.colorTextTertiary,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: tokens.spaceLg),
            Row(children: [
              Expanded(
                child: AdmButton(
                  block: true,
                  onPressed: () => _formCtrl.resetFields(),
                  child: const Text('Reset'),
                ),
              ),
              SizedBox(width: tokens.spaceMd),
              Expanded(
                child: AdmButton.primary(
                  block: true,
                  onPressed: () {
                    if (_formCtrl.validate()) {
                      AdmToast.show(context, content: 'Submitted!', type: AdmToastType.success);
                    } else {
                      AdmToast.show(context, content: 'Please fix errors', type: AdmToastType.fail);
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ]),
            SizedBox(height: tokens.spaceXxl),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Feedback Page
// ─────────────────────────────────────────────────────────────────────────────

class _FeedbackPage extends StatelessWidget {
  const _FeedbackPage();

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Notice Bar'),
          const AdmNoticeBar(content: Text('System upgrade scheduled for tonight 10 PM.')),
          SizedBox(height: tokens.spaceSm),
          AdmNoticeBar(
            icon: Icon(AdmIcons.info, size: 16),
            content: const Text('Your verification is pending review.'),
            closeable: true,
            color: tokens.colorPrimary,
            background: tokens.colorPrimary.withOpacity(0.08),
          ),
          SizedBox(height: tokens.spaceSm),
          AdmNoticeBar(
            icon: Icon(AdmIcons.circle_alert, size: 16),
            content: const Text('Payment failed. Please update your card.'),
            closeable: true,
            color: tokens.colorDanger,
            background: tokens.colorDanger.withOpacity(0.08),
          ),
          SizedBox(height: tokens.spaceXl),
          const _SectionTitle('Toast'),
          AdmSpace(wrap: true, gap: tokens.spaceSm, children: [
            AdmButton(
              size: AdmButtonSize.small,
              onPressed: () => AdmToast.show(context, content: 'This is a toast!'),
              child: const Text('Info'),
            ),
            AdmButton(
              size: AdmButtonSize.small,
              color: AdmButtonColor.success,
              onPressed: () => AdmToast.show(context, content: 'Saved!', type: AdmToastType.success),
              child: const Text('Success'),
            ),
            AdmButton(
              size: AdmButtonSize.small,
              color: AdmButtonColor.danger,
              onPressed: () => AdmToast.show(context, content: 'Failed!', type: AdmToastType.fail),
              child: const Text('Fail'),
            ),
            AdmButton(
              size: AdmButtonSize.small,
              color: AdmButtonColor.warning,
              onPressed: () {
                AdmToast.show(context, content: 'Loading…', type: AdmToastType.loading);
                Future.delayed(const Duration(seconds: 2), () => AdmToast.hide(context));
              },
              child: const Text('Loading (2s)'),
            ),
          ]),
          SizedBox(height: tokens.spaceXl),
          const _SectionTitle('Modal / Dialog'),
          AdmSpace(wrap: true, gap: tokens.spaceSm, children: [
            AdmButton(
              size: AdmButtonSize.small,
              onPressed: () => AdmModal.alert(
                context,
                title: const Text('Alert'),
                content: const Text('This action cannot be undone.'),
                onConfirm: () {},
              ),
              child: const Text('Alert'),
            ),
            AdmButton(
              size: AdmButtonSize.small,
              color: AdmButtonColor.danger,
              onPressed: () async {
                final result = await AdmModal.confirm(
                  context,
                  title: const Text('Delete item?'),
                  content: const Text('This will permanently remove the item from your account.'),
                );
                if (result && context.mounted) {
                  AdmToast.show(context, content: 'Deleted!', type: AdmToastType.success);
                }
              },
              child: const Text('Confirm'),
            ),
          ]),
          SizedBox(height: tokens.spaceXl),
          const _SectionTitle('Action Sheet'),
          AdmButton(
            onPressed: () => AdmActionSheet.show(
              context,
              title: const Text('Select option'),
              actions: [
                AdmAction(
                  text: const Text('Share'),
                  onPress: () => AdmToast.show(context, content: 'Shared!'),
                ),
                AdmAction(
                  text: const Text('Save to Photos'),
                  onPress: () => AdmToast.show(context, content: 'Saved!'),
                ),
                AdmAction(
                  text: const Text('Copy Link'),
                  onPress: () => AdmToast.show(context, content: 'Copied!'),
                ),
                const AdmAction(
                  text: Text('Delete'),
                  danger: true,
                ),
              ],
            ),
            child: const Text('Show Action Sheet'),
          ),
          SizedBox(height: tokens.spaceXl),
          const _SectionTitle('Popup (Bottom Sheet)'),
          AdmButton(
            onPressed: () => AdmPopup.show(
              context,
              position: AdmPopupPosition.bottom,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AdmColors.grey3,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text('Bottom Popup', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    const Text('This is a custom popup content area.', textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: AdmButton.primary(
                        block: true,
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child: const Text('Show Bottom Popup'),
          ),
          SizedBox(height: tokens.spaceXl),
          const _SectionTitle('Loading'),
          AdmSpace(gap: tokens.spaceXl, children: [
            const AdmLoading(),
            AdmLoading(color: tokens.colorSuccess),
            AdmLoading(color: tokens.colorDanger, size: 40),
            AdmLoading.dots(color: tokens.colorPrimary),
          ]),
          SizedBox(height: tokens.spaceXl),
          const _SectionTitle('Collapse'),
          const AdmCollapse(
            accordion: true,
            panels: [
              AdmCollapsePanel(
                key: 'q1',
                title: Text('What is Ant Design Mobile?'),
                content: Text(
                    'Ant Design Mobile is an essential UI blocks library for building mobile web apps. It provides a complete suite of high-quality components.'),
              ),
              AdmCollapsePanel(
                key: 'q2',
                title: Text('Is there a Flutter version?'),
                content: Text(
                    'This package is the community Flutter port, providing the same design language with native performance.'),
              ),
              AdmCollapsePanel(
                key: 'q3',
                title: Text('How do I customize the theme?'),
                content: Text(
                    'Wrap your app in AdmTheme and pass a custom AdmThemeData with your own AdmTokens to override colors, spacing, fonts, etc.'),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceXxl),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile Page
// ─────────────────────────────────────────────────────────────────────────────

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero header
          Container(
            color: tokens.colorBackground,
            padding: EdgeInsets.all(tokens.spaceXl),
            child: Row(
              children: [
                AdmAvatar(
                  text: 'JD',
                  size: AdmAvatarSize.xl,
                  backgroundColor: tokens.colorPrimary,
                ),
                SizedBox(width: tokens.spaceLg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('John Doe',
                          style: TextStyle(
                              fontSize: tokens.fontSizeXxl,
                              fontWeight: tokens.fontWeightBold,
                              color: tokens.colorTextBase)),
                      SizedBox(height: tokens.spaceXs),
                      Text('john.doe@example.com',
                          style: TextStyle(fontSize: tokens.fontSizeSm, color: tokens.colorTextSecondary)),
                      SizedBox(height: tokens.spaceSm),
                      AdmSpace(gap: tokens.spaceXs, children: const [
                        AdmTag(color: AdmTagColor.primary, child: Text('Pro')),
                        AdmTag(color: AdmTagColor.success, child: Text('Verified')),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: tokens.spaceSm),

          // Stats
          Container(
            color: tokens.colorBackground,
            padding: EdgeInsets.symmetric(vertical: tokens.spaceLg),
            child: const AdmGrid(
              columns: 3,
              gap: 0,
              children: [
                _StatCell(value: '128', label: 'Orders'),
                _StatCell(value: '4.9★', label: 'Rating'),
                _StatCell(value: '\$2,450', label: 'Spent'),
              ],
            ),
          ),

          SizedBox(height: tokens.spaceSm),

          AdmList(
            header: const Text('Account'),
            children: [
              AdmListItem(
                prefix: Icon(AdmIcons.user, size: 20),
                title: const Text('Edit Profile'),
                arrow: true,
                onTap: () {},
              ),
              AdmListItem(
                prefix: Icon(AdmIcons.map_pin, size: 20),
                title: const Text('Saved Addresses'),
                extra: const Text('3'),
                arrow: true,
                onTap: () {},
              ),
              AdmListItem(
                prefix: Icon(AdmIcons.credit_card, size: 20),
                title: const Text('Payment Methods'),
                arrow: true,
                onTap: () {},
              ),
            ],
          ),

          SizedBox(height: tokens.spaceSm),

          AdmList(
            header: const Text('Preferences'),
            children: [
              AdmListItem(
                prefix: Icon(AdmIcons.bell, size: 20),
                title: const Text('Push Notifications'),
                extra: AdmSwitch(checked: true, onChange: (_) {}),
              ),
              AdmListItem(
                prefix: Icon(AdmIcons.globe, size: 20),
                title: const Text('Language'),
                extra: const Text('English'),
                arrow: true,
                onTap: () {},
              ),
              AdmListItem(
                prefix: Icon(AdmIcons.shield, size: 20),
                title: const Text('Privacy Settings'),
                arrow: true,
                onTap: () {},
              ),
            ],
          ),

          SizedBox(height: tokens.spaceSm),

          Padding(
            padding: EdgeInsets.all(tokens.spaceLg),
            child: AdmButton(
              block: true,
              color: AdmButtonColor.danger,
              fill: AdmButtonFill.outline,
              onPressed: () {},
              child: const Text('Sign Out'),
            ),
          ),

          SizedBox(height: tokens.spaceXxl),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;

  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: tokens.fontSizeXxl, fontWeight: tokens.fontWeightBold, color: tokens.colorTextBase)),
        SizedBox(height: tokens.spaceXs),
        Text(label, style: TextStyle(fontSize: tokens.fontSizeSm, color: tokens.colorTextTertiary)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spaceSm),
      child: Text(
        text,
        style: TextStyle(
          fontSize: tokens.fontSizeSm,
          fontWeight: tokens.fontWeightBold,
          color: tokens.colorTextTertiary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
