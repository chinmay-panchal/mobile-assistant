import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../services/reference_paper_service.dart';
import '../../../../services/paper_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/paper_wizard_state.dart';
import 'paper_wizard_step_difficulty.dart';
import 'pdf_preview_screen.dart';

class PaperWizardStepReference extends StatefulWidget {
  final Map<String, dynamic> subject;
  final PaperWizardState state;

  const PaperWizardStepReference({Key? key, required this.subject, required this.state}) : super(key: key);

  @override
  State<PaperWizardStepReference> createState() => _PaperWizardStepReferenceState();
}

class _PaperWizardStepReferenceState extends State<PaperWizardStepReference> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReferencePaperService _refService = ReferencePaperService();
  final PaperService _paperService = PaperService();

  List<Map<String, dynamic>> _refPapers = [];
  List<Map<String, dynamic>> _aiPapers = [];
  bool _loadingPapers = true;

  // Upload state
  bool _uploading = false;
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _yearCtrl = TextEditingController();
  final TextEditingController _examTypeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchPapers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleCtrl.dispose();
    _yearCtrl.dispose();
    _examTypeCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchPapers() async {
    setState(() { _loadingPapers = true; });
    try {
      final results = await Future.wait([
        _refService.listReferencePapers(widget.subject['id']),
        _paperService.listPapersBySubject(widget.subject['id']),
      ]);
      if (mounted) {
        setState(() { 
          _refPapers = results[0]; 
          _aiPapers = results[1].where((p) => p['status'] != 'FAILED').toList();
          _loadingPapers = false; 
        });
      }
    } catch (_) {
      if (mounted) setState(() { _loadingPapers = false; });
    }
  }

  Future<void> _pickAndUpload() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a title first.')));
      return;
    }

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: false,
        withReadStream: false,
      );
      if (result == null || result.isEmpty) return;
      final picked = result.first;
      if (picked.path == null) return;

      setState(() => _uploading = true);

      final uploaded = await _refService.uploadReferencePaper(
        subjectId: widget.subject['id'],
        title: title,
        filePath: picked.path!,
        year: int.tryParse(_yearCtrl.text.trim()),
        examType: _examTypeCtrl.text.trim().isEmpty ? null : _examTypeCtrl.text.trim(),
      );

      if (mounted) {
        setState(() {
          _uploading = false;
          // auto-select the uploaded paper
          widget.state.referencePaperId = uploaded['id'];
          _titleCtrl.clear();
          _yearCtrl.clear();
          _examTypeCtrl.clear();
        });
        // refresh library and switch to library tab
        await _fetchPapers();
        _tabController.animateTo(0);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reference paper uploaded!')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Step 3 of 5', style: theme.textTheme.bodySmall),
          Text('Reference', style: theme.textTheme.titleLarge),
        ]),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(children: [
          _buildProgressBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('REFERENCE PAPER', style: theme.textTheme.labelLarge?.copyWith(fontSize: 12, letterSpacing: 1.2)),
                const SizedBox(height: 4),
                const Text('Optional — helps guide format and question style', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 20),
                // Tab bar
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.all(4),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.primary),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textTertiary,
                    tabs: const [
                      Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.collections_bookmark, size: 16), SizedBox(width: 8),
                        Text('From Library', style: TextStyle(fontWeight: FontWeight.bold)),
                      ])),
                      Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.upload, size: 16), SizedBox(width: 8),
                        Text('Upload New', style: TextStyle(fontWeight: FontWeight.bold)),
                      ])),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildLibraryTab(), _buildUploadTab()],
                  ),
                ),
                const SizedBox(height: 16),
                // Info box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: RichText(text: const TextSpan(
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.5),
                      children: [
                        TextSpan(text: 'This step is ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: 'optional', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning)),
                        TextSpan(text: '. When provided, AI will mirror the reference paper\'s format — no need to configure question types manually.'),
                      ],
                    ))),
                  ]),
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(children: [
              if (widget.state.referencePaperId != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(children: [
                    const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                    const SizedBox(width: 8),
                    const Text('Reference paper selected', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 13)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => setState(() => widget.state.referencePaperId = null),
                      child: const Text('Clear', style: TextStyle(color: AppColors.error)),
                    ),
                  ]),
                ),
              PrimaryButton(
                text: 'Continue',
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => PaperWizardStepDifficulty(subject: widget.subject, state: widget.state),
                  ));
                },
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildLibraryTab() {
    if (_loadingPapers) return const Center(child: CircularProgressIndicator());
    if (_refPapers.isEmpty && _aiPapers.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.insert_drive_file_outlined, size: 48, color: AppColors.textTertiary.withOpacity(0.4)),
        const SizedBox(height: 12),
        const Text('No papers found', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Upload a past-year paper or generate one with AI', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
      ]));
    }

    final combinedList = [
      ..._refPapers.map((p) => {...p, 'is_ai': false}),
      ..._aiPapers.map((p) => {...p, 'is_ai': true}),
    ];

    return ListView.builder(
      itemCount: combinedList.length,
      itemBuilder: (context, index) {
        final paper = combinedList[index];
        final isSelected = widget.state.referencePaperId == paper['id'];
        final isAi = paper['is_ai'] == true;

        return GestureDetector(
          onTap: () => setState(() {
            widget.state.referencePaperId = isSelected ? null : paper['id'];
          }),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: isSelected ? 2 : 1),
            ),
            child: Row(children: [
              CircleAvatar(
                backgroundColor: isAi ? const Color(0xFF9333EA).withOpacity(0.1) : AppColors.divider.withOpacity(0.4),
                child: Icon(isAi ? Icons.auto_awesome : Icons.insert_drive_file_outlined,
                  color: isAi ? const Color(0xFF9333EA) : AppColors.textTertiary),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(paper['title'] ?? 'Reference Paper',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(children: [
                  if (paper['year'] != null) ...[
                    Text('${paper['year']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('•', style: TextStyle(color: AppColors.textTertiary, fontSize: 12))),
                  ],
                  if (paper['exam_type'] != null)
                    Text('${paper['exam_type']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  if (isAi && paper['total_marks'] != null)
                    Text('${paper['total_marks']} marks', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ]),
              ])),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.remove_red_eye, color: AppColors.textSecondary),
                onPressed: () async {
                  if (isAi) {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => PdfPreviewScreen(subject: widget.subject, paper: paper),
                    ));
                  } else {
                    final urlPath = paper['file_url'];
                    if (urlPath != null) {
                      final uri = Uri.parse('https://revisit-humongous-wiry.ngrok-free.dev$urlPath');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    }
                  }
                },
              ),
              const SizedBox(width: 8),
              Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.primary : AppColors.divider),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildUploadTab() {
    return SingleChildScrollView(
      child: Column(children: [
        TextField(
          controller: _titleCtrl,
          decoration: InputDecoration(
            labelText: 'Paper Title *',
            hintText: 'e.g. Board Exam 2023',
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.divider)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(
            controller: _yearCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Year (optional)',
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.divider)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            ),
          )),
          const SizedBox(width: 12),
          Expanded(child: TextField(
            controller: _examTypeCtrl,
            decoration: InputDecoration(
              labelText: 'Exam Type (optional)',
              hintText: 'e.g. CBSE',
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.divider)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            ),
          )),
        ]),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _uploading ? null : _pickAndUpload,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: _uploading
                ? const Column(children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Uploading…', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ])
                : Column(children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryLight.withOpacity(0.1),
                      radius: 24,
                      child: const Icon(Icons.upload, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    const Text('Tap to select PDF', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    const Text('PDF format only', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(children: List.generate(5, (i) => Expanded(
        child: Container(
          margin: EdgeInsets.only(right: i == 4 ? 0 : 8),
          height: 4,
          decoration: BoxDecoration(
            color: i <= 2 ? AppColors.primary : AppColors.divider,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ))),
    );
  }
}
