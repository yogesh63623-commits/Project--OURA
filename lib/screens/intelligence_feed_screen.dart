import 'package:flutter/material.dart';
import 'package:oura/models/email_summary.dart';
import 'package:oura/repositories/email_repository.dart';

class IntelligenceFeedScreen extends StatefulWidget {
  final EmailRepository? repository;
  const IntelligenceFeedScreen({super.key, this.repository});

  @override
  State<IntelligenceFeedScreen> createState() => _IntelligenceFeedScreenState();
}

class _IntelligenceFeedScreenState extends State<IntelligenceFeedScreen> {
  late final EmailRepository _repo;
  EmailCategory _activeCategory = EmailCategory.primary;
  String _activeFolder = 'Inbox';
  String _searchQuery = '';
  bool _isSidebarCollapsed = false;

  bool _isLoggedIn = false;
  String _userEmail = 'user@oura.io';

  final List<EmailSummary> _sentItems = [
    EmailSummary(
      id: 'sent_1',
      senderName: 'Me',
      senderEmail: 'user@oura.io',
      subject: 'Follow-up: Architecture review meeting notes',
      summary: 'Sent meeting notes and next steps to the infrastructure engineering leads.',
      category: EmailCategory.primary,
      actionItems: ['Await backend confirmation'],
      receivedAt: DateTime.now().subtract(const Duration(days: 1)),
    )
  ];

