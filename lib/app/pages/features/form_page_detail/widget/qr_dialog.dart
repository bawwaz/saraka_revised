import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:saraka_foto_box/app/pages/features/form_page_detail/form_page_detail_controller.dart';
import 'package:get/get.dart';

class ScanQRDialog extends StatefulWidget {
  const ScanQRDialog({Key? key}) : super(key: key);

  @override
  _ScanQRDialogState createState() => _ScanQRDialogState();
}

class _ScanQRDialogState extends State<ScanQRDialog> {
  final formDetailController = Get.put(FormPageDetailController());
  late MobileScannerController cameraController;
  double _currentZoom = 1.0;
  double _previousZoom = 1.0;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _focusAtPoint(Offset point) {
    print("Focusing at point: ${point.dx}, ${point.dy}");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Scan QR Code'),
      content: GestureDetector(
        onScaleStart: (details) {
          _previousZoom = _currentZoom;
        },
        onScaleUpdate: (details) {
          setState(() {
            _currentZoom = (_previousZoom * details.scale).clamp(1.0, 3.0);
          });
          cameraController.setZoomScale(_currentZoom);
        },
        onTapDown: (TapDownDetails details) {
          final renderBox = context.findRenderObject() as RenderBox;
          final localPosition = renderBox.globalToLocal(details.globalPosition);
          _focusAtPoint(localPosition);
        },
        child: SizedBox(
          width: 300,
          height: 300,
          child: MobileScanner(
            controller: cameraController,
            onDetect: (BarcodeCapture barcodeCapture) {
              if (barcodeCapture.barcodes.isNotEmpty) {
                final qrResult = barcodeCapture.barcodes.first.rawValue ?? '';
                formDetailController.scannedQR.value = qrResult;
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
          onPressed: () {
            setState(() {
              _torchOn = !_torchOn;
            });
            cameraController.toggleTorch();
          },
        ),
      ],
    );
  }
}

Future<void> showScanQRDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => const ScanQRDialog(),
  );
}
