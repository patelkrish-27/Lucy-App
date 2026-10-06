import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/io.dart';

class LucyConnection {
  const LucyConnection({required this.name, required this.url});
  final String name;
  final String url;
}

class LucyService {
  LucyService({this.baseUrl});
  static const _storage = FlutterSecureStorage();
  static const _urlKey = 'lucy.url';
  static const _tokenKey = 'lucy.device_token';
  static const _nameKey = 'lucy.server_name';
  final String? baseUrl;
  IOWebSocketChannel? _socket;

  Future<LucyConnection?> savedConnection() async {
    final url = await _storage.read(key: _urlKey);
    final name = await _storage.read(key: _nameKey);
    if (url == null || url.isEmpty) return null;
    return LucyConnection(name: name ?? 'Lucy Desktop', url: url);
  }

  Future<LucyConnection> pairFromQr(String raw) async {
    final data = jsonDecode(raw);
    if (data is! Map || data['lucy'] != 1) throw const FormatException('This is not a Lucy pairing QR code.');
    final url = _normaliseWs(data['url'] as String?);
    final token = data['token'] as String?;
    final name = (data['name'] as String?)?.trim();
    if (url == null || token == null || token.isEmpty) throw const FormatException('The Lucy QR code is incomplete.');
    final auth = await _connectAndAuth(url, token, await _deviceName());
    final deviceToken = auth['device_token'] as String?;
    if (deviceToken == null || deviceToken.isEmpty) throw const FormatException('Lucy did not return a device token.');
    await _storage.write(key: _urlKey, value: url);
    await _storage.write(key: _tokenKey, value: deviceToken);
    await _storage.write(key: _nameKey, value: name ?? (auth['device'] as String? ?? 'Lucy Desktop'));
    await disconnect();
    return LucyConnection(name: name ?? 'Lucy Desktop', url: url);
  }

  Future<String> sendTask(String prompt, {Future<bool> Function(String name, Map<String, dynamic> input)? onApproval}) async {
    final token = await _storage.read(key: _tokenKey);
    final saved = await savedConnection();
    if (token == null || saved == null) throw StateError('Connect Lucy first by scanning the QR code.');
    await _ensureConnected(saved.url, token);
    final socket = _socket!;
    final done = Completer<String>();
    late StreamSubscription sub;
    sub = socket.stream.listen((event) async {
      try {
        final msg = jsonDecode(event as String) as Map<String, dynamic>;
        switch (msg['type']) {
          case 'approval_request':
            final allow = await (onApproval?.call(msg['name'] as String? ?? 'Lucy action', Map<String, dynamic>.from(msg['input'] as Map? ?? const {})) ?? Future.value(false));
            _send({'type': 'approval', 'id': msg['id'], 'decision': allow ? 'allow_once' : 'deny'});
          case 'task_done':
            if (!done.isCompleted) done.complete(msg['summary'] as String? ?? '');
          case 'error':
            if (!done.isCompleted) done.completeError(StateError(msg['message'] as String? ?? 'Lucy reported an error.'));
        }
      } catch (e) {
        if (!done.isCompleted) done.completeError(e);
      }
    });
    _send({'type': 'task', 'prompt': prompt});
    try { return await done.future.timeout(const Duration(minutes: 30)); }
    finally { await sub.cancel(); }
  }

  Future<Map<String, dynamic>> _connectAndAuth(String url, String token, String deviceName) async {
    await disconnect();
    final channel = IOWebSocketChannel.connect(Uri.parse(url));
    _socket = channel;
    final auth = Completer<Map<String, dynamic>>();
    late StreamSubscription sub;
    sub = channel.stream.listen((event) {
      try {
        final msg = jsonDecode(event as String) as Map<String, dynamic>;
        if (msg['type'] == 'hello') {
          _send({'type': 'auth', 'token': token, 'name': deviceName});
        } else if (msg['type'] == 'auth_ok' && !auth.isCompleted) {
          auth.complete(msg);
        } else if (msg['type'] == 'error' && !auth.isCompleted) {
          auth.completeError(StateError(msg['message'] as String? ?? 'Lucy rejected the connection.'));
        }
      } catch (e) { if (!auth.isCompleted) auth.completeError(e); }
    }, onError: auth.completeError, onDone: () {
      if (!auth.isCompleted) auth.completeError(StateError('Lucy disconnected.'));
    });
    try { return await auth.future.timeout(const Duration(seconds: 10)); }
    finally { await sub.cancel(); }
  }

  Future<void> _ensureConnected(String url, String token) async {
    if (_socket != null) return;
    await _connectAndAuth(url, token, await _deviceName());
  }

  void _send(Map<String, dynamic> message) => _socket?.sink.add(jsonEncode(message));
  Future<void> disconnect() async {
    final socket = _socket; _socket = null; await socket?.sink.close();
  }

  String? _normaliseWs(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri == null || uri.host.isEmpty) return null;
    if (uri.scheme == 'http') return uri.replace(scheme: 'ws').toString();
    if (uri.scheme == 'https') return uri.replace(scheme: 'wss').toString();
    if (uri.scheme == 'ws' || uri.scheme == 'wss') return uri.toString();
    return null;
  }

  Future<String> _deviceName() async {
    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final a = await info.androidInfo;
      return '${a.manufacturer} ${a.model}'.trim();
    }
    if (Platform.isIOS) {
      final i = await info.iosInfo;
      return i.name.isEmpty ? 'iPhone' : i.name;
    }
    return 'Lucy Phone';
  }
}