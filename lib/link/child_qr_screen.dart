import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../child.dart';
import '../parent/parent_store.dart';
import '../parent/parent_ui.dart';
import 'child_link.dart';
import '../core/api_client.dart';
import '../sync/result_sync.dart';
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

    final syncKey = await SyncKeys.forChild(child.id);

    if (!mounted) return;
    final link = ChildLink(
      child: child,
      unlockCode: code,
      data: ChildAppState.instance.linkData(),
      syncKey: syncKey,
    );
    setState(() => _link = link);
    _getShortCode(link.encode());
  }

  Future<void> _copy(String text, String done) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done)));
  }

  Future<void> _getShortCode(String payload) async {
    setState(() {
      _gettingCode = true;
      _codeError = null;
    });
    try {
      final code = await const LinkApi().create(payload);
      if (mounted) setState(() => _shortCode = code);
    } on ApiException catch (e) {
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
                    'On the child\'s phone choose "I am a child", then scan '
                    'the QR or type the code.',
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
                          'Code to type',
                          style: TextStyle(
                            color: ParentUi.dark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (_shortCode != null) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _shortCode!.pretty,
                                  style: const TextStyle(
                                    color: ParentUi.purple,
                                    fontSize: 30,
                                    letterSpacing: 4,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Copy',
                                onPressed: () => _copy(
                                  _shortCode!.pretty,
                                  'Code copied.',
                                ),
                                icon: const Icon(Icons.copy_rounded),
                              ),
                            ],
                          ),
                          Text(
                            'One use, valid for '
                            '${_shortCode!.lifetime.inMinutes} minutes.',
                            style: const TextStyle(color: ParentUi.muted),
                          ),
                        ] else if (_gettingCode) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: LinearProgressIndicator(),
                          ),
                        ] else ...[
                          Text(
                            _codeError ?? 'No code yet.',
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: () => _getShortCode(text),
                                child: const Text('Try again'),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () => _copy(
                                  text,
                                  'Offline code copied.',
                                ),
                                child: const Text('Copy offline code'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
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
                          'Needed to leave child mode on that phone.',
                          style: TextStyle(color: ParentUi.muted),
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
