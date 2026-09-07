import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../services/workspace_service.dart';
import '../../../../services/subject_service.dart';
import '../../../../services/book_service.dart';
import '../../../../services/chapter_service.dart';
import '../../../../services/document_service.dart';
import 'package:file_picker/file_picker.dart';

class AppBottomSheet {
  static void showAddWorkspace(BuildContext context, {required VoidCallback onSuccess}) {
    final nameController = TextEditingController();
    final service = WorkspaceService();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('New Workspace', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Create a class or course workspace (e.g. Class 10th)', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: nameController,
                    label: 'WORKSPACE NAME',
                    hintText: 'e.g. Class 10th Physics',
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          text: 'Cancel',
                          isSecondary: true,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          text: isLoading ? 'Creating...' : 'Create Workspace',
                          onPressed: isLoading ? () {} : () async {
                            final name = nameController.text.trim();
                            if (name.isEmpty) return;
                            setState(() => isLoading = true);
                            try {
                              await service.createWorkspace(name);
                              if (context.mounted) {
                                Navigator.pop(context);
                                onSuccess();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                                );
                              }
                            } finally {
                              if (context.mounted) {
                                setState(() => isLoading = false);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showAddSubject(BuildContext context, {required String workspaceId, required VoidCallback onSuccess}) {
    final nameController = TextEditingController();
    final service = SubjectService();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Add Subject', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Enter subject name for this workspace', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: nameController,
                    label: 'SUBJECT NAME',
                    hintText: 'e.g. Mathematics',
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          text: 'Cancel',
                          isSecondary: true,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          text: isLoading ? 'Adding...' : 'Add Subject',
                          onPressed: isLoading ? () {} : () async {
                            final name = nameController.text.trim();
                            if (name.isEmpty) return;
                            setState(() => isLoading = true);
                            try {
                              await service.createSubject(workspaceId, name, name.toUpperCase());
                              if (context.mounted) {
                                Navigator.pop(context);
                                onSuccess();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                                );
                              }
                            } finally {
                              if (context.mounted) {
                                setState(() => isLoading = false);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showAddBook(BuildContext context, {required String subjectId, required VoidCallback onSuccess}) {
    final nameController = TextEditingController();
    final service = BookService();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Add New Book', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Enter the book name', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: nameController,
                    label: 'BOOK NAME',
                    hintText: 'e.g. NCERT Science Part II',
                  ),

                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          text: 'Cancel',
                          isSecondary: true,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          text: isLoading ? 'Adding...' : 'Add Book',
                          onPressed: isLoading ? () {} : () async {
                            final name = nameController.text.trim();
                            if (name.isEmpty) return;
                            setState(() => isLoading = true);
                            try {
                              await service.createBook(subjectId, name);
                              if (context.mounted) {
                                Navigator.pop(context);
                                onSuccess();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                                );
                              }
                            } finally {
                              if (context.mounted) {
                                setState(() => isLoading = false);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showAddChapter(BuildContext context, {required String bookId, required int nextChapterNum, required bool hasWholeBookPdf, required VoidCallback onSuccess}) {
    final titleController = TextEditingController();
    final numberController = TextEditingController(text: nextChapterNum.toString());
    final startPageController = TextEditingController();
    final endPageController = TextEditingController();
    final chapterService = ChapterService();
    final documentService = DocumentService();
    bool isLoading = false;
    PlatformFile? selectedFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Add Chapter', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Enter chapter details and optionally upload a PDF', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: numberController,
                    label: 'CHAPTER NUMBER',
                    hintText: 'e.g. 1',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: titleController,
                    label: 'CHAPTER NAME',
                    hintText: 'e.g. Mensuration',
                  ),
                  const SizedBox(height: 16),
                  if (hasWholeBookPdf) ...[
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: startPageController,
                            label: 'START PAGE (OPTIONAL)',
                            hintText: 'e.g. 1',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            controller: endPageController,
                            label: 'END PAGE (OPTIONAL)',
                            hintText: 'e.g. 20',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    'CHAPTER PDF (OPTIONAL)',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final res = await FilePicker.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                        withData: false,
                        withReadStream: false,
                      );
                      if (res.isNotEmpty) {
                        setState(() => selectedFile = res.first);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: selectedFile != null
                            ? AppColors.successLight.withOpacity(0.3)
                            : AppColors.primaryLight.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selectedFile != null
                              ? AppColors.success
                              : AppColors.primaryLight.withOpacity(0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              selectedFile != null ? Icons.check_circle : Icons.upload,
                              color: selectedFile != null ? AppColors.success : AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            selectedFile != null ? selectedFile!.name : 'Tap to upload PDF',
                            style: TextStyle(
                              color: selectedFile != null ? AppColors.success : AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (selectedFile == null)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text('Chapter content · PDF only', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          text: 'Cancel',
                          isSecondary: true,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          text: isLoading ? 'Adding...' : 'Add Chapter',
                          onPressed: isLoading ? () {} : () async {
                            final title = titleController.text.trim();
                            final chapterNumStr = numberController.text.trim();
                            if (title.isEmpty || chapterNumStr.isEmpty) return;

                            final chapterNum = int.tryParse(chapterNumStr) ?? nextChapterNum;
                            final startPage = int.tryParse(startPageController.text.trim());
                            final endPage = int.tryParse(endPageController.text.trim());
                            
                            setState(() => isLoading = true);
                            try {
                              final chapter = await chapterService.createChapter(
                                bookId, 
                                chapterNum, 
                                title, 
                                startPage: startPage, 
                                endPage: endPage,
                              );
                              if (selectedFile != null && selectedFile!.path != null) {
                                await documentService.uploadDocument(
                                  filePath: selectedFile!.path!,
                                  bookId: bookId,
                                  chapterId: chapter['id'],
                                );
                              }
                              if (context.mounted) {
                                Navigator.pop(context);
                                onSuccess();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                                );
                              }
                            } finally {
                              if (context.mounted) {
                                setState(() => isLoading = false);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ),
            );
          },
        );
      },
    );
  }

  static void showEditChapter(
    BuildContext context, {
    required Map<String, dynamic> chapter,
    required bool hasWholeBookPdf,
    required VoidCallback onSuccess,
  }) {
    final titleController = TextEditingController(text: chapter['name']);
    final numberController = TextEditingController(text: chapter['chapter_number'].toString());
    final startPageController = TextEditingController(text: chapter['start_page']?.toString() ?? '');
    final endPageController = TextEditingController(text: chapter['end_page']?.toString() ?? '');
    final chapterService = ChapterService();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Edit Chapter', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Update chapter details', style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: numberController,
                      label: 'CHAPTER NUMBER',
                      hintText: 'e.g. 1',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: titleController,
                      label: 'CHAPTER NAME',
                      hintText: 'e.g. Mensuration',
                    ),
                    const SizedBox(height: 16),
                    if (hasWholeBookPdf) ...[
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: startPageController,
                              label: 'START PAGE (OPTIONAL)',
                              hintText: 'e.g. 1',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: endPageController,
                              label: 'END PAGE (OPTIONAL)',
                              hintText: 'e.g. 20',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            text: 'Cancel',
                            isSecondary: true,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: PrimaryButton(
                            text: isLoading ? 'Saving...' : 'Save',
                            onPressed: isLoading ? () {} : () async {
                              final title = titleController.text.trim();
                              final chapterNumStr = numberController.text.trim();
                              if (title.isEmpty || chapterNumStr.isEmpty) return;
                              final chapterNum = int.tryParse(chapterNumStr) ?? chapter['chapter_number'];
                              final startPage = int.tryParse(startPageController.text.trim());
                              final endPage = int.tryParse(endPageController.text.trim());
                              
                              setState(() => isLoading = true);
                              try {
                                await chapterService.updateChapter(
                                  chapter['id'], 
                                  chapterNum, 
                                  title, 
                                  startPage: startPage, 
                                  endPage: endPage,
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  onSuccess();
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                                  );
                                }
                              } finally {
                                if (context.mounted) {
                                  setState(() => isLoading = false);
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static void showEditWorkspace(
    BuildContext context, {
    required Map<String, dynamic> workspace,
    required VoidCallback onSuccess,
  }) {
    final nameController = TextEditingController(text: workspace['name']);
    final service = WorkspaceService();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Edit Workspace', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Update workspace name', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: nameController,
                    label: 'WORKSPACE NAME',
                    hintText: 'e.g. Class 10th Physics',
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          text: 'Cancel',
                          isSecondary: true,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          text: isLoading ? 'Saving...' : 'Save Changes',
                          onPressed: isLoading ? () {} : () async {
                            final name = nameController.text.trim();
                            if (name.isEmpty) return;
                            setState(() => isLoading = true);
                            try {
                              await service.updateWorkspace(workspace['id'], name);
                              if (context.mounted) {
                                Navigator.pop(context);
                                onSuccess();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                                );
                              }
                            } finally {
                              if (context.mounted) {
                                setState(() => isLoading = false);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showEditSubject(
    BuildContext context, {
    required Map<String, dynamic> subject,
    required VoidCallback onSuccess,
  }) {
    final nameController = TextEditingController(text: subject['name']);
    final service = SubjectService();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Edit Subject', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Update subject name', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: nameController,
                    label: 'SUBJECT NAME',
                    hintText: 'e.g. Mathematics',
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          text: 'Cancel',
                          isSecondary: true,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          text: isLoading ? 'Saving...' : 'Save Changes',
                          onPressed: isLoading ? () {} : () async {
                            final name = nameController.text.trim();
                            if (name.isEmpty) return;
                            setState(() => isLoading = true);
                            try {
                              await service.updateSubject(subject['id'], name);
                              if (context.mounted) {
                                Navigator.pop(context);
                                onSuccess();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                                );
                              }
                            } finally {
                              if (context.mounted) {
                                setState(() => isLoading = false);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showEditBook(
    BuildContext context, {
    required Map<String, dynamic> book,
    required VoidCallback onSuccess,
  }) {
    final nameController = TextEditingController(text: book['name'] ?? book['title']);
    final service = BookService();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Edit Book', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Update book name', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: nameController,
                    label: 'BOOK NAME',
                    hintText: 'e.g. NCERT Physics',
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          text: 'Cancel',
                          isSecondary: true,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          text: isLoading ? 'Saving...' : 'Save Changes',
                          onPressed: isLoading ? () {} : () async {
                            final name = nameController.text.trim();
                            if (name.isEmpty) return;
                            setState(() => isLoading = true);
                            try {
                              await service.updateBook(book['id'], name);
                              if (context.mounted) {
                                Navigator.pop(context);
                                onSuccess();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                                );
                              }
                            } finally {
                              if (context.mounted) {
                                setState(() => isLoading = false);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showDeleteConfirm(
    BuildContext context, {
    required String title,
    required String message,
    required Future<void> Function() onDelete,
  }) {
    bool isLoading = false;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.errorLight,
                    child: const Icon(Icons.delete_outline, color: AppColors.error, size: 28),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          text: 'Cancel',
                          isSecondary: true,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  setState(() => isLoading = true);
                                  try {
                                    await onDelete();
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                                      );
                                    }
                                  } finally {
                                    if (context.mounted) {
                                      setState(() => isLoading = false);
                                    }
                                  }
                                },
                          child: Text(
                            isLoading ? 'Deleting...' : 'Delete',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
