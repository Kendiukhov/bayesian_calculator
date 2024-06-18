
class Event {
  String name;
  double probability;
  bool? resolved;
  DateTime? resolutionDeadline;
  List<String> tags;
  String importance;
  String? description;

  Event({
    required this.name,
    required this.probability,
    this.resolved,
    this.resolutionDeadline,
    this.tags = const [],
    this.importance = 'Medium',
    this.description,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      name: json['name'],
      probability: json['probability'],
      resolved: json['resolved'],
      resolutionDeadline: json['resolutionDeadline'] != null ? DateTime.parse(json['resolutionDeadline']) : null,
      tags: List<String>.from(json['tags']),
      importance: json['importance'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'probability': probability,
      'resolved': resolved,
      'resolutionDeadline': resolutionDeadline?.toIso8601String(),
      'tags': tags,
      'importance': importance,
      'description': description,
    };
  }
}
