import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/dart.dart';
import 'package:re_highlight/styles/atom-one-light.dart';
import 'package:split_view/split_view.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        home: Scaffold(body: HomePage()),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final _controller = CodeViewController('''
    // The "import" keyword is used to specify dependencies, in this case,
    // the built-in widgets that are added by initState below.
    import core.widgets;
    // The "widget" keyword is used to define a new widget constructor.
    // The "root" widget is specified as the one to render in the build
    // method below.
    widget root = Container(
      color: 0xFF002211,
      child: Center(
        child: Text(text: ["Hello, ", data.greet.name, "!"], textDirection: "ltr"),
      ),
    );
  ''');

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: _controller,
        builder: (context, child) => SplitView(
          viewMode: SplitViewMode.Horizontal,
          gripColor: Colors.transparent,
          indicator: const SplitIndicator(
            viewMode: SplitViewMode.Horizontal,
            color: Colors.grey,
          ),
          gripColorActive: Colors.transparent,
          activeIndicator: const SplitIndicator(
            viewMode: SplitViewMode.Horizontal,
            isActive: true,
            color: Colors.black,
          ),
          children: [
            CodeView(controller: _controller),
            Text(_controller.value),
          ],
        ),
      );
}

typedef CodeViewController = ValueNotifier<String>;

class CodeView extends StatefulWidget {
  const CodeView({
    required this.controller,
    super.key,
  });

  final CodeViewController controller;

  @override
  State<CodeView> createState() => _CodeViewState();
}

class _CodeViewState extends State<CodeView> {
  late final _controller =
      CodeLineEditingController.fromText(widget.controller.value);

  @override
  Widget build(BuildContext context) => CodeEditor(
        controller: _controller,
        onChanged: (value) => widget.controller.value =
            value.codeLines.asString(TextLineBreak.crlf),
        style: CodeEditorStyle(
          codeTheme: CodeHighlightTheme(
            languages: {'json': CodeHighlightThemeMode(mode: langDart)},
            theme: atomOneLightTheme,
          ),
        ),
        indicatorBuilder: (
          context,
          editingController,
          chunkController,
          notifier,
        ) =>
            DefaultCodeLineNumber(
          controller: editingController,
          notifier: notifier,
        ),
        scrollController: CodeScrollController(
          verticalScroller: ScrollController(),
          horizontalScroller: ScrollController(),
        ),
      );
}
