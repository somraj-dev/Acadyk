import 'profile_model.dart';

class NotificationModel {
  final String id;
  final String recipientId;
  final String? senderId;
  final String type; // follow, like, comment, club_join_request, student_chapter_join_request, etc.
  final String title;
  final String body;
  final String? referenceId;
  final String? referenceType;
  final String? clubId;
  final String? clubTitle;
  final String? requestStatus; // pending, approved, declined
  final bool isRead;
  final DateTime createdAt;
  final ProfileModel? senderProfile;

  NotificationModel({
    required this.id,
    required this.recipientId,
    this.senderId,
    required this.type,
    required this.title,
    required this.body,
    this.referenceId,
    this.referenceType,
    this.clubId,
    this.clubTitle,
    this.requestStatus,
    required this.isRead,
    required this.createdAt,
    this.senderProfile,
  });

  bool get isClubJoinRequest =>
      type == 'club_join_request' ||
      type == 'student_chapter_join_request' ||
      type == 'chapter_join_request';

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    ProfileModel? senderProfileObj;
    if (json['sender'] != null) {
      senderProfileObj = ProfileModel.fromJson(json['sender']);
    } else if (json['profiles'] != null) {
      senderProfileObj = ProfileModel.fromJson(json['profiles']);
    }

    return NotificationModel(
      id: json['id'] ?? '',
      recipientId: json['recipient_id'] ?? '',
      senderId: json['sender_id'],
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      referenceId: json['reference_id']?.toString(),
      referenceType: json['reference_type'],
      clubId: json['club_id']?.toString() ?? json['clubId']?.toString(),
      clubTitle: json['club_title']?.toString() ?? json['clubTitle']?.toString(),
      requestStatus: json['request_status']?.toString() ?? json['requestStatus']?.toString() ?? (json['type']?.toString().contains('join_request') == true ? 'pending' : null),
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      senderProfile: senderProfileObj,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient_id': recipientId,
      'sender_id': senderId,
      'type': type,
      'title': title,
      'body': body,
      'reference_id': referenceId,
      'reference_type': referenceType,
      'club_id': clubId,
      'club_title': clubTitle,
      'request_status': requestStatus,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
