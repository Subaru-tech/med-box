import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../repositories/message_repository.dart';
import '../services/network_service.dart';

class MessageProvider with ChangeNotifier {
  final MessageRepository _repository = MessageRepository();
  final NetworkService _networkService = NetworkService();
  List<Message> _messages = [];
  bool _isLoading = false;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  int get pendingMessages =>
      _messages.where((m) => !m.acknowledged).length;

  /// Listen to messages for a device
  void listenToMessages(String deviceId) {
    _isLoading = true;
    _repository.getMessagesForDevice(deviceId).listen((data) {
      _messages = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Listen to messages sent by the caregiver
  void listenToSentMessages(String senderId) {
    _isLoading = true;
    _repository.getMessagesBySender(senderId).listen((data) {
      _messages = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Send a message to the elderly person's device
  Future<bool> sendMessage({
    required String text,
    required String senderId,
    required String senderName,
    required String deviceId,
    String? ipAddress,
  }) async {
    try {
      final message = Message(
        id: '',
        text: text,
        senderId: senderId,
        senderName: senderName,
        deviceId: deviceId,
        timestamp: DateTime.now(),
      );

      await _repository.sendMessage(message);

      // Push to device if online
      if (ipAddress != null && ipAddress.isNotEmpty) {
        await _networkService.sendMessageToDevice(
          ipAddress: ipAddress,
          text: text,
          senderName: senderName,
        );
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String id) async {
    await _repository.deleteMessage(id);
  }
}
