import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../models/paper_wizard_state.dart';
import 'paper_wizard_step_reference.dart';

class PaperWizardStepMarks extends StatefulWidget {
  final Map<String, dynamic> subject;
  final PaperWizardState state;

  const PaperWizardStepMarks({Key? key, required this.subject, required this.state}) : super(key: key);

  @override
  State<PaperWizardStepMarks> createState() => _PaperWizardStepMarksState();
}

class _PaperWizardStepMarksState extends State<PaperWizardStepMarks> {
  late final TextEditingController _marksController;

  @override
  void initState() {
    super.initState();
    _marksController = TextEditingController(text: widget.state.totalMarks.toString());
  }

  @override
  void dispose() {
    _marksController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final v = int.tryParse(_marksController.text.trim());
    return v != null && v > 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Step 2 of 5', style: theme.textTheme.bodySmall),
          Text('Marks', style: theme.textTheme.titleLarge),
        ]),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(children: [
          _buildProgressBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('TOTAL MARKS', style: theme.textTheme.labelLarge?.copyWith(fontSize: 12, letterSpacing: 1.2)),
                const SizedBox(height: 12),
                TextField(
                  controller: _marksController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'e.g. 80',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'The total marks of the paper. AI will distribute marks across sections and questions.',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                // Quick presets
                Text('QUICK PRESETS', style: theme.textTheme.labelLarge?.copyWith(fontSize: 12, letterSpacing: 1.2)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  children: [20, 40, 50, 60, 80, 100].map((v) {
                    final isSelected = _marksController.text == v.toString();
                    return GestureDetector(
                      onTap: () => setState(() => _marksController.text = v.toString()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
                        ),
                        child: Text(
                          '$v',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: PrimaryButton(
              text: 'Continue',
              icon: const Icon(Icons.arrow_forward),
              onPressed: _isValid ? () {
                widget.state.totalMarks = int.parse(_marksController.text.trim());
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => PaperWizardStepReference(subject: widget.subject, state: widget.state),
                ));
              } : null,
            ),
          ),
        ]),
      ),
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
            color: i <= 1 ? AppColors.primary : AppColors.divider,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ))),
    );
  }
}
