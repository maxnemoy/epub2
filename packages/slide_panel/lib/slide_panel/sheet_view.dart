import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:slide_panel/slide_panel/controller_provider.dart';
import 'package:slide_panel/slide_panel/custom_chapter_builder.dart';

class SheetView extends StatefulWidget {
  SheetView(
      {Key? key,
      required this.title,
      required this.body,
      required this.paragraphId,
      this.backgroundColor = Colors.white,
      this.accentColor = Colors.orange,
      TextStyle? titleTextStyle})
      : titleTextStyle = titleTextStyle ??
            TextStyle(
                fontSize: 18, fontStyle: FontStyle.italic, color: accentColor),
        super(key: key);

  final String title;
  final Widget body;
  final Color backgroundColor;
  final Color accentColor;
  final TextStyle titleTextStyle;
  final String paragraphId;

  @override
  State<SheetView> createState() => _SheetViewState();
}

class _SheetViewState extends State<SheetView> {
  late EpubController _notesReaderController;

  @override
  void initState() {
    _notesReaderController = EpubController(
      document: EpubDocument.openAsset('assets/notes_example.epub'),
    );
    super.initState();
  }

  @override
  void dispose() {
    _notesReaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: const BorderRadius.all(Radius.circular(2))),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 25, left: 25, bottom: 20),
            child: Text(
              widget.title,
              style: widget.titleTextStyle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Container(
              color: widget.accentColor,
              height: 2,
              width: double.infinity,
            ),
          ),
          SizedBox(
            height: 300,
            child: Container(
              width: double.infinity,
              color: widget.accentColor.withOpacity(0.05),
              padding: const EdgeInsets.only(left: 25, right: 20, bottom: 20),
              child: EpubView(
                builders: EpubViewBuilders<DefaultBuilderOptions>(
                  options: const DefaultBuilderOptions(),
                  chapterDividerBuilder: (_) => const Divider(),
                  chapterBuilder: (context,
                          builders,
                          document,
                          chapters,
                          paragraphs,
                          index,
                          chapterIndex,
                          paragraphIndex,
                          onExternalLinkPressed) =>
                      customChapterBuilder(
                          context,
                          builders,
                          document,
                          chapters,
                          paragraphs,
                          index,
                          chapterIndex,
                          paragraphIndex,
                          onExternalLinkPressed,
                          widget.paragraphId),
                ),
                controller: _notesReaderController,
              ),
            ),
          )
          // Expanded(
          //   child: Padding(
          //       padding: const EdgeInsets.only(bottom: 5, left: 25),
          //       child: SingleChildScrollView(
          //           controller: ControllerProvider.of(context).controller,
          //           child: Container(
          //             width: double.infinity,
          //              color: widget.accentColor.withOpacity(0.05),
          //             padding: const EdgeInsets.only(
          //                 left: 25, right: 20, bottom: 20),
          //             child:
          //           ))),
          // ),
        ],
      ),
    );
  }
}
