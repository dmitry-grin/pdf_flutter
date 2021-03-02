import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfium/flutter_pdfium.dart';

typedef load_document_func = Handle Function(
    Pointer<Void> dataBuffer, int size);
typedef LoadPDF = Handle Function(Pointer<Void> dataBuffer, int size);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  loadDylib('libpdfsdk.so');
  initLibrary();

  final filename = 'prog_book.pdf';
  var bytes = await rootBundle.load("assets/prog_book.pdf");
  String dir = (await getApplicationDocumentsDirectory()).path;

  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  await writeToFile(bytes, '$dir/$filename');

  runApp(
    PDFViewerApp(filePath: '$dir/$filename'),
  );
}

class PDFViewerApp extends StatefulWidget {
  final String filePath;

  const PDFViewerApp({Key key, @required this.filePath}) : super(key: key);

  @override
  _PDFViewerAppState createState() => _PDFViewerAppState();
}

class _PDFViewerAppState extends State<PDFViewerApp> {
  bool isLoaded = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: PdfView(widget.filePath),
      ),
    );
  }
}

class PdfPainter extends CustomPainter {
  final ui.Image image;

  PdfPainter(this.image);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    // canvas.drawCircle(Offset.zero, 20.0, Paint());
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(PdfPainter oldDelegate) {
    return oldDelegate.image != image;
  }
}

class PdfView extends StatefulWidget {
  final String filePath;

  PdfView(this.filePath);

  @override
  _PdfViewState createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  int _currentPage = 0;
  int _totalPages;

  Future<void> buildImage() {
    final c = Completer<ui.Image>();

    int width;
    int height;
    Pointer<FPDF_PAGE> page;
    Pointer<FPDF_DOCUMENT> doc;
    Pointer<FPDF_BITMAP> bitmap;
    Uint8List buf;
    int ppi = 100;

    assert(widget.filePath != null);

    doc = loadDocument(widget.filePath);
    page = fLoadPage(doc, _currentPage);
    _totalPages = fGetPageCount(doc);

    width = fGetPageWidth(page).toInt();
    height = fGetPageHeight(page).toInt();
    width = pointsToPixels(width, ppi).toInt();
    height = pointsToPixels(height, ppi).toInt();

    bitmap = fBitmapCreate(width, height, 1);
    fBitmapFillRect(bitmap, 0, 0, width, height, 0);
    fRenderPageBitmap(bitmap, page, 0, 0, width, height, 0, 0);

    buf = fBitmapGetBuffer(bitmap)
        .asTypedList(width * height)
        .buffer
        .asUint8List();

    ui.decodeImageFromPixels(
      buf,
      width,
      height,
      ui.PixelFormat.rgba8888,
      c.complete,
    );

    fCloseDocument(doc);

    return c.future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: buildImage(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 2.0,
                  child: RawImage(
                    image: snapshot.data,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: PageControl(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  onTapForward: onTapForward,
                  onTapBack: onTapBack,
                ),
              )
            ],
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void onTapForward() {
    _currentPage += 1;
    setState(() {});
  }

  void onTapBack() {
    _currentPage -= 1;
    setState(() {});
  }
}

class PageControl extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onTapBack;
  final VoidCallback onTapForward;

  const PageControl(
      {Key key,
        this.currentPage,
        this.totalPages,
        this.onTapBack,
        this.onTapForward})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          child: Text('$currentPage of $totalPages'),
        ),
        IconButton(icon: Icon(Icons.arrow_upward), onPressed: onTapForward),
        IconButton(icon: Icon(Icons.arrow_downward), onPressed: onTapBack),
      ],
    );
  }
}
