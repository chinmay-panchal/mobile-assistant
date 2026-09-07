import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/subject_service.dart';
import '../../../../services/workspace_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../explore/screens/explore_screen.dart';
import '../../subjects/screens/subject_grid_screen.dart';
import '../widgets/workspace_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WorkspaceService _workspaceService = WorkspaceService();
  List<Map<String, dynamic>> _workspaces = [];
  bool _isLoading = true;
  String? _error;

  final List<int> _paletteBg = [0xFFE0E7FF, 0xFFD1FAE5, 0xFFF3E8FF, 0xFFFEF3C7, 0xFFFCE7F3];
  final List<int> _paletteIcon = [0xFF4F46E5, 0xFF059669, 0xFF9333EA, 0xFFD97706, 0xFFDB2777];

  @override
  void initState() {
    super.initState();
    _fetchWorkspaces();
  }

  Future<void> _fetchWorkspaces() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await _workspaceService.getWorkspaces();

      // Fetch subject counts in parallel for all workspaces
      final subjectService = SubjectService();
      final subjectCounts = await Future.wait(
        list.map((ws) async {
          try {
            final subjects = await subjectService.getSubjects(ws['id']);
            return subjects.length;
          } catch (_) {
            return 0;
          }
        }),
      );

      final enriched = list.asMap().entries.map((entry) {
        return {
          ...entry.value,
          'subjectCount': subjectCounts[entry.key],
          'paperCount': 0, // no papers endpoint yet
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _workspaces = enriched;
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning 👋',
                        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'My Workspaces',
                        style: theme.textTheme.headlineLarge,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ExploreScreen(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          backgroundColor: AppColors.primaryLight.withOpacity(0.1),
                          child: ClipOval(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Positioned(
                                    bottom: 8,
                                    child: Icon(Icons.search_rounded,
                                        color: AppColors.primary, size: 20),
                                  ),
                                  const Positioned(
                                    top: 7,
                                    right: 7,
                                    child: Icon(Icons.auto_awesome,
                                        color: AppColors.primary, size: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: AppColors.error.withOpacity(0.1),
                        child: IconButton(
                          icon: const Icon(Icons.logout, color: AppColors.error, size: 20),
                          tooltip: 'Logout',
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Logout'),
                                content: const Text('Are you sure you want to logout?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Logout', style: TextStyle(color: AppColors.error)),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true && mounted) {
                              await AuthService().logout();
                              if (mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
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
                                  onPressed: _fetchWorkspaces,
                                  child: const Text('Retry'),
                                )
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _workspaces.length + 1,
                            itemBuilder: (context, index) {
                              if (index == _workspaces.length) {
                                return GestureDetector(
                                  onTap: () {
                                    AppBottomSheet.showAddWorkspace(
                                      context,
                                      onSuccess: _fetchWorkspaces,
                                    );
                                  },
                                  child: _DashedBorderBox(
                                    borderRadius: 20,
                                    padding: const EdgeInsets.all(24),
                                    child: Row(
                                      children: [
                                        const CircleAvatar(
                                          backgroundColor: AppColors.background,
                                          child: Icon(Icons.add, color: AppColors.primary),
                                        ),
                                        const SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'New Workspace',
                                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            Text(
                                              'Create a class or course',
                                              style: TextStyle(color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              final workspace = _workspaces[index];
                              final colorIndex = index % _paletteBg.length;
                              final workspaceData = {
                                ...workspace,
                                'color': _paletteBg[colorIndex],
                                'iconColor': _paletteIcon[colorIndex],
                                // subjectCount and paperCount already enriched in _fetchWorkspaces
                              };

                              return WorkspaceCard(
                                workspace: workspaceData,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SubjectGridScreen(workspace: workspaceData),
                                    ),
                                  ).then((_) => _fetchWorkspaces());
                                },
                                onEdit: () {
                                  AppBottomSheet.showEditWorkspace(
                                    context,
                                    workspace: workspaceData,
                                    onSuccess: _fetchWorkspaces,
                                  );
                                },
                                onDelete: () {
                                  AppBottomSheet.showDeleteConfirm(
                                    context,
                                    title: 'Delete Workspace',
                                    message: 'Are you sure you want to delete "${workspaceData['name']}"? All subjects and papers inside will be permanently deleted.',
                                    onDelete: () async {
                                      await _workspaceService.deleteWorkspace(workspaceData['id']);
                                      _fetchWorkspaces();
                                    },
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppBottomSheet.showAddWorkspace(
            context,
            onSuccess: _fetchWorkspaces,
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

/// A container that draws a dashed rounded border using CustomPaint.
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
