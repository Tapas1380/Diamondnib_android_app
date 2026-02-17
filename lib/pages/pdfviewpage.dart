import 'package:diamondnib/provider/novelsectiondataprovider.dart';
import 'package:diamondnib/utils/color.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/widget/mytext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewPage extends StatefulWidget {
  final String? pdfLink, title;
  final dynamic novelChapterID, contentID;
  const PdfViewPage(
      {super.key,
      required this.pdfLink,
      required this.title,
      required this.contentID,
      required this.novelChapterID});

  @override
  State<PdfViewPage> createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  late NovelSectionDataProvider novelpovider;
  late PdfViewerController _pdfViewerController;
  @override
  void initState() {
    printLog("widget.pdfLink == ${widget.pdfLink}");
    novelpovider =
        Provider.of<NovelSectionDataProvider>(context, listen: false);
    _pdfViewerController = PdfViewerController();
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    await novelpovider.getAddContentPlay(
        2, widget.novelChapterID.toString(), 0, widget.contentID.toString());

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorPrimary,
          leading: InkWell(
            onTap: () async {
              onBackPressed(false);
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Utils().backBtn(18, 18, 12),
            ),
          ),
          title: MyText(
            fontsizeWeb: 18,
            color: white,
            text: widget.title.toString(),
            fontsizeNormal: 18,
            fontweight: FontWeight.w600,
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.bookmark,
                color: white,
                semanticLabel: 'Bookmark',
              ),
              onPressed: () {
                _pdfViewerKey.currentState?.openBookmarkView();
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.first_page,
                color: white,
              ),
              onPressed: () {
                _pdfViewerController.firstPage();
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.last_page,
                color: white,
              ),
              onPressed: () {
                _pdfViewerController.lastPage();
              },
            ),
          ],
        ),
        body: SfPdfViewer.network(
          widget.pdfLink.toString(),
          controller: _pdfViewerController,
          key: _pdfViewerKey,
          onPageChanged: (details) {
            _pdfViewerController.pageNumber;
            printLog("Current Page nO -- ${_pdfViewerController.pageNumber}");
            printLog(
                "Current Page pageCount -- ${_pdfViewerController.pageCount}");
          },
        ),
      ),
    );
  }

  Future<void> onBackPressed(didPop) async {
    if (didPop) return;
    if (_pdfViewerController.pageNumber != _pdfViewerController.pageCount) {
      novelpovider.addToContinue(widget.contentID, 2,
          "${_pdfViewerController.pageNumber}", "${widget.novelChapterID}", 0);
      if (!context.mounted) return;
      if (kIsWeb) {
        if (context.canPop()) {
          context.pop();
        }
      } else {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    }
  }
}
