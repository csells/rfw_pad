import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/dart.dart';
import 'package:re_highlight/styles/atom-one-light.dart';
import 'package:rfw/formats.dart';
import 'package:rfw/rfw.dart';
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
            WidgetView(text: _controller.value),
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
            value.codeLines.asString(TextLineBreak.lf),
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

class WidgetView extends StatefulWidget {
  const WidgetView({
    required this.text,
    super.key,
  });

  final String text;

  @override
  State<WidgetView> createState() => _WidgetViewState();
}

class _WidgetViewState extends State<WidgetView> {
  final coreName = const LibraryName(<String>['core', 'widgets']);
  final mainName = const LibraryName(<String>['main']);
  final _runtime = Runtime();
  final _data = DynamicContent();
  late RemoteWidgetLibrary _remoteWidgets;

  @override
  void initState() {
    super.initState();

    _runtime.update(coreName, createCoreWidgets());
    _data.update('greet', <String, Object>{'name': 'World'});

    reset();
  }

  void reset() {
    debugPrint('reset called');
    _remoteWidgets = parseLibraryFile(widget.text);
    _runtime.update(mainName, _remoteWidgets);
  }

  @override
  void didUpdateWidget(covariant WidgetView oldWidget) {
    super.didUpdateWidget(oldWidget);
    reset();
  }

  @override
  Widget build(BuildContext context) => RemoteWidget(
        runtime: _runtime,
        data: _data,
        widget: FullyQualifiedWidgetName(mainName, 'root'),
        onEvent: (name, arguments) => debugPrint(
          'user triggered event "$name" with data: $arguments',
        ),
      );
}
