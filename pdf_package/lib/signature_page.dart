import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignaturePage extends StatefulWidget {
  @override
  _SignaturePageState createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signature'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: () {
            _controller.clear();
          }),
          IconButton(icon: Icon(Icons.save), onPressed: () async {
            final Uint8List img = await _controller.toPngBytes();
            Navigator.pop(context, img);
          }),
        ],
      ),
      body: Signature(
        height: 300,
        width: 300,
        controller: _controller,
        backgroundColor: Colors.grey[200],
      ),
    );
  }
}


