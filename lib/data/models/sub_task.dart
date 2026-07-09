class SubTask {
  SubTask({required this.title, this.isCompleted = false, String? id})
      : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  final String id;
  final String title;
  final bool isCompleted;

  SubTask copyWith({String? title, bool? isCompleted}) => SubTask(
        id: id,
        title: title ?? this.title,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };

  factory SubTask.fromJson(Map<String, dynamic> json) => SubTask(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}
