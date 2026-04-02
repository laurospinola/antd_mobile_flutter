import 'package:antd_mobile_flutter/antd_mobile_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IconsGalleryPage extends StatefulWidget {
  const IconsGalleryPage({super.key});

  @override
  State<IconsGalleryPage> createState() => _IconsGalleryPageState();
}

class _IconsGalleryPageState extends State<IconsGalleryPage> {
  List<String> _all = [];
  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    _loadIcons();
  }

  Future<void> _loadIcons() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final paths = manifest
        .listAssets()
        .where((p) => p.startsWith('assets/icons/') && p.endsWith('.svg'))
        .toList()
      ..sort();
    setState(() {
      _all = paths;
      _filtered = paths;
    });
  }

  String _nameFor(String path) => path
      .replaceFirst('assets/icons/', '')
      .replaceFirst('.svg', '')
      .replaceAll('-', '_');

  void _onSearch(String query) {
    final q = query.toLowerCase().replaceAll(' ', '_');
    setState(() {
      _filtered = q.isEmpty ? _all : _all.where((p) => _nameFor(p).contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
              tokens.spaceMd, tokens.spaceMd, tokens.spaceMd, tokens.spaceXs),
          child: AdmSearchBar(
            placeholder: 'Search ${_all.length} icons…',
            showCancelButton: false,
            onChanged: _onSearch,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: tokens.spaceMd, vertical: tokens.spaceXs),
          child: Text(
            '${_filtered.length} icons',
            style: TextStyle(
                fontSize: tokens.fontSizeSm, color: tokens.colorTextSecondary),
          ),
        ),
        Expanded(
          child: _all.isEmpty
              ? const Center(child: AdmLoading())
              : GridView.builder(
                  padding: EdgeInsets.all(tokens.spaceSm),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _filtered.length,
                  itemBuilder: (context, i) {
                    final path = _filtered[i];
                    final name = _nameFor(path);
                    return _IconCell(path: path, name: name);
                  },
                ),
        ),
      ],
    );
  }
}

class _IconCell extends StatelessWidget {
  final String path;
  final String name;

  const _IconCell({required this.path, required this.name});

  @override
  Widget build(BuildContext context) {
    final tokens = AdmTheme.tokensOf(context);

    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: 'AppSvgIcons.$name'));
        AdmToast.show(context, content: 'AppSvgIcons.$name');
      },
      child: Container(
        decoration: BoxDecoration(
          color: tokens.colorBackground,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.colorBorder),
        ),
        padding: EdgeInsets.all(tokens.spaceXs),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: tokens.spaceXs),
            Text(
              name,
              style: TextStyle(
                  fontSize: 9, color: tokens.colorTextSecondary),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
