import 'dart:typed_data';
// ignore: implementation_imports
import 'package:epub_view/src/data/models/paragraph.dart';
import 'package:epub_view/epub_view.dart' hide Image;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

Widget customChapterBuilder(
    BuildContext context,
    EpubViewBuilders builders,
    EpubBook document,
    List<EpubChapter> chapters,
    List<Paragraph> paragraphs,
    int index,
    int chapterIndex,
    int paragraphIndex,
    ExternalLinkPressed onExternalLinkPressed,
    String paragraphId) {
  if (paragraphs.isEmpty) {
    return Container();
  }

  final defaultBuilder = builders as EpubViewBuilders<DefaultBuilderOptions>;
  final options = defaultBuilder.options;

  // ignore others elements
  if (paragraphs[index].element.parent?.id != paragraphId) {
    return Container();
  }

  //ignore headers
  if (paragraphs[index].element.outerHtml.contains("h2 ")) {
    return Container();
  }

  return Column(
    children: <Widget>[
      if (chapterIndex >= 0 && paragraphIndex == 0)
        builders.chapterDividerBuilder(chapters[chapterIndex]),
      Html(
        data: paragraphs[index].element.outerHtml,
        onLinkTap: (href, _, __, ___) => onExternalLinkPressed(href!),
        style: {
          'html': Style(
            padding: options.paragraphPadding as EdgeInsets?,
          ).merge(Style.fromTextStyle(options.textStyle)),
        },
        customRenders: {
          tagMatcher('img'):
              CustomRender.widget(widget: (context, buildChildren) {
            final url =
                context.tree.element!.attributes['src']!.replaceAll('../', '');
            return Image(
              image: MemoryImage(
                Uint8List.fromList(
                  document.Content!.Images![url]!.Content!,
                ),
              ),
            );
          }),
        },
      ),
    ],
  );
}
