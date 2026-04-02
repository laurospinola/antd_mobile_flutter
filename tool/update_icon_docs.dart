// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// Downloads each lucide SVG and replaces `/// ![](url)` doc comments with
/// an inline base64 data URI: `/// ![clear](data:image/svg+xml;base64,...)`.
///
/// Run from the project root:
///   dart tool/update_icon_docs.dart
void main() async {
  final file = File('lib/src/theme/adm_icons.dart');
  if (!file.existsSync()) {
    print('ERROR: lib/src/theme/adm_icons.dart not found. Run from project root.');
    exit(1);
  }

  print('Reading adm_icons.dart...');
  final content = await file.readAsString();

  final urlPattern = RegExp(
    r'/// !\[\]\((https://raw\.githubusercontent\.com/[^)]+)\)',
  );
  final matches = urlPattern.allMatches(content).toList();
  print('Found ${matches.length} icon URLs to process.');

  // Download SVGs concurrently in batches to avoid hammering GitHub.
  const batchSize = 30;
  final replacements = <String, String>{}; // url -> base64 string

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);

  for (var i = 0; i < matches.length; i += batchSize) {
    final batch = matches.skip(i).take(batchSize).toList();

    await Future.wait(batch.map((match) async {
      final url = match.group(1)!;
      if (replacements.containsKey(url)) return; // already downloaded
      final svg = await _downloadSvg(client, url);
      if (svg != null) {
        replacements[url] = base64Encode(utf8.encode(svg));
      }
    }));

    final done = (i + batchSize).clamp(0, matches.length);
    print('  Progress: $done / ${matches.length}');

    if (i + batchSize < matches.length) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  client.close();

  final failCount = matches.length - replacements.length;
  if (failCount > 0) {
    print('WARNING: $failCount URLs could not be downloaded — they will keep the original format.');
  }

  print('Updating documentation comments...');
  final newContent = content.replaceAllMapped(urlPattern, (match) {
    final url = match.group(1)!;
    final b64 = replacements[url];
    if (b64 == null) return match.group(0)!;
    return '/// ![clear](data:image/svg+xml;base64,$b64)';
  });

  await file.writeAsString(newContent);

  print('Done. Updated ${replacements.length} icons.');
}

Future<String?> _downloadSvg(HttpClient client, String url) async {
  try {
    final uri = Uri.parse(url);
    final request = await client.getUrl(uri);
    request.headers.set(HttpHeaders.userAgentHeader, 'DartIconDocUpdater/1.0');
    final response = await request.close();

    if (response.statusCode == 200) {
      final bytes = await response.expand((c) => c).toList();
      return utf8.decode(bytes);
    }
    print('  HTTP ${response.statusCode} for $url');
    return null;
  } catch (e) {
    print('  Error fetching $url: $e');
    return null;
  }
}
