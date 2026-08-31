import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/helpers.dart';
import '../models/message_model.dart';
import '../providers/device_provider.dart';
import '../providers/message_provider.dart';
import '../widgets/ambient_background.dart';
import '../widgets/glass_container.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    final device = context.read<DeviceProvider>();
    final msgProvider = context.read<MessageProvider>();

    final success = await msgProvider.sendMessage(
      text: text,
      senderId: 'caregiver',
      senderName: 'Caregiver',
      deviceId: device.selectedDeviceId ?? '',
      ipAddress: device.selectedDevice?.ipAddress,
    );

    if (success) {
      _messageController.clear();
    }

    if (mounted) {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messageProvider = context.watch<MessageProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.messages)),
      body: AmbientBackground(
        child: Column(
          children: [
            Expanded(
              child: messageProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary)))
                  : messageProvider.messages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.all(16),
                          itemCount: messageProvider.messages.length,
                          itemBuilder: (context, index) {
                            final message = messageProvider.messages[index];
                            return _MessageBubble(message: message);
                          },
                        ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: GlassContainer(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: const InputDecoration(
                          hintText: 'Write a message to your loved one...',
                          hintStyle: TextStyle(color: AppColors.textHint),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        onPressed: _isSending ? null : _sendMessage,
                        icon: _isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 64, color: AppColors.textHint.withAlpha(127)),
          const SizedBox(height: 16),
          const Text(
            AppStrings.noMessages,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to your loved one',
            style: TextStyle(color: AppColors.textHint, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(14),
        borderColor: message.acknowledged
            ? AppColors.success.withAlpha(51)
            : AppColors.border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '💌 From: ${message.senderName}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (message.acknowledged
                            ? AppColors.success
                            : AppColors.warning)
                        .withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (message.acknowledged
                              ? AppColors.success
                              : AppColors.warning)
                          .withAlpha(77),
                    ),
                  ),
                  child: Text(
                    message.acknowledged
                        ? '✓ Acknowledged'
                        : '⏳ Pending',
                    style: TextStyle(
                      color: message.acknowledged
                          ? AppColors.success
                          : AppColors.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              message.text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time, size: 12, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(
                  Helpers.formatDateTime(message.timestamp),
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 11,
                  ),
                ),
                if (message.acknowledged && message.acknowledgedAt != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.check_circle, size: 12, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(
                    'Acknowledged ${Helpers.formatTime(message.acknowledgedAt!)}',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
