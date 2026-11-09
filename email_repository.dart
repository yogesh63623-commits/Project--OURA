import 'package:cloud_firestore/cloud_firestore.dart';

import 'email_summary.dart';

class EmailRepository {
  EmailRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Live stream of all emails, newest first.
  Stream<List<EmailSummary>> watchEmails() {
    return _firestore
        .collection('emails')
        .orderBy('received_at', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(EmailSummary.fromFirestore).toList());
  }

  /// Marks an email as read.
  Future<void> markAsRead(String id) {
    return _firestore.collection('emails').doc(id).update({'isRead': true});
  }
}
