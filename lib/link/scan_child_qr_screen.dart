import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../child.dart';
import '../parent/parent_store.dart';
import 'child_device.dart';
import 'child_link.dart';
import 'link_api.dart';
import 'linked_child_home.dart';

/// The child's side: scans the parent's QR code and turns this phone into
/// the child's own, showing only the child's screen.
class ScanChildQrScreen extends StatefulWidget {
  const ScanChildQrScreen({super.key});

  @override
  State<ScanChildQrScreen> createState() => _ScanChildQrScreenState();
}

class _ScanChildQrScreenState extends State<ScanChildQrScreen> {
  final _shortController = TextEditingController();
  final _pasteController = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _shortController.dispose();
    _pasteController.dispose();
    super.dispose();
  }

  Future<void> _useShortCode() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final payload = await const LinkApi().claim(_shortController.text);
      if (!mounted) return;
      setState(() => _busy = false);
      await _accept(payload);
    } on LinkException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.message;
        });
      }
    }
  }

  Future<void> _accept(String text) async {
    if (_busy) return;

    final link = ChildLink.decode(text);
    if (link == null) {
      setState(() => _error = 'This is not a MAZID child code.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    final child = link.child;
    ParentStore.instance.adoptLinkedChild(child);
    await ChildAppState.instance.importLinkData(child.id, link.data);
    await ChildDevice.instance.link(child.id, link.unlockCode);

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LinkedChildHome(child: child)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan your code')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: MobileScanner(
                onDetect: (capture) {
                  for (final barcode in capture.barcodes) {
                    final value = barcode.rawValue;
                    if (value != null) {
                      _accept(value);
                      return;
                    }
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Ask your parent to show the code on their phone.',
                    textAlign: TextAlign.center,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextField(
                    controller: _shortController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Or type the short code (ABCD-EFGH)',
                      suffixIcon: IconButton(
                        onPressed: _useShortCode,
                        icon: const Icon(Icons.check_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _pasteController,
                    decoration: InputDecoration(
                      hintText: 'Or paste the code as text',
                      suffixIcon: IconButton(
                        onPressed: () => _accept(_pasteController.text),
                        icon: const Icon(Icons.check_rounded),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
