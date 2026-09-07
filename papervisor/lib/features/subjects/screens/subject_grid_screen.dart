import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../services/book_service.dart';
import '../../../../services/subject_service.dart';
import '../widgets/subject_card.dart';
import 'subject_detail_screen.dart';

class SubjectGridScreen extends StatefulWidget {
  final Map<String, dynamic> workspace;

  const SubjectGridScreen({Key? key, required this.workspace}) : super(key: key);

  @override
  State<SubjectGridScreen> createState() => _SubjectGridScreenState();
}

class _SubjectGridScreenState extends State<SubjectGridScreen> {
  final SubjectService _subjectService = SubjectService();
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = true;
  String? _error;

  final List<int> _paletteIcon = [0xFF4F46E5, 0xFF059669, 0xFF9333EA, 0xFFD97706, 0xFFDC2626];

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await _subjectService.getSubjects(widget.workspace['id']);

      // Fetch book counts in parallel for all subjects
      final bookService = BookService();
      final bookCounts = await Future.wait(
        list.map((s) async {
          try {
            final books = await bookService.getBooks(s['id']);
            return books.length;
          } catch (_) {
            return 0;
          }
        }),
      );

      final enriched = list.asMap().entries.map((entry) {
        return {
          ...entry.value,
          'bookCount': bookCounts[entry.key],
          'paperCount': 0, // no papers endpoint yet
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _subjects = enriched;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Workspace', style: theme.textTheme.bodySmall),
            Text(widget.workspace['name'], style: theme.textTheme.titleLarge),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_error!, style: const TextStyle(color: AppColors.error)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchSubjects,
                            child: const Text('Retry'),
                          )
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.15,
                      ),
                      itemCount: _subjects.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _subjects.length) {
                          return GestureDetector(
                            onTap: () {
                              AppBottomSheet.showAddSubject(
                                context,
                                workspaceId: widget.workspace['id'],
                                onSuccess: _fetchSubjects,
                              );
                            },
                            child: _DashedBorderBox(
                              borderRadius: 20,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add, color: AppColors.primary),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Add Subject',
                                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final subject = _subjects[index];
                        final subjectData = {
                          ...subject,
                          'iconColor': _paletteIcon[index % _paletteIcon.length],
                          // bookCount and paperCount already enriched in _fetchSubjects
                        };

                        return SubjectCard(
                          subject: subjectData,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SubjectDetailScreen(subject: subjectData, workspace: widget.workspace),
                              ),
                            ).then((_) => _fetchSubjects());
                          },
                          onEdit: () {
                            AppBottomSheet.showEditSubject(
                              context,
                              subject: subjectData,
                              onSuccess: _fetchSubjects,
                            );
                          },
                          onDelete: () {
                            AppBottomSheet.showDeleteConfirm(
                              context,
                              title: 'Delete Subject',
                              message: 'Are you sure you want to delete "${subjectData['name']}"? All books and papers inside will be permanently deleted.',
                              onDelete: () async {
                                await _subjectService.deleteSubject(subjectData['id']);
                                _fetchSubjects();
                              },
                            );
                          },
                        );
                      },
                    ),
        ),
      ),
    );
  }
}

/// Shared dashed rounded-border box using CustomPaint.
class _DashedBorderBox extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;

  const _DashedBorderBox({
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.divider,
    this.strokeWidth = 1.5,
    this.dashLength = 6,
    this.dashGap = 4,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        borderRadius: borderRadius,
        color: color,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        dashGap: dashGap,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final double borderRadius;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;

  _DashedBorderPainter({
    required this.borderRadius,
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.borderRadius != borderRadius;
}
