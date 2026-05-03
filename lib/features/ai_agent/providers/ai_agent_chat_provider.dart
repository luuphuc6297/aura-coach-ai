import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../data/gemini/config.dart';
import '../data/help_content.dart';

/// One message in the help chat. Author is either the learner or Aura.
class HelpChatMessage {
  final String id;
  final HelpChatRole role;
  final String text;
  final DateTime createdAt;
  final bool isError;

  const HelpChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.isError = false,
  });
}

enum HelpChatRole { user, assistant }

/// Drives the Ask AI panel of the AI Agent screen. Owns the message list,
/// in-flight flag, and the live Gemini ChatSession so multi-turn context
/// (e.g. follow-up questions) actually carries over without us re-shipping
/// the entire history every call.
///
/// Stateless across app restarts on purpose — help conversations are
/// disposable, no Firestore persistence needed. If the user wants to keep
/// notes they can copy-paste from the chat.
class AIAgentChatProvider extends ChangeNotifier {
  AIAgentChatProvider();

  final List<HelpChatMessage> _messages = [
    HelpChatMessage(
      id: 'welcome',
      role: HelpChatRole.assistant,
      text: 'Chào bạn! Mình là Aura, trợ lý của Aura Coach AI. Bạn cần giúp '
          'gì về cách dùng app? Cứ hỏi tự nhiên — ví dụ "làm sao để lưu từ?", '
          '"streak là gì?", hay "Mind Map dùng thế nào?".',
      createdAt: DateTime.now(),
    ),
  ];

  bool _sending = false;
  ChatSession? _session;

  List<HelpChatMessage> get messages => List.unmodifiable(_messages);
  bool get sending => _sending;

  ChatSession _ensureSession() {
    if (_session != null) return _session!;
    final model = GeminiConfig.flash(
      temperature: 0.4,
      responseMimeType: 'text/plain',
      systemInstruction: HelpContent.askAiSystemPrompt,
    );
    _session = model.startChat();
    return _session!;
  }

  Future<void> send(String text) async {
    final clean = text.trim();
    if (clean.isEmpty || _sending) return;

    final userMsg = HelpChatMessage(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      role: HelpChatRole.user,
      text: clean,
      createdAt: DateTime.now(),
    );
    _messages.add(userMsg);
    _sending = true;
    notifyListeners();

    try {
      final session = _ensureSession();
      final response = await session
          .sendMessage(Content.text(clean))
          .timeout(const Duration(seconds: 30));
      final reply = response.text?.trim() ?? '';
      _messages.add(
        HelpChatMessage(
          id: 'a_${DateTime.now().millisecondsSinceEpoch}',
          role: HelpChatRole.assistant,
          text: reply.isEmpty
              ? 'Mình chưa hiểu câu hỏi. Bạn diễn đạt khác giúp mình nhé?'
              : reply,
          createdAt: DateTime.now(),
        ),
      );
    } on TimeoutException {
      _appendError('Mạng đang chậm. Bạn thử lại sau ít giây nhé.');
    } catch (e, st) {
      debugPrint('AIAgentChatProvider.send failed: $e\n$st');
      _appendError(
        kDebugMode
            ? 'Lỗi: $e'
            : 'Mình tạm thời không trả lời được. Bạn thử lại nhé.',
      );
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  void _appendError(String msg) {
    _messages.add(
      HelpChatMessage(
        id: 'e_${DateTime.now().millisecondsSinceEpoch}',
        role: HelpChatRole.assistant,
        text: msg,
        createdAt: DateTime.now(),
        isError: true,
      ),
    );
  }

  /// Wipes the conversation back to the welcome greeting and discards the
  /// underlying ChatSession so context resets too. Useful after the user
  /// closes the chat panel — next opening starts fresh.
  void reset() {
    _messages
      ..clear()
      ..add(
        HelpChatMessage(
          id: 'welcome',
          role: HelpChatRole.assistant,
          text:
              'Chào bạn! Mình là Aura, trợ lý của Aura Coach AI. Bạn cần giúp '
              'gì về cách dùng app?',
          createdAt: DateTime.now(),
        ),
      );
    _session = null;
    _sending = false;
    notifyListeners();
  }
}
