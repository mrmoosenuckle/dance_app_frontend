class Child {
  final String id;
  final String name;
  const Child({required this.id, required this.name});

  factory Child.fromJson(Map<String, dynamic> json) =>
      Child(id: json['id'].toString(), name: json['name'] as String);
}
