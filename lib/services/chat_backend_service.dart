import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ChatBackendService {
  const ChatBackendService();

  /// Configure at build time:
  /// flutter run --dart-define=BACKEND_URL=https://10.0.2.2:3000
  static const String backendUrl = ('AIzaSyAYQ3tCg3fSx3YKNtLvURrzu-J78CpRVw4');

  Future<String> sendMessage(String message) async {
    final safeMessage = message.trim();
    if (safeMessage.isEmpty) {
      throw const ChatBackendException('Message is empty.');
    }
    if (backendUrl.trim().isEmpty) {
      throw const ChatBackendException('Chat backend is not configured.');
    }

    final baseUri = Uri.tryParse(backendUrl);
    if (baseUri == null || !baseUri.hasScheme) {
      throw const ChatBackendException('Invalid chat backend URL.');
    }

    try {
      final uri = baseUri.resolve('/chat');
      final resp = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'message': safeMessage}),
          )
          .timeout(const Duration(seconds: 20));

      final data = _decodeObject(resp.body);
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        final err = (data['error'] ?? 'Request failed').toString();
        throw ChatBackendException(err);
      }

      final reply = (data['reply'] ?? '').toString().trim();
      if (reply.isEmpty) {
        throw const ChatBackendException('Empty response from chat backend.');
      }
      return reply;
    } on TimeoutException {
      throw const ChatBackendException(
        'Connection timed out. Please try again.',
      );
    } on ChatBackendException {
      rethrow;
    } catch (_) {
      throw const ChatBackendException('Could not reach chat backend.');
    }
  }

  Map<String, dynamic> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map) return decoded.cast<String, dynamic>();
    throw const ChatBackendException('Invalid response from chat backend.');
  }
}

class ChatBackendException implements Exception {
  const ChatBackendException(this.message);

  final String message;

  @override
  String toString() => message;
}

const chatBackendService = ChatBackendService();
