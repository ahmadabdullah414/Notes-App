class Note {
  final String id;
  final String title;
  final String content;
  final String date;
  final String priority; // Added priority field

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.priority, // Required priority
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      date: json['date'],
      priority: json['priority'], // Fetch priority from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
      'priority': priority, // Save priority to JSON
    };
  }
}
