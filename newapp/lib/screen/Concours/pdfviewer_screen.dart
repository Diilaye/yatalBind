import '/utils/colors.dart' as color;
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PDFViewerWidget extends StatefulWidget {
  final String filePath;

  const PDFViewerWidget({super.key, required this.filePath});

  @override
  // ignore: library_private_types_in_public_api
  _PDFViewerWidgetState createState() => _PDFViewerWidgetState();
}

class _PDFViewerWidgetState extends State<PDFViewerWidget> {
  late PdfControllerPinch _pdfController;
  int totalPageCount = 0, currentPage = 1;
  @override
  void initState() {
    super.initState();
    // Initialiser le contrôleur avec le fichier PDF à partir du chemin
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset(widget.filePath),
    );
  }

  @override
  void dispose() {
    // Nettoyer le contrôleur
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color.AppColor.yAccentColor,
        title: Text(
          'LECTURE PDF',
          style: TextStyle(
              color: color.AppColor.yDarkColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildUi(),
    );
  }

  Widget _buildUi() {
    return Column(children: [
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Total Pages: ${totalPageCount}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color.AppColor.yDarkColor,
            ),
          ),
          IconButton(
            onPressed: () {
              _pdfController.previousPage(
                  duration: Duration(milliseconds: 200), curve: Curves.linear);
            },
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: color.AppColor.yDarkColor,
            ),
          ),
          Text("Page: ${currentPage}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color.AppColor.yDarkColor,
              )),
          IconButton(
            onPressed: () {
              _pdfController.nextPage(
                  duration: Duration(milliseconds: 200), curve: Curves.linear);
            },
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: color.AppColor.yDarkColor,
            ),
          )
        ],
      ),
      _pdfView(),
    ]);
  }

  Widget _pdfView() {
    return Expanded(
      child: PdfViewPinch(
        scrollDirection: Axis.vertical,
        controller: _pdfController,
        onDocumentLoaded: (document) {
          setState(() {
            totalPageCount = document.pagesCount;
          });
        },
        onPageChanged: (page) {
          setState(() {
            currentPage = page;
          });
        },
      ),
    );
  }
}
