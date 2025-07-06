// lib/markdown_viewer_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // Required for loading assets
import 'package:flutter_markdown/flutter_markdown.dart'; // Required for Markdown rendering

class MarkdownViewerPage extends StatefulWidget {
  final String markdownAssetPath;
  final String pageTitle;

  const MarkdownViewerPage({
    super.key,
    required this.markdownAssetPath,
    required this.pageTitle,
  });

  @override
  State<MarkdownViewerPage> createState() => _MarkdownViewerPageState();
}

class _MarkdownViewerPageState extends State<MarkdownViewerPage> {
  String _markdownContent = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMarkdownAsset();
  }

  Future<void> _loadMarkdownAsset() async {
    try {
      // Load the markdown file from assets
      final String content = await rootBundle.loadString(widget.markdownAssetPath);
      if (mounted) { // Guard with mounted check
        setState(() {
          _markdownContent = content;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) { // Guard with mounted check
        setState(() {
          _error = 'Failed to load document: $e';
          _isLoading = false;
        });
      }
      // print('Error loading markdown asset: $e'); // Avoid print
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pageTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _error!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Markdown(
                  data: _markdownContent,
                  padding: const EdgeInsets.all(16.0),
                  styleSheet: MarkdownStyleSheet(
                    // Customizing Markdown styles to match the dark theme
                    p: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                    h1: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white),
                    h2: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                    h3: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                    strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    em: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70),
                    listBullet: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                    blockquote: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white54,
                          fontStyle: FontStyle.italic,
                          decorationColor: Colors.white38,
                        ),
                    code: const TextStyle(
                      backgroundColor: Colors.grey, // Dark background for code blocks
                      color: Colors.black,
                      fontFamily: 'monospace',
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.white12),
                    ),
                  ),
                ),
    );
  }
}