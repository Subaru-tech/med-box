import 'package:flutter/material.dart';
import '../models/notice_model.dart';
import '../models/device_model.dart';
import '../repositories/notice_repository.dart';
import '../services/network_service.dart';

class NoticeProvider with ChangeNotifier {
  final NoticeRepository _repository = NoticeRepository();
  final NetworkService _networkService = NetworkService();
  List<Notice> _notices = [];
  bool _isLoading = false;
  String? _searchQuery;

  List<Notice> get notices {
    if (_searchQuery == null || _searchQuery!.isEmpty) {
      return _notices;
    }
    return _notices.where((n) => 
      n.title.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
      n.message.toLowerCase().contains(_searchQuery!.toLowerCase())
    ).toList();
  }
  
  bool get isLoading => _isLoading;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Listen to notices created by the user
  void listenToUserNotices(String userId) {
    _isLoading = true;
    _repository.getNoticesByUser(userId).listen((data) {
      _notices = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Create a new notice and push to hardware if online
  Future<bool> createNotice(Notice notice, {Device? targetDevice}) async {
    try {
      // 1. Save to Cloud Firestore (Sync)
      await _repository.createNotice(notice);

      // 2. Direct Push to Hardware (Local IP)
      if (targetDevice != null && 
          targetDevice.ipAddress != null && 
          targetDevice.ipAddress!.isNotEmpty) {
        
        await _networkService.sendNoticeToDevice(
          ipAddress: targetDevice.ipAddress!,
          title: notice.title,
          message: notice.message,
          scheduledAt: notice.scheduledAt,
        );
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a notice
  Future<void> deleteNotice(String id) async {
    await _repository.deleteNotice(id);
  }

  /// Resend a notice
  Future<void> resendNotice(String id) async {
    await _repository.resendNotice(id);
  }
}
