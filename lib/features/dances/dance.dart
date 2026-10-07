class Dance {
  final String id;
  final String name;
  final String category;
  final int durationSeconds;

  const Dance({
    required this.id,
    required this.name,
    required this.category,
    required this.durationSeconds,
  });

  factory Dance.fromJson(Map<String, dynamic> json) => Dance(
    id: json['id'].toString(),
    name: json['name'] as String,
    category: (json['category'] ?? '') as String,
    durationSeconds: (json['durationSeconds'] ?? 0) as int,
  );

  /// Duration as m:ss.
  String get formattedDuration {
    final s = (durationSeconds % 60).toString().padLeft(2, '0');
    return '${durationSeconds ~/ 60}:$s';
  }
}
