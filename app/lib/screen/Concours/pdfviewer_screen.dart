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
        title: Text('Visualiseur PDF'),
      ),
      body: PdfViewPinch(
        controller: _pdfController,
        onDocumentLoaded: (document) {
          print('Document chargé avec ${document.pagesCount} pages.');
        },
        onPageChanged: (page) {
          print('Page actuelle : ${page}');
        },
      ),
    );
  }
}
