import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:oura/models/email_summary.dart';

class EmailRepository {
  final FirebaseFirestore? _firestore;

  EmailRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? _safeFirestore();

  static FirebaseFirestore? _safeFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint("Firestore not initialized, falling back to local mock data: $e");
      return null;
    }
  }

  Stream<List<EmailSummary>> getEmails({EmailCategory? category}) {
    if (_firestore == null) {
      return Stream.value(_getFallbackEmails(category));
    }

    try {
      Query query = _firestore!.collection('emails').orderBy('received_at', descending: true);
      
      return query.snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return _getFallbackEmails(category);
        }
        var list = snapshot.docs.map((doc) => EmailSummary.fromFirestore(doc)).toList();
        if (category != null) {
          list = list.where((item) => item.category == category).toList();
        }
        return list;
      }).handleError((error) {
        debugPrint("Firestore stream error, returning fallback data: $error");
        return _getFallbackEmails(category);
      });
    } catch (e) {
      debugPrint("Query build error: $e");
      return Stream.value(_getFallbackEmails(category));
    }
  }

  List<EmailSummary> _getFallbackEmails(EmailCategory? category) {
    final all = [
      EmailSummary(
        id: '1',
        senderName: 'Sarah Jenkins',
        senderEmail: 'sarah.j@enterprise.com',
        subject: 'Urgent: Final Q4 Product Review & Approval Needed',
        summary: 'Sarah requests final approval on the Q4 roadmap slide deck prior to tomorrow\'s board presentation.',
        category: EmailCategory.primary,
        actionItems: ['Review Q4 slide deck by 4 PM', 'Confirm meeting attendance'],
        receivedAt: DateTime.now().subtract(const Duration(minutes: 14)),
      ),
      EmailSummary(
        id: '2',
        senderName: 'GitHub Notifications',
        senderEmail: 'notifications@github.com',
        subject: 'New release published: v2.4.0 in project-oura',
        summary: 'Automated release notes detailing latest CI/CD pipeline and web deployment optimizations.',
        category: EmailCategory.secondary,
        actionItems: ['Review release notes'],
        receivedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      EmailSummary(
        id: '3',
        senderName: 'Prize Lottery Club',
        senderEmail: 'winner@claim-rewards-online.xyz',
        subject: 'Claim your exclusive \$1,000 gift voucher right now!',
        summary: 'Unsolicited promotional message flagged by AI due to suspicious links and prize solicitation.',
        category: EmailCategory.spam,
        actionItems: [],
        receivedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];

    if (category == null) return all;
    return all.where((e) => e.category == category).toList();
  }
}