class EntryImage {
  const EntryImage({
    this.id,
    required this.entryId,
    required this.imagePath,
  });

  final int? id;
  final int entryId;
  final String imagePath;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'entry_id': entryId,
      'image_path': imagePath,
    };
  }

  factory EntryImage.fromMap(Map<String, Object?> map) {
    return EntryImage(
      id: map['id'] as int?,
      entryId: map['entry_id'] as int,
      imagePath: map['image_path'] as String,
    );
  }
}
