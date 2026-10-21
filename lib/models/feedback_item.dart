import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FeedbackCategory {
  final String key;
  final String label;
  final String emoji;
  final String description;
  final IconData icon;
  final Color color;

  const FeedbackCategory({
    required this.key,
    required this.label,
    required this.emoji,
    required this.description,
    required this.icon,
    required this.color,
  });

  static const List<FeedbackCategory> all = [
    FeedbackCategory(
      key: 'bug_report',
      label: 'Laporan Masalah (Bug)',
      emoji: '🐛',
      description: 'Ada fitur yang error, macet, atau tidak berfungsi semestinya.',
      icon: CupertinoIcons.exclamationmark_triangle_fill,
      color: Colors.redAccent,
    ),
    FeedbackCategory(
      key: 'feature_request',
      label: 'Ide / Fitur Baru',
      emoji: '💡',
      description: 'Usulan penambahan fitur atau kemampuan baru di aplikasi.',
      icon: CupertinoIcons.lightbulb_fill,
      color: Colors.amber,
    ),
    FeedbackCategory(
      key: 'recipe_feedback',
      label: 'Resep & Ekstraksi',
      emoji: '☕',
      description: 'Saran rasio, biji kopi lokal, metode seduh, atau varietas.',
      icon: CupertinoIcons.flame_fill,
      color: Color(0xFF6B4423),
    ),
    FeedbackCategory(
      key: 'ui_ux',
      label: 'Desain & Tampilan',
      emoji: '🎨',
      description: 'Saran tata letak, kemudahan navigasi, atau kenyamanan visual.',
      icon: CupertinoIcons.paintbrush_fill,
      color: Colors.purple,
    ),
    FeedbackCategory(
      key: 'other',
      label: 'Masukan Umum',
      emoji: '💬',
      description: 'Pujian, pertanyaan, atau masukan lain seputar Coffee Labs.',
      icon: CupertinoIcons.chat_bubble_2_fill,
      color: Colors.blue,
    ),
  ];

  static FeedbackCategory fromKey(String key) {
    return all.firstWhere(
      (c) => c.key.toLowerCase() == key.toLowerCase(),
      orElse: () => all.last,
    );
  }
}

class FeedbackStatusHelper {
  static String getLabel(String status) {
    switch (status.toLowerCase()) {
      case 'reviewed':
        return 'Ditinjau';
      case 'in_progress':
        return 'Sedang Diproses';
      case 'resolved':
        return 'Selesai';
      case 'dismissed':
        return 'Ditutup';
      default:
        return 'Menunggu';
    }
  }

  static Color getColor(String status) {
    switch (status.toLowerCase()) {
      case 'reviewed':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'resolved':
        return Colors.green;
      case 'dismissed':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }
}

class FeedbackItem {
  final String id;
  final String? userId;
  final String username;
  final String userRole;
  final String category;
  final String featureAffected;
  final String title;
  final String description;
  final int rating;
  final String appVersion;
  final String deviceInfo;
  final String status;
  final String? adminNotes;
  final DateTime createdAt;

  const FeedbackItem({
    required this.id,
    this.userId,
    required this.username,
    required this.userRole,
    required this.category,
    required this.featureAffected,
    required this.title,
    required this.description,
    required this.rating,
    required this.appVersion,
    required this.deviceInfo,
    required this.status,
    this.adminNotes,
    required this.createdAt,
  });

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    return FeedbackItem(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      username: json['username']?.toString() ?? 'Tamu',
      userRole: json['user_role']?.toString() ?? 'guest',
      category: json['category']?.toString() ?? 'other',
      featureAffected: json['feature_affected']?.toString() ?? 'Umum',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      appVersion: json['app_version']?.toString() ?? '1.0.0',
      deviceInfo: json['device_info']?.toString() ?? 'Mobile',
      status: json['status']?.toString() ?? 'pending',
      adminNotes: json['admin_notes']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  FeedbackCategory get categoryInfo => FeedbackCategory.fromKey(category);
}

class FeedbackStatsData {
  final int total;
  final int pending;
  final int inProgress;
  final int resolved;
  final int bugReports;
  final int featureRequests;
  final double averageRating;

  const FeedbackStatsData({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.resolved,
    required this.bugReports,
    required this.featureRequests,
    required this.averageRating,
  });

  factory FeedbackStatsData.fromJson(Map<String, dynamic> json) {
    return FeedbackStatsData(
      total: (json['total'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      inProgress: (json['in_progress'] as num?)?.toInt() ?? 0,
      resolved: (json['resolved'] as num?)?.toInt() ?? 0,
      bugReports: (json['bug_reports'] as num?)?.toInt() ?? 0,
      featureRequests: (json['feature_requests'] as num?)?.toInt() ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 5.0,
    );
  }
}
