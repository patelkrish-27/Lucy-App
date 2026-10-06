import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/lucy_service.dart';
import '../widgets/cute_graphics.dart';
import '../widgets/lucy_orb.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});
  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  bool notifications = true;
  bool haptics = true;
  bool folderOnSession = false;
  final _service = LucyService();
  LucyConnection? _connection;
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    _service.savedConnection().then((v) { if (mounted) setState(() => _connection = v); });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 34),
        children: [
          Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Config', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w800)),
              SizedBox(height: 4),
              Text('Connect Lucy to your computer', style: TextStyle(color: Color(0xFFB9AEC7))),
            ])),
            LucyMascot(size: 62, state: LucyMascotState.listening),
          ]),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF17131D),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFB879FF).withValues(alpha: .24)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(_connection == null ? Icons.link_off_rounded : Icons.check_circle_rounded,
                    color: _connection == null ? const Color(0xFF8E8796) : const Color(0xFF7DE2A8)),
                const SizedBox(width: 10),
                Text(_connection == null ? 'Not connected' : 'Connected',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
              ]),
              const SizedBox(height: 8),
              Text(_connection == null
                  ? 'Scan the QR code shown by Lucy Desktop. No IP address or token is needed.'
                  : 'Connected to ${_connection!.name}.',
                  style: const TextStyle(color: Color(0xFFB9AEC7))),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: FilledButton.icon(
                onPressed: _connecting ? null : () => _scan(context),
                icon: _connecting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.qr_code_scanner_rounded),
                label: Text(_connecting ? 'Connecting…' : 'Scan Lucy QR'),
              )),
            ]),
          ),
          const SizedBox(height: 28),
          _Group(title: 'Notifications', children: [
            _SwitchRow(title: 'Notifications', subtitle: 'Notify when Lucy needs attention', value: notifications, onChanged: (v) => setState(() => notifications = v)),
          ]),
          _Group(title: 'Appearance', children: [
            _ActionRow(icon: Icons.palette_outlined, title: 'Lucy theme', subtitle: 'Dark violet · plush mascot', onTap: () {}),
            _ActionRow(icon: Icons.animation_rounded, title: 'Mascot animation', subtitle: 'Smooth and interactive', onTap: () {}),
          ]),
          _Group(title: 'Sessions', children: [
            _SwitchRow(title: 'Select folder on new session', subtitle: 'Choose the working directory before starting', value: folderOnSession, onChanged: (v) => setState(() => folderOnSession = v)),
            _ActionRow(icon: Icons.devices_rounded, title: 'Connected computers', subtitle: '1 computer online', onTap: () {}),
          ]),
          _Group(title: 'Feedback', children: [
            _SwitchRow(title: 'Haptics', subtitle: 'Small feedback when Lucy reacts', value: haptics, onChanged: (v) => setState(() => haptics = v)),
          ]),
          _Group(title: 'About', children: [
            _ActionRow(icon: Icons.info_outline_rounded, title: 'Lucy', subtitle: 'Version 0.1.0 · No cloud by default', onTap: () {}),
          ]),
        ],
      ),
    );
  }

  Future<void> _scan(BuildContext context) async {
    setState(() => _connecting = true);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF15121B),
        child: SizedBox(
          height: 480,
          child: Column(children: [
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text('Scan Lucy Desktop', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
            ),
            Expanded(
              child: MobileScanner(
                onDetect: (capture) async {
                  if (capture.barcodes.isEmpty) return;
                  final raw = capture.barcodes.first.rawValue;
                  if (raw == null) return;
                  try {
                    final data = jsonDecode(raw);
                    if (data is! Map || data['lucy'] != 1) return;
                    Navigator.of(context).pop();
                    final connection = await _service.pairFromQr(raw);
                    if (mounted) {
                      setState(() => _connection = connection);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Connected to ${connection.name} ✓')),
                      );
                    }
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not connect: $e')),
                    );
                  } finally {
                    if (mounted) setState(() => _connecting = false);
                  }
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(14),
              child: Text('Point your camera at the QR code shown on Lucy.', textAlign: TextAlign.center),
            ),
          ]),
        ),
      ),
    );
    if (mounted) setState(() => _connecting = false);
  }
}

class _OrDivider extends StatelessWidget {
  @override Widget build(BuildContext context) => Row(children: [
    const Expanded(child: Divider()),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('or enter manually', style: TextStyle(color: Color(0xFF716A78), fontSize: 11))),
    const Expanded(child: Divider()),
  ]);
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});
  final String title; final List<Widget> children;
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 25),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Color(0xFFB879FF), fontWeight: FontWeight.w700, fontSize: 13)),
      const SizedBox(height: 8),
      LucyCard(child: Column(children: children)),
    ]),
  );
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.title, required this.subtitle, required this.value, required this.onChanged});
  final String title, subtitle; final bool value; final ValueChanged<bool> onChanged;
  @override Widget build(BuildContext context) => SwitchListTile(
    contentPadding: EdgeInsets.zero, title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)), value: value, onChanged: onChanged,
  );
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon; final String title, subtitle; final VoidCallback onTap;
  @override Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero, onTap: onTap, leading: Icon(icon, color: const Color(0xFFB879FF)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
    trailing: const Icon(Icons.chevron_right_rounded),
  );
}