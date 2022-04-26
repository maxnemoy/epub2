import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:epub2/image.dart';
import 'package:epub2/sheet_view.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, SystemUiOverlayStyle;

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    _setSystemUIOverlayStyle();
  }

  Brightness get platformBrightness =>
      MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
          .platformBrightness;

  void _setSystemUIOverlayStyle() {
    if (platformBrightness == Brightness.light) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.grey[50],
        systemNavigationBarIconBrightness: Brightness.dark,
      ));
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.grey[850],
        systemNavigationBarIconBrightness: Brightness.light,
      ));
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Epub demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
        ),
        debugShowCheckedModeBanner: false,
        home: const MyHomePage(),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late EpubController _epubReaderController;
  late EpubController _notesReaderController;

  @override
  void initState() {
    _epubReaderController = EpubController(
      document: EpubDocument.openAsset('assets/example.epub'),
    );
    _notesReaderController = EpubController(
      document: EpubDocument.openAsset('assets/notes_example.epub'),
    );
    super.initState();
  }

  @override
  void dispose() {
    _epubReaderController.dispose();
    _notesReaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: EpubViewActualChapter(
            controller: _epubReaderController,
            builder: (chapterValue) => Text(
              chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ?? '',
              textAlign: TextAlign.start,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.save_alt),
              color: Colors.white,
              onPressed: () => _showCurrentEpubCfi(context),
            ),
          ],
        ),
        drawer: Drawer(
          child: EpubViewTableOfContents(controller: _epubReaderController),
        ),
        body: EpubView(
          onExternalLinkPressed: (link) async {
            var uri = Uri.parse(link);
            print(uri.path);
            print(uri.queryParameters["id"]);
            if (uri.origin == "http://epub.epub") {
              if (uri.path.split("/")[1] == "notes") {
                showFlexibleBottomSheet(
                  minHeight: 0,
                  initHeight: 0.5,
                  maxHeight: 1,
                  context: context,
                  bottomSheetColor: Colors.transparent,
                  builder: (context, controller, offset) => _buildBottomSheet(
                      context,
                      controller,
                      offset,
                      uri.queryParameters["id"] as String),
                  anchors: [0, 0.5, 1],
                  isSafeArea: true,
                );
              }
              if (uri.path.split("/")[1] == "images") {
                debugPrint(uri.path.substring(1));
                _epubReaderController.document.then((book) {
                  book.Content!.Images!.forEach((key, value) {
                    if (key == uri.path.substring(1)) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              ImageViewer(bytes: value.Content!)));
                    }
                  });
                });
              }
            }
          },
          builders: EpubViewBuilders<DefaultBuilderOptions>(
            options: const DefaultBuilderOptions(),
            chapterDividerBuilder: (_) => const Divider(),
          ),
          controller: _epubReaderController,
        ),
      );

  void _showCurrentEpubCfi(context) {
    final cfi = _epubReaderController.generateEpubCfi();

    if (cfi != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cfi),
          action: SnackBarAction(
            label: 'GO',
            onPressed: () {
              _epubReaderController.gotoEpubCfi(cfi);
            },
          ),
        ),
      );
    }
  }

  Widget _buildBottomSheet(BuildContext context,
      ScrollController scrollController, double bottomSheetOffset, String id) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      child: SheetView(
        paragraphId: id,
        controller: scrollController,
      ),
    );
  }
}
