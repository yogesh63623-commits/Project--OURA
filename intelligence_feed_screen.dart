import 'package:flutter/material.dart';

import 'email_repository.dart';
import 'email_summary.dart';

class IntelligenceFeedScreen extends StatefulWidget {
  const IntelligenceFeedScreen({super.key, this.repository});

  final EmailRepository? repository;

  @override
  State<IntelligenceFeedScreen> createState() => _IntelligenceFeedScreenState();
}

class _IntelligenceFeedScreenState extends State<IntelligenceFeedScreen> {
  late final EmailRepository _repository;
  late final Stream<List<EmailSummary>> _stream;
  EmailCategory _selected = EmailCategory.primary;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? EmailRepository();
    // Created once so rebuilds (tab changes) don't re-subscribe.
    _stream = _repository.watchEmails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intelligence Feed'),
        centerTitle: false,
      ),
      body: StreamBuilder<List<EmailSummary>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _MessageState(
              icon: Icons.error_outline,
              message: 'Something went wrong loading your emails.',
              detail: '${snapshot.error}',
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final all = snapshot.data ?? const <EmailSummary>[];
          final counts = {
            for (final c in EmailCategory.values)
              c: all.where((e) => e.category == c).length,
          };
          final filtered = all.where((e) => e.category == _selected).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<EmailCategory>(
                    showSelectedIcon: false,
                    segments: [
                      for (final c in EmailCategory.values)
                        ButtonSegment(
                          value: c,
                          label: Text('${_labelFor(c)} (${counts[c]})'),
                        ),
                    ],
                    selected: {_selected},
                    onSelectionChanged: (s) =>
                        setState(() => _selected = s.first),
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? _MessageState(
                        icon: Icons.inbox_outlined,
                        message:
                            'No ${_labelFor(_selected).toLowerCase()} emails right now',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => EmailSummaryCard(
                          email: filtered[i],
                          onTap: () {
                            if (!filtered[i].isRead) {
                              _repository.markAsRead(filtered[i].id);
                            }
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _labelFor(EmailCategory c) {
  switch (c) {
    case EmailCategory.primary:
      return 'Primary';
    case EmailCategory.secondary:
      return 'Secondary';
    case EmailCategory.spam:
      return 'Spam';
  }
}

Color _colorFor(EmailCategory c) {
  switch (c) {
    case EmailCategory.primary:
      return const Color(0xFF2563EB); // blue
    case EmailCategory.secondary:
      return const Color(0xFF0D9488); // teal
    case EmailCategory.spam:
      return const Color(0xFFB4534F); // muted red
  }
}

String _timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${time.day}/${time.month}/${time.year}';
}

class EmailSummaryCard extends StatelessWidget {
  const EmailSummaryCard({super.key, required this.email, this.onTap});

  final EmailSummary email;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _colorFor(email.category);
    final senderLabel =
        email.senderName.isNotEmpty ? email.senderName : email.senderEmail;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge + unread dot
              Row(
                children: [
                  _CategoryBadge(
                    label: _labelFor(email.category),
                    color: accent,
                  ),
                  const Spacer(),
                  if (!email.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Sender + time
              Row(
                children: [
                  Expanded(
                    child: Text(
                      senderLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _timeAgo(email.receivedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Subject
              Text(
                email.subject.isEmpty ? '(No subject)' : email.subject,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: email.isRead ? FontWeight.w500 : FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              // AI summary
              Text(
                email.summary,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),

              // Action items
              if (email.actionItems.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in email.actionItems)
                      Chip(
                        avatar: Icon(Icons.check_circle_outline,
                            size: 16, color: accent),
                        label: Text(item),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: accent.withValues(alpha: 0.08),
                        side: BorderSide.none,
                        labelStyle: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.icon, required this.message, this.detail});

  final IconData icon;
  final String message;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (detail != null) ...[
              const SizedBox(height: 8),
              Text(
                detail!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
