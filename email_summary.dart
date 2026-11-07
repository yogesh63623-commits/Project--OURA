import 'package:cloud_firestore/cloud_firestore.dart';

enum EmailCategory { primary, secondary, spam }

class EmailSummary {
  final String id;
  final String senderName;
  final String senderEmail;
  final String subject;
  final String summary;
  final EmailCategory category;
  final List<String> actionItems;
  final bool isRead;

  const EmailSummary({
    required this.id,
    required this.senderName,
    required this.senderEmail,
    required this.subject,
    required this.summary,
    required this.category,
    this.actionItems = const [],
    this.isRead = false,
  });

  /// Builds an EmailSummary from a Firestore document.
  factory EmailSummary.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return EmailSummary(
      id: doc.id,
      senderName: data['senderName'] as String? ?? '',
      senderEmail: data['senderEmail'] as String? ?? '',
      subject: data['subject'] as String? ?? '',
      summary: data['summary'] as String? ?? '',
      category: _categoryFromString(data['category'] as String?),
      actionItems: List<String>.from(data['actionItems'] ?? const []),
      isRead: data['isRead'] as bool? ?? false,
    );
  }

  /// Converts to a map for writing to Firestore.
  /// The id is not included because it is the document ID.
  Map<String, dynamic> toMap() {
    return {
      'senderName': senderName,
      'senderEmail': senderEmail,
      'subject': subject,
      'summary': summary,
      'category': category.name,
      'actionItems': actionItems,
      'isRead': isRead,
    };
  }

  EmailSummary copyWith({
    String? id,
    String? senderName,
    String? senderEmail,
    String? subject,
    String? summary,
    EmailCategory? category,
    List<String>? actionItems,
    bool? isRead,
  }) {
    return EmailSummary(
      id: id ?? this.id,
      senderName: senderName ?? this.senderName,
      senderEmail: senderEmail ?? this.senderEmail,
      subject: subject ?? this.subject,
      summary: summary ?? this.summary,
      category: category ?? this.category,
      actionItems: actionItems ?? this.actionItems,
      isRead: isRead ?? this.isRead,
    );
  }

  static EmailCategory _categoryFromString(String? value) {
    return EmailCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => EmailCategory.primary,
    );
  }
}
