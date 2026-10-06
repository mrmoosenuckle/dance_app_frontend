class Child {
  final String name;
  const Child({required this.name});

  factory Child.fromJson(Map<String, dynamic> json) =>
      Child(name: json['name'] as String);
}