  final List<EmailSummary> _draftItems = [
    EmailSummary(
      id: 'draft_1',
      senderName: 'Draft',
      senderEmail: 'user@oura.io',
      subject: 'Project Oura Phase 2 Proposal',
      summary: 'Draft outline detailing Flutter Web improvements and user notification hooks.',
      category: EmailCategory.secondary,
      actionItems: ['Complete budget section'],
      receivedAt: DateTime.now().subtract(const Duration(hours: 3)),
    )
  ];

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? EmailRepository();
  }

  void _openAuthDialog() {
    final emailController = TextEditingController(text: _isLoggedIn ? _userEmail : '');
    final passController = TextEditingController();
    bool isSignUp = false;
    bool obscurePassword = true;
    bool rememberMe = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            if (_isLoggedIn) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                contentPadding: const EdgeInsets.all(28),
                content: SizedBox(
                  width: 360,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF1E88E5), width: 3),
                          color: const Color(0xFFE3F2FD),
                        ),
                        child: const Icon(Icons.person, size: 50, color: Color(0xFF1E88E5)),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Signed In",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _userEmail,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            setState(() => _isLoggedIn = false);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Signed out successfully")),
                            );
                          },
                          child: const Text("Sign Out", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text("Close", style: TextStyle(color: Colors.grey.shade700)),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Dialog(
              backgroundColor: const Color(0xFFD6E9FA),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                width: 380,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top Circular User Icon from Reference Image
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF1E88E5), width: 3),
                          color: Colors.transparent,
                        ),
                        child: const Center(
                          child: Icon(Icons.person, size: 62, color: Color(0xFF1E88E5)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Username / Email Field
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6E9FA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF1E88E5), width: 1.8),
                        ),
                        child: TextField(
                          controller: emailController,
                          style: const TextStyle(fontSize: 15, color: Color(0xFF0D47A1)),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                            prefixIcon: Icon(Icons.person, color: Color(0xFF1E88E5), size: 22),
                            hintText: "Username",
                            hintStyle: TextStyle(color: Color(0xFF1E88E5), fontSize: 15),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Password Field with Toggle Eye
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6E9FA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF1E88E5), width: 1.8),
                        ),
                        child: TextField(
                          controller: passController,
                          obscureText: obscurePassword,
                          style: const TextStyle(fontSize: 15, color: Color(0xFF0D47A1)),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            prefixIcon: const Icon(Icons.lock, color: Color(0xFF1E88E5), size: 22),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFF1E88E5),
                                size: 20,
                              ),
                              onPressed: () => setModalState(() => obscurePassword = !obscurePassword),
                            ),
                            hintText: "Password",
                            hintStyle: const TextStyle(color: Color(0xFF1E88E5), fontSize: 15),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Remember Me & Forgot Password Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: rememberMe,
                                  activeColor: const Color(0xFF1E88E5),
                                  side: const BorderSide(color: Color(0xFF1E88E5), width: 1.6),
                                  onChanged: (val) => setModalState(() => rememberMe = val ?? false),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                "Remember me",
                                style: TextStyle(color: Color(0xFF1976D2), fontSize: 12),
                              ),
                            ],
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Password reset email sent.")),
                              );
                            },
                            child: const Text(
                              "Forgot password?",
                              style: TextStyle(color: Color(0xFF1976D2), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Primary LOGIN / SIGN UP Button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (emailController.text.trim().isNotEmpty) {
                              setState(() {
                                _isLoggedIn = true;
                                _userEmail = emailController.text.trim();
                              });
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Logged in as $_userEmail")),
                              );
                            }
                          },
                          child: Text(
                            isSignUp ? "SIGN UP" : "LOGIN",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Toggle between Login and Sign Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isSignUp ? "Already have an account?" : "Don't have an account?",
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                          ),
                          TextButton(
                            onPressed: () => setModalState(() => isSignUp = !isSignUp),
                            child: Text(
                              isSignUp ? "Log In" : "Sign Up",
                              style: const TextStyle(
                                color: Color(0xFF0D47A1),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: const Color(0xFF1E88E5).withOpacity(0.3))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text("or", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ),
                          Expanded(child: Divider(color: const Color(0xFF1E88E5).withOpacity(0.3))),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Login with Google at the bottom
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            setState(() {
                              _isLoggedIn = true;
                              _userEmail = "google.user@oura.io";
                            });
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Signed in via Google successfully!")),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                height: 18,
                                width: 18,
                                errorBuilder: (c, e, s) => const Icon(Icons.g_mobiledata, size: 24, color: Color(0xFF4285F4)),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Sign in with Google",
                                style: TextStyle(
                                  color: Color(0xFF3C4043),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openComposeModal() {
    final toCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.edit_note, color: Color(0xFF0B57D0)),
            SizedBox(width: 8),
            Text("Compose New Message"),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: toCtrl,
                decoration: const InputDecoration(labelText: "To", border: UnderlineInputBorder()),
              ),
              TextField(
                controller: subjectCtrl,
                decoration: const InputDecoration(labelText: "Subject", border: UnderlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "Write your email message...",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Discard")),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B57D0)),
            icon: const Icon(Icons.send, color: Colors.white, size: 16),
            label: const Text("Send", style: TextStyle(color: Colors.white)),
            onPressed: () {
              if (subjectCtrl.text.isNotEmpty) {
                setState(() {
                  _sentItems.insert(
                    0,
                    EmailSummary(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      senderName: 'Me',
                      senderEmail: _userEmail,
                      subject: subjectCtrl.text,
                      summary: bodyCtrl.text.isEmpty ? "No body provided." : bodyCtrl.text,
                      category: EmailCategory.primary,
                      actionItems: [],
                      receivedAt: DateTime.now(),
                    ),
                  );
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Email sent successfully!")),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _openEmailDetail(EmailSummary email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(email.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
          ],
        ),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF0B57D0),
                      child: Text(email.senderName.isEmpty ? '?' : email.senderName[0],
                          style: const TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(email.senderName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(email.senderEmail, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      "${email.receivedAt.hour}:${email.receivedAt.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD3E3FD)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Color(0xFF0B57D0), size: 16),
                          SizedBox(width: 6),
                          Text("AI Intelligence Summary",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF041E49))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(email.summary, style: const TextStyle(height: 1.4)),
                    ],
                  ),
                ),
                if (email.actionItems.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text("Action Items:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...email.actionItems.map((act) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, size: 16, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(child: Text(act)),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("About Project Oura"),
        content: const Text(
          "Project Oura is an AI-powered email triage pipeline:\n\n"
          "1. Gmail captures incoming emails.\n"
          "2. Make.com invokes Gemini AI to categorize and summarize.\n"
          "3. Firestore stores the results.\n"
          "4. Flutter Web presents your intelligent live feed.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
        ],
      ),
    );
  }

  Color _colorFor(EmailCategory c) {
    switch (c) {
      case EmailCategory.primary:
        return const Color(0xFF0B57D0);
      case EmailCategory.secondary:
        return const Color(0xFF007A78);
      case EmailCategory.spam:
        return const Color(0xFFB3261E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopAppBar(),
                if (_activeFolder == 'Inbox') _buildCategoryTabBar(),
                Expanded(child: _buildMainView()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: _isSidebarCollapsed ? 70 : 220,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FC),
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: InkWell(
              onTap: _openComposeModal,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFC2E7FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: _isSidebarCollapsed ? MainAxisSize.min : MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.edit_outlined, color: Color(0xFF001D35)),
                    if (!_isSidebarCollapsed) ...[
                      const SizedBox(width: 8),
                      const Text("Compose",
                          style: TextStyle(color: Color(0xFF001D35), fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _sidebarItem(Icons.inbox, "Inbox"),
          _sidebarItem(Icons.send_outlined, "Sent"),
          _sidebarItem(Icons.drafts_outlined, "Drafts"),
          _sidebarItem(Icons.report_gmailerrorred_outlined, "Spam"),
          const Spacer(),
          _sidebarItem(Icons.settings_outlined, "Settings"),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title) {
    final isSelected = _activeFolder == title;
    return InkWell(
      onTap: () {
        setState(() {
          _activeFolder = title;
          if (title == 'Spam') {
            _activeCategory = EmailCategory.spam;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD3E3FD) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? const Color(0xFF041E49) : Colors.grey.shade700),
            if (!_isSidebarCollapsed) ...[
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF041E49) : Colors.grey.shade800,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
          ),
          const SizedBox(width: 8),

          // Brand Logo + Title Integration
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              'assets/logo.png',
              height: 32,
              width: 32,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.mark_email_unread_rounded,
                color: Color(0xFF0B57D0),
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 10),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Project ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF5F6368),
                  ),
                ),
                TextSpan(
                  text: 'Oura',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B57D0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),

          // Search Bar
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FB),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                      decoration: const InputDecoration(
                        hintText: "Search in intelligence feed...",
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(icon: const Icon(Icons.help_outline), onPressed: _openHelpDialog),
          const SizedBox(width: 8),
          InkWell(
            onTap: _openAuthDialog,
            borderRadius: BorderRadius.circular(20),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: _isLoggedIn ? const Color(0xFF0B57D0) : Colors.grey.shade400,
              child: Icon(
                _isLoggedIn ? Icons.person : Icons.login,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _categoryTab(EmailCategory.primary, "Primary", Icons.inbox),
          _categoryTab(EmailCategory.secondary, "Secondary", Icons.label_important_outline),
          _categoryTab(EmailCategory.spam, "Spam", Icons.report_gmailerrorred),
        ],
      ),
    );
  }

  Widget _categoryTab(EmailCategory cat, String label, IconData icon) {
    final isSelected = _activeCategory == cat;
    return InkWell(
      onTap: () => setState(() => _activeCategory = cat),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF0B57D0) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? const Color(0xFF0B57D0) : Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF0B57D0) : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainView() {
    if (_activeFolder == 'Sent') {
      return _renderList(_sentItems);
    }
    if (_activeFolder == 'Drafts') {
      return _renderList(_draftItems);
    }
    if (_activeFolder == 'Settings') {
      return const Center(child: Text("Project Oura Settings & Configuration"));
    }

    return StreamBuilder<List<EmailSummary>>(
      stream: _repo.getEmails(category: _activeCategory),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snapshot.data ?? [];
        final filtered = list.where((item) {
          return item.subject.toLowerCase().contains(_searchQuery) ||
              item.senderName.toLowerCase().contains(_searchQuery) ||
              item.summary.toLowerCase().contains(_searchQuery);
        }).toList();

        return _renderList(filtered);
      },
    );
  }

  Widget _renderList(List<EmailSummary> emails) {
    if (emails.isEmpty) {
      return Center(
        child: Text("No items found in $_activeFolder",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: emails.length,
      itemBuilder: (context, index) {
        final email = emails[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: InkWell(
            onTap: () => _openEmailDetail(email),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          email.isStarred ? Icons.star : Icons.star_border,
                          color: email.isStarred ? Colors.amber : Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => setState(() => email.isStarred = !email.isStarred),
                      ),
                      Text(email.senderName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _colorFor(email.category).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          email.category.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _colorFor(email.category),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${email.receivedAt.hour}:${email.receivedAt.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(
                      email.subject,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFF0B57D0), size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            email.summary,
                            style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}