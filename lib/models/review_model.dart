import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final int mediaId;
  final String mediaType;
  final double rating;
  final String comment;
  final DateTime? createdAt;

  ReviewModel({
    required this.id, required this.userId, required this.userName,
    required this.userAvatar, required this.mediaId, required this.mediaType,
    required this.rating, required this.comment, this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ReviewModel(
      id: documentId,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userAvatar: data['userAvatar'] ?? '',
      mediaId: data['mediaId'] ?? 0,
      mediaType: data['mediaType'] ?? 'movie',
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
    );
  }
}