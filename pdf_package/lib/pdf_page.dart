import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:pdf_package/signature_page.dart';
import 'package:printing/printing.dart';

class PDFPage extends StatefulWidget {
  final InvoiceItem invoice;

  const PDFPage({Key key, this.invoice}) : super(key: key);

  @override
  _PDFPageState createState() => _PDFPageState();
}

class _PDFPageState extends State<PDFPage> {
  Uint8List signature;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () async {
              final Uint8List result = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SignaturePage()));
              if (result != null) {
                signature = result;
                setState(() {});
              }
            },
            child: Text(
              'Add signature',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: PdfPreview(
        pdfFileName: 'Delivery_invoice_${widget.invoice.invoiceNumber}.pdf',
        build: (format) => _generatePdf(format),
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    double grandTotal = 0;

    widget.invoice.deliveryItems.forEach((element) {
      grandTotal += element.total;
    });

    final pdf = pw.Document();

    const tableHeaders = ['Delivery item name', 'Quantity', 'Price', 'Total'];

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Column(
            children: [
              pw.Text(
                'Invoice #${widget.invoice.invoiceNumber}',
                style:
                    pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 30),
              pw.Align(
                alignment: pw.Alignment.topRight,
                child: pw.Text('Recipient: ${widget.invoice.clientName}'),
              ),
              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.topRight,
                child: pw.Text('Delivered to: ${widget.invoice.address}'),
              ),
              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.topRight,
                child: pw.Text('Date: Wednesday, March 3rd, 2020'),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 2, color: PdfColors.black),
              pw.SizedBox(height: 30),
              pw.Table.fromTextArray(
                  cellAlignment: pw.Alignment.centerLeft,
                  headerDecoration: pw.BoxDecoration(
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(2)),
                  ),
                  headerHeight: 25,
                  cellHeight: 40,
                  headers: List<String>.generate(
                    tableHeaders.length,
                    (col) => tableHeaders[col],
                  ),
                  data: List<List<String>>.generate(
                    widget.invoice.deliveryItems.length,
                    (row) => List<String>.generate(
                        tableHeaders.length,
                        (col) =>
                            widget.invoice.deliveryItems[row].getIndex(col)),
                  )),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Text(
                  'Grand total: $grandTotal \$',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                pw.Text('Signature:'),
                pw.SizedBox(width: 20),
                if (signature == null) ...[pw.Text('____________')],
                if (signature != null) ...[
                  pw.Container(
                    height: 80,
                    width: 80,
                    child: pw.Image(pw.MemoryImage(signature),
                        fit: pw.BoxFit.cover),
                  ),
                ]
              ]),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}

class InvoiceItem {
  final String invoiceNumber;
  final String clientName;
  final String address;
  final List<DeliveryItem> deliveryItems;

  InvoiceItem(
      {this.invoiceNumber, this.clientName, this.address, this.deliveryItems});
}

class DeliveryItem {
  String productName;
  int count = 1;
  double price;

  double get total => count * price;

  String getIndex(int index) {
    switch (index) {
      case 0:
        return productName;
      case 1:
        return count.toString();
      case 2:
        return price.toString();
      case 3:
        return total.toString();
    }
    return '';
  }
}
