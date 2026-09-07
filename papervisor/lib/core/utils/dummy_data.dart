class DummyData {
  // We'll populate these when we build the models.
  static const List<Map<String, dynamic>> workspaces = [
    {
      'id': '1',
      'name': 'Class 8th',
      'subjectCount': 5,
      'paperCount': 12,
      'color': 0xFFE0E7FF, // Light purple
      'iconColor': 0xFF4F46E5,
    },
    {
      'id': '2',
      'name': 'Class 10th',
      'subjectCount': 4,
      'paperCount': 8,
      'color': 0xFFD1FAE5, // Light green
      'iconColor': 0xFF059669,
    },
    {
      'id': '3',
      'name': 'Class 12th',
      'subjectCount': 6,
      'paperCount': 15,
      'color': 0xFFF3E8FF, // Light purple
      'iconColor': 0xFF9333EA,
    },
  ];

  static const List<Map<String, dynamic>> subjects = [
    {
      'id': 's1',
      'name': 'Mathematics',
      'bookCount': 2,
      'paperCount': 4,
      'iconColor': 0xFF4F46E5, // Purple
    },
    {
      'id': 's2',
      'name': 'Science',
      'bookCount': 3,
      'paperCount': 6,
      'iconColor': 0xFF059669, // Green
    },
    {
      'id': 's3',
      'name': 'English',
      'bookCount': 1,
      'paperCount': 3,
      'iconColor': 0xFF9333EA, // Purple
    },
    {
      'id': 's4',
      'name': 'Social Studies',
      'bookCount': 2,
      'paperCount': 2,
      'iconColor': 0xFFD97706, // Orange
    },
    {
      'id': 's5',
      'name': 'Hindi',
      'bookCount': 1,
      'paperCount': 1,
      'iconColor': 0xFFDC2626, // Red
    },
  ];

  static const List<Map<String, dynamic>> books = [
    {
      'id': 'b1',
      'name': 'NCERT Mathematics Part I',
      'chaptersCompleted': 5,
      'totalChapters': 8,
    },
    {
      'id': 'b2',
      'name': 'RD Sharma — Class 8',
      'chaptersCompleted': 12,
      'totalChapters': 12,
    }
  ];

  static const List<Map<String, dynamic>> chapters = [
    {'id': 'c1', 'name': 'Rational Numbers', 'status': 'completed'},
    {'id': 'c2', 'name': 'Linear Equations in One Variable', 'status': 'completed'},
    {'id': 'c3', 'name': 'Understanding Quadrilaterals', 'status': 'pending'},
    {'id': 'c4', 'name': 'Practical Geometry', 'status': 'pending'},
    {'id': 'c5', 'name': 'Data Handling', 'status': 'completed'},
    {'id': 'c6', 'name': 'Squares and Square Roots', 'status': 'completed'},
    {'id': 'c7', 'name': 'Cubes and Cube Roots', 'status': 'completed'},
    {'id': 'c8', 'name': 'Comparing Quantities', 'status': 'uploading', 'progress': 0.8},
  ];

  static const List<Map<String, dynamic>> papers = [
    {
      'id': 'p1',
      'name': 'Mid-term Examination 2024',
      'date': '15 Oct 2024',
      'marks': 80,
      'difficulty': 'Medium',
    },
    {
      'id': 'p2',
      'name': 'Unit Test – Chapters 3–5',
      'date': '22 Sep 2024',
      'marks': 30,
      'difficulty': 'Easy',
    },
    {
      'id': 'p3',
      'name': 'Final Annual Examination',
      'date': '5 Mar 2025',
      'marks': 100,
      'difficulty': 'Hard',
    },
  ];
}
