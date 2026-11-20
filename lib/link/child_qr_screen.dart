import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../child.dart';
import '../parent/parent_store.dart';
import '../parent/parent_ui.dart';
import 'child_link.dart';
import 'link_api.dart';

/// The parent's side: shows the QR code the child scans on their own phone.
class ChildQrScreen extends StatefulWidget {
  const ChildQrScreen({super.key, required this.child});

  final ParentChild child;

  @override
  State<ChildQrScreen> createState() => _ChildQrScreenState();
}

class _ChildQrScreenState extends State<ChildQrScreen> {
  ChildLink? _link;
  ShortCode? _shortCode;
  bool _gettingCode = false;
  String? _codeError;

  String get _codeKey => 'mazid_child_unlock_${widget.child.id}';

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final child = widget.child;
    await ChildAppState.instance.switchChild(child.id);

    // The same code every time, so the parent can find it again later.
    final prefs = await SharedPreferences.getInstance();
    var code = prefs.getString(_codeKey);
    if (code == null || !RegExp(r'^\d{6}$').hasMatch(code)) {
      code = ChildLink.newUnlockCode();
      await prefs.setString(_codeKey, code);
    }

    if (!mounted) return;
    setState(() {
      _link = ChildLink(
        child: child,
        unlockCode: code!,
        data: ChildAppState.instance.linkData(),
      );
    });
  }

  Future<void> _getShortCode(String payload) async {
    setState(() {
      _gettingCode = true;
      _codeError = null;
    });
    try {
      final code = await const LinkApi().create(payload);
      if (mounted) setState(() => _shortCode = code);
    } on LinkException catch (e) {
      if (mounted) setState(() => _codeError = e.message);
    } finally {
      if (mounted) setState(() => _gettingCode = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final link = _link;
    final text = link?.encode();

    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, '${widget.child.name}\'s phone'),
      body: SafeArea(
        child: link == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                children: [
                  const Text(
                    'On the child\'s phone, open MAZID and choose '
                    '"I am a child", then scan this code.',
                    style: TextStyle(color: ParentUi.muted, height: 1.45),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: QrImageView(
                        data: text!,
                        size: 260,
                        errorCorrectionLevel: QrErrorCorrectLevel.L,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ParentCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Parent code',
                          style: TextStyle(
                            color: ParentUi.dark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          link.unlockCode,
                          style: const TextStyle(
                            color: ParentUi.purple,
                            fontSize: 28,
                            letterSpacing: 6,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'You need it to take the child\'s phone out of '
                          'child mode. Keep it to yourself.',
                          style: TextStyle(color: ParentUi.muted, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const ParentCard(
                    child: Text(
                      'This copies the tasks and rewards as they are now. '
                      'Anything you add later needs a new scan until the '
                      'online sync is built.',
                      style: TextStyle(color: ParentUi.muted, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ParentCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'No camera? Use a short code',
                          style: TextStyle(
                            color: ParentUi.dark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (_shortCode == null) ...[
                          const Text(
                            'The child types it on their phone. It works '
                            'once and lasts 10 minutes. Both phones need '
                            'the internet.',
                            style: TextStyle(
                              color: ParentUi.muted,
                              height: 1.4,
                            ),
                          ),
                          if (_codeError != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              _codeError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                          const SizedBox(height: 10),
                          FilledButton(
                            onPressed: _gettingCode
                                ? null
                                : () => _getShortCode(text),
                            style: FilledButton.styleFrom(
                              backgroundColor: ParentUi.purple,
                              minimumSize: const Size.fromHeight(46),
                            ),
                            child: Text(
                              _gettingCode ? 'Please wait...' : 'Get a code',
                            ),
                          ),
                        ] else ...[
                          Text(
                            _shortCode!.pretty,
                            style: const TextStyle(
                              color: ParentUi.purple,
                              fontSize: 30,
                              letterSpacing: 4,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Valid for ${_shortCode!.lifetime.inMinutes} '
                            'minutes, one use.',
                            style: const TextStyle(color: ParentUi.muted),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: text));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code copied.')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ParentUi.purple,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Copy the code as text'),
                  ),
                ],
              ),
      ),
    );
  }
}
