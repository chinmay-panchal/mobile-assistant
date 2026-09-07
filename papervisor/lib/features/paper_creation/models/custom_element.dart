import 'dart:typed_data';

enum CustomElementType {
  text,
  image,
}

class CustomElement {
  final String id;
  final CustomElementType type;
  
  // Coordinates as relative percentages (0.0 to 1.0)
  // so they scale perfectly regardless of screen size or PDF size.
  double relativeX;
  double relativeY;
  
  // Multi-page tracking and scaling
  int pageIndex;
  double scale;
  
  // For text elements
  String? text;
  double fontSize;
  
  // For image elements
  Uint8List? imageBytes;
  
  CustomElement({
    required this.id,
    required this.type,
    required this.relativeX,
    required this.relativeY,
    this.pageIndex = 0,
    this.scale = 1.0,
    this.text,
    this.fontSize = 14.0,
    this.imageBytes,
  });

  CustomElement copyWith({
    double? relativeX,
    double? relativeY,
    int? pageIndex,
    double? scale,
    String? text,
    double? fontSize,
    Uint8List? imageBytes,
  }) {
    return CustomElement(
      id: id,
      type: type,
      relativeX: relativeX ?? this.relativeX,
      relativeY: relativeY ?? this.relativeY,
      pageIndex: pageIndex ?? this.pageIndex,
      scale: scale ?? this.scale,
      text: text ?? this.text,
      fontSize: fontSize ?? this.fontSize,
      imageBytes: imageBytes ?? this.imageBytes,
    );
  }
}
