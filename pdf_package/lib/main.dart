import 'package:flutter/material.dart';
import 'package:pdf_package/pdf_page.dart';

void main() {
  runApp(PdfGenerationApp());
}

class PdfGenerationApp extends StatefulWidget {
  @override
  _PdfGenerationAppState createState() => _PdfGenerationAppState();
}

class _PdfGenerationAppState extends State<PdfGenerationApp> {
  List<DeliveryItem> deliveryItems = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Invoice'),
        ),
        body: CreatePdfForm(itemsToDeliver: deliveryItems),
        floatingActionButton: Builder(builder: (BuildContext context) {
          return FloatingActionButton(
            child: Icon(Icons.add_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  var item = DeliveryItem();

                  return AlertDialog(
                    content: StatefulBuilder(
                      // You need this, notice the parameters below:
                      builder: (BuildContext context, StateSetter setState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            buildTextForm('Item name', (String input) {
                              item.productName = input;
                            }),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: buildTextForm(
                                    'Price',
                                    (String input) {
                                      item.price = double.parse(input);
                                    },
                                    keyboard: TextInputType.number,
                                  ),
                                ),
                                SizedBox(width: 20),
                                Row(
                                  children: [
                                    IconButton(
                                        icon: Icon(Icons.remove),
                                        onPressed: () {
                                          if (item.count > 1) {
                                            setState(() {
                                              item.count--;
                                            });
                                          }
                                        }),
                                    Text('${item.count}'),
                                    IconButton(
                                      icon: Icon(Icons.add_rounded),
                                      onPressed: () {
                                        setState(
                                          () {
                                            item.count++;
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(height: 30),
                            RaisedButton(
                                child: Text('Add'),
                                onPressed: () {
                                  onAdd(item);
                                  Navigator.of(context).pop();
                                })
                          ],
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        }),
      ),
    );
  }

  onAdd(DeliveryItem item) {
    deliveryItems.add(item);
    setState(() {});
  }
}

class CreatePdfForm extends StatefulWidget {
  final List<DeliveryItem> itemsToDeliver;

  CreatePdfForm({Key key, this.itemsToDeliver}) : super(key: key);

  @override
  _CreatePdfFormState createState() => _CreatePdfFormState();
}

class _CreatePdfFormState extends State<CreatePdfForm> {
  String invoiceNumber;
  String clientName;
  String address;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          children: [
            SizedBox(height: 20),
            buildTextForm('Invoice number', (String input) {
              setState(() => invoiceNumber = input);
            }),
            SizedBox(height: 20),
            buildTextForm('Client name', (String input) {
              setState(() => clientName = input);
            }),
            SizedBox(height: 20),
            buildTextForm('Address', (String input) {
              setState(() => address = input);
            }),
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Text('Delivery items',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            for (DeliveryItem item in widget.itemsToDeliver) buildTile(item),
            if (widget.itemsToDeliver.isEmpty) ...[
              SizedBox(height: 50),
              Center(child: Text('No items to deliver'))
            ]
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              onPressed: canCreateInvoice()
                  ? () {
                      final invoice = InvoiceItem(
                          invoiceNumber: invoiceNumber,
                          clientName: clientName,
                          address: address,
                          deliveryItems: widget.itemsToDeliver);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PDFPage(
                            invoice: invoice,
                          ),
                        ),
                      );
                    }
                  : null,
              child: Text('Generate'),
            ),
          ),
        )
      ],
    );
  }

  Widget buildTile(DeliveryItem item) {
    final total = item.price * item.count;

    return ListTile(
      title: Text(item.productName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Quantity: ${item.count}'),
          SizedBox(width: 20),
          Text('Price: ${item.price} \$'),
          SizedBox(width: 20),
          Text('Total: $total \$')
        ],
      ),
    );
  }

  bool canCreateInvoice() {
    if (widget.itemsToDeliver.isNotEmpty &&
        invoiceNumber != null &&
        clientName != null &&
        address != null) {
      return true;
    }

    return false;
  }
}

Widget buildTextForm(String hint, Function(String) onChanged,
    {TextInputType keyboard = TextInputType.text}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15.0),
    child: TextFormField(
      keyboardType: keyboard,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
      ),
    ),
  );
}
