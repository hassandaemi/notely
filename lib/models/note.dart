const String tableNotes = 'notes';

class Note {
  final int? id;
  final String? title;
  final String? description;
  final bool isPinned; // New field for pinning

  const Note({
    this.id,
    this.title,
    this.description,
    this.isPinned = false, // Default value is false
  });

  Note copy({
    int? id,
    String? title,
    String? description,
    bool? isPinned, // Add isPinned to copy method
  }) =>
      Note(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        isPinned: isPinned ?? this.isPinned, // Update isPinned
      );

  Map<String, Object?> toJson() => {
        NotesField.id: id,
        NotesField.title: title,
        NotesField.description: description,
        NotesField.isPinned: isPinned ? 1 : 0, // Store as int in DB
      };

  static Note fromJson(Map<String, Object?> json) => Note(
        id: json[NotesField.id] as int?,
        title: json[NotesField.title] as String?,
        description: json[NotesField.description] as String?,
        isPinned: (json[NotesField.isPinned] as int?) == 1
            ? true
            : false, // Convert to bool
      );
}

class NotesField {
  static final List<String> values = [id, title, description, isPinned];

  static const String id = '_id';
  static const String title = '_title';
  static const String description = '_description';
  static const String isPinned = '_isPinned'; // New field
}
