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
  final DateTime receivedAt;
  bool isStarred;
  bool isRead;

  EmailSummary({
    required this.id,
    required this.senderName,
    required this.senderEmail,
    required this.subject,
    required this.summary,
    required this.category,
    required this.actionItems,
    required this.receivedAt,
    this.isStarred = false,
    this.isRead = false,
  });

  factory EmailSummary.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};

    // Parse category safely
    final rawCategory = (data['category'] ?? 'primary').toString().toLowerCase();
    EmailCategory cat = EmailCategory.primary;
    if (rawCategory.contains('spam')) {
      cat = EmailCategory.spam;
    } else if (rawCategory.contains('secondary')) {
      cat = EmailCategory.secondary;
    }

    // Parse timestamp safely
    DateTime date = DateTime.now();
    final rawDate = data['received_at'] ?? data['timestamp'] ?? data['date'];
    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else if (rawDate is String) {
      date = DateTime.tryParse(rawDate) ?? DateTime.now();
    }

    // Parse action items list
    List<String> actions = [];
    if (data['action_items'] is List) {
      actions = List<String>.from(data['action_items'].map((e) => e.toString()));
    } else if (data['action_items'] is String && (data['action_items'] as String).isNotEmpty) {
      actions = [(data['action_items'] as String)];
    }

    return EmailSummary(
      id: doc.id,
      senderName: data['sender_name'] ?? data['sender'] ?? 'Unknown Sender',
      senderEmail: data['sender_email'] ?? '',
      subject: data['subject'] ?? '(No Subject)',
      summary: data['summary'] ?? 'No summary available.',
      category: cat,
      actionItems: actions,
      receivedAt: date,
      isStarred: data['is_starred'] ?? false,
      isRead: data['is_read'] ?? false,
    );
  }
}