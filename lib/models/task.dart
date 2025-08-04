class Task {
  final String name;
  final String description;
  final String month;
  final String day;

  Task({
    required this.name,
    required this.description,
    required this.month,
    required this.day,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'month': month,
        'day': day,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        name: json['name'] as String,
        description: json['description'] as String,
        month: json['month'] as String,
        day: json['day'] as String,
      );
}