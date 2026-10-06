import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../theme/auth_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String publicPolicyUrl = 'https://app.100.60.191.242.sslip.io/privacy.html';

  Future<void> _openExternalBrowser(BuildContext context) async {
    try {
      final launched = await launchUrlString(
        publicPolicyUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open external browser.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Privacy Policy & Terms',
          style: TextStyle(
            fontFamily: AuthTheme.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: textColor),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: [
          IconButton(
            tooltip: 'Open in Browser',
            icon: Icon(Icons.open_in_browser_rounded, color: AuthTheme.accentSky),
            onPressed: () => _openExternalBrowser(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildBadge('UK GDPR & DPA 2018', AuthTheme.accentSky),
                          _buildBadge('PECR Compliant', const Color(0xFF10B981)),
                          _buildBadge('Terms & Conditions', const Color(0xFF6366F1)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Papervisor Privacy Policy, UK GDPR Statement & Terms of Service',
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Last updated: October 2026 • Effective Date: October 2026',
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'This consolidated legal document outlines how Papervisor ("we", "our", or "us") collects, protects, processes, and respects your personal data in compliance with the UK General Data Protection Regulation (UK GDPR), Data Protection Act 2018, and Privacy and Electronic Communications Regulations (PECR), as well as the terms governing your use of the Papervisor application and web platform.',
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 14,
                          height: 1.6,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section 1: Overview and Data Controller
                _buildSection(
                  title: '1. Data Controller Information',
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  textSecondary: textSecondary,
                  children: [
                    _buildParagraph(
                      'Papervisor is an educational assessment platform designed for teachers, schools, and academic institutions to generate curriculum-aligned examination papers and assessments.',
                      textColor,
                    ),
                    const SizedBox(height: 10),
                    _buildBullet(
                      'Data Controller: Papervisor Education Ltd.',
                      textColor,
                    ),
                    _buildBullet(
                      'Contact / Data Protection Officer (DPO): info@qrioustech.com',
                      textColor,
                    ),
                    _buildBullet(
                      'Primary Jurisdiction: England and Wales (United Kingdom)',
                      textColor,
                    ),
                    _buildBullet(
                      'Supervisory Authority: Information Commissioner\'s Office (ICO), Wycliffe House, Water Lane, Wilmslow, Cheshire SK9 5AF (ico.org.uk)',
                      textColor,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Section 2: Data Collection
                _buildSection(
                  title: '2. Personal Data We Collect',
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  textSecondary: textSecondary,
                  children: [
                    _buildParagraph(
                      'We strictly practice data minimization under UK GDPR Article 5(1)(c) and collect only the data necessary to provide our services:',
                      textColor,
                    ),
                    const SizedBox(height: 10),
                    _buildBullet(
                      'Account & Identity Information: Your full name, institutional email address, and encrypted password credentials (hashed using industry-standard cryptographic algorithms).',
                      textColor,
                    ),
                    _buildBullet(
                      'Curriculum & Educational Content: Subject names, grades/classes, uploaded educational documents (PDF textbooks, worksheets), question banks, past year questions (PYQs), and generated question papers.',
                      textColor,
                    ),
                    _buildBullet(
                      'Technical & Session Data: IP addresses and authorization tokens stored securely in encrypted storage (FlutterSecureStorage on mobile devices) solely for authentication and session continuity.',
                      textColor,
                    ),
                    _buildBullet(
                      'What We Do NOT Collect: We do NOT track individual students, collect children\'s personal identifiers, collect special category data (health, biometric, racial, political), or sell personal information to advertising data brokers.',
                      textColor,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Section 3: Legal Bases for Processing
                _buildSection(
                  title: '3. Legal Bases for Processing (UK GDPR Art. 6)',
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  textSecondary: textSecondary,
                  children: [
                    _buildParagraph(
                      'Under UK GDPR Article 6, we process your personal data under the following legal lawful bases:',
                      textColor,
                    ),
                    const SizedBox(height: 10),
                    _buildBullet(
                      'Performance of Contract (Art. 6(1)(b)): Processing required to deliver our core services, manage user accounts, authenticate teachers, and generate requested exam papers.',
                      textColor,
                    ),
                    _buildBullet(
                      'Legitimate Interests (Art. 6(1)(f)): Ensuring application reliability, system security, bug resolution, and preventing unauthorized abuse of our AI resources.',
                      textColor,
                    ),
                    _buildBullet(
                      'Explicit Consent (Art. 6(1)(a)): When you explicitly opt in to submit curriculum documents to AI models (Google Gemini API) for question synthesis and assessment drafting.',
                      textColor,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Section 4: AI Processing & Third-Party Sub-Processors
                _buildSection(
                  title: '4. AI Sub-Processors & International Transfers',
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  textSecondary: textSecondary,
                  children: [
                    _buildParagraph(
                      'Papervisor integrates advanced artificial intelligence to assist teachers in question generation and research:',
                      textColor,
                    ),
                    const SizedBox(height: 10),
                    _buildBullet(
                      'Google Gemini API (Google LLC): Processes academic prompts and text excerpts from user-selected curriculum documents to produce structured examination questions and marking guides. Your data is not used to train Google\'s foundational public AI models.',
                      textColor,
                    ),
                    _buildBullet(
                      'Self-Hosted Cloud Infrastructure: Hosted on secure Amazon Web Services (AWS EC2) virtual instances with PostgreSQL pgvector and Redis caching. All network traffic is encrypted in transit using TLS 1.3 / SSL.',
                      textColor,
                    ),
                    _buildBullet(
                      'International Data Transfer Safeguards: For transfers outside the UK, appropriate safeguards are in place pursuant to UK GDPR Article 46, including the UK International Data Transfer Agreement (IDTA) and EU Standard Contractual Clauses (SCCs).',
                      textColor,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Section 5: Data Retention & Security
                _buildSection(
                  title: '5. Data Retention & Security Measures',
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  textSecondary: textSecondary,
                  children: [
                    _buildBullet(
                      'Security Controls: We implement strict technical controls, including encrypted authentication tokens (FlutterSecureStorage / KeyStore / Keychain), HTTPS enforcement, database access controls, and sanitized server logging to prevent inadvertent PII disclosure.',
                      textColor,
                    ),
                    _buildBullet(
                      'Retention Period: Account data and workspace contents are retained for the duration of your active account. If an account is inactive or deleted, personal data is permanently erased from active databases within 30 days.',
                      textColor,
                    ),
                    _buildBullet(
                      'Local Storage: Temporary PDF render caches on client devices can be cleared anytime by logging out or selecting "Clear Cache" in app settings.',
                      textColor,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Section 6: Your UK GDPR Rights
                _buildSection(
                  title: '6. Your Rights Under UK GDPR',
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  textSecondary: textSecondary,
                  children: [
                    _buildParagraph(
                      'As a data subject in the United Kingdom, you have the following enforceable statutory rights:',
                      textColor,
                    ),
                    const SizedBox(height: 10),
                    _buildBullet(
                      'Right to Access (Art. 15): Request a complete copy of the personal data we hold about you.',
                      textColor,
                    ),
                    _buildBullet(
                      'Right to Rectification (Art. 16): Request correction of inaccurate or incomplete personal information.',
                      textColor,
                    ),
                    _buildBullet(
                      'Right to Erasure / Deletion (Art. 17): Request permanent deletion of your account and personal data. You can exercise this directly inside the app under Account Settings or by emailing info@qrioustech.com.',
                      textColor,
                    ),
                    _buildBullet(
                      'Right to Restrict Processing (Art. 18): Request restriction of data processing in specified circumstances.',
                      textColor,
                    ),
                    _buildBullet(
                      'Right to Data Portability (Art. 20): Obtain your educational questions and curriculum items in a structured, machine-readable format.',
                      textColor,
                    ),
                    _buildBullet(
                      'Right to Object (Art. 21): Object to processing based on legitimate interests.',
                      textColor,
                    ),
                    _buildBullet(
                      'Right to Lodge a Complaint: You have the right to lodge a complaint with the UK Information Commissioner\'s Office (ICO) at ico.org.uk or by calling 0303 123 1113.',
                      textColor,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Section 7: Terms of Service & User Conduct
                _buildSection(
                  title: '7. Terms of Service & Acceptable Use',
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  textSecondary: textSecondary,
                  children: [
                    _buildBullet(
                      'Account Responsibility: You are responsible for safeguarding your login credentials and for all activities occurring under your account.',
                      textColor,
                    ),
                    _buildBullet(
                      'Curriculum Uploads & Copyright: Users must possess appropriate rights or licenses to upload textbooks, worksheets, and syllabus documents. You agree not to upload content that infringes third-party intellectual property rights or contains confidential student records.',
                      textColor,
                    ),
                    _buildBullet(
                      'Educator Review Requirement: AI-generated exam papers, marking schemes, and question suggestions are intended as pedagogical aids. Educators are solely responsible for reviewing and verifying the accuracy and appropriateness of questions prior to administering examinations to students.',
                      textColor,
                    ),
                    _buildBullet(
                      'Prohibited Uses: You may not use Papervisor to generate misleading, harmful, discriminatory, or unlawful assessment material, or attempt to reverse engineer backend APIs or infrastructure.',
                      textColor,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Section 8: Intellectual Property & Ownership
                _buildSection(
                  title: '8. Intellectual Property & Assessment Ownership',
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  textSecondary: textSecondary,
                  children: [
                    _buildParagraph(
                      'All proprietary code, branding, logos, and UI designs of Papervisor remain the exclusive property of Papervisor. Assessment papers, question banks, and exams created by you using the platform belong to you or your educational institution, subject to underlying curriculum copyright.',
                      textColor,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Section 9: Governing Law & Contact
                _buildSection(
                  title: '9. Governing Law & Contact Us',
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  textSecondary: textSecondary,
                  children: [
                    _buildParagraph(
                      'These terms and privacy policies are governed by and construed in accordance with the laws of England and Wales. Any disputes arising in connection with these terms shall be subject to the exclusive jurisdiction of the courts of England and Wales.',
                      textColor,
                    ),
                    const SizedBox(height: 12),
                    _buildParagraph(
                      'For questions regarding privacy, terms, or to exercise your UK GDPR rights:',
                      textColor,
                    ),
                    const SizedBox(height: 8),
                    _buildBullet('Email: info@qrioustech.com', textColor),
                    _buildBullet('Official Public URL: $publicPolicyUrl', textColor),
                  ],
                ),

                const SizedBox(height: 32),

                // Action Bar
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AuthTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _openExternalBrowser(context),
                    icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                    label: const Text(
                      'Open Public Privacy Policy Page',
                      style: TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AuthTheme.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color textSecondary,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: AuthTheme.fontFamily,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildParagraph(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AuthTheme.fontFamily,
        fontSize: 14,
        height: 1.6,
        color: color,
      ),
    );
  }

  Widget _buildBullet(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 10),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: AuthTheme.accentSky,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 14,
                height: 1.5,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
