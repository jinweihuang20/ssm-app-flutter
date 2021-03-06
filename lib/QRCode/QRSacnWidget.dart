import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';

class QRScanner extends StatefulWidget {
  const QRScanner({Key? key, required this.ssmMoudleQRCodeOnCapature}) : super(key: key);
  final Function(String) ssmMoudleQRCodeOnCapature;
  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  QRViewController? controller;
  Barcode? result;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('掃描QR代碼'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(children: [
              _buildQrView(context),
              const Padding(
                padding: EdgeInsets.only(top: 58.0, left: 60),
                child: Text('請掃描貼於控制器上方的QR CODE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400) ? 150.0 : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(borderColor: Color.fromARGB(255, 23, 52, 218), borderRadius: 10, borderLength: 30, borderWidth: 10, cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        String str = result?.code as String;
        if (isSSMModuleQRCode(str)) {
          controller.pauseCamera();
          Navigator.pop(context, str);
        }
      });
    });
  }

  bool isSSMModuleQRCode(String code) {
    //gpm-ssm-module:AXM23001:192.168.0.3
    if (code.contains('gpm-ssm-module')) {
      return true;
    } else {
      return false;
    }
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    print('QR Scanner Disposed');
    super.dispose();
  }
}
