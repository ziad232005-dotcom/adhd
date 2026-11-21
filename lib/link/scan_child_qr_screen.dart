import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../child.dart';
import '../parent/parent_store.dart';
import 'child_device.dart';
import 'child_link.dart';
import '../core/api_client.dart';
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
  final _codeController = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// A short code is swapped for the data on the server; a long offline
  /// code already carries it.
  Future<void> _useTypedCode() async {
    final text = _codeController.text.trim();
    if (text.isEmpty) return;
    if (text.startsWith('mazid1.')) {
      await _accept(text);
    } else {
      await _useShortCode(text);
    }
  }

  Future<void> _useShortCode(String text) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final payload = await const LinkApi().claim(text);
      if (!mounted) return;
      setState(() => _busy = false);
      await _accept(payload);
    } on ApiException catch (e) {
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
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Or type the code (ABCD-EFGH)',
                      suffixIcon: IconButton(
                        onPressed: _useTypedCode,
                        icon: const Icon(Icons.check_rounded),
                      ),
                    ),
                    onSubmitted: (_) => _useTypedCode(),
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
