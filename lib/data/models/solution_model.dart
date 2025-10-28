class SolutionModel {
  final int id;
  final int userId;
  final String summary;
  final String problem;
  final String solution;
  final List<String> reference;
  final DateTime createdAt;

  SolutionModel({
    required this.id,
    required this.userId,
    required this.summary,
    required this.problem,
    required this.solution,
    required this.reference,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'summary': summary,
      'problem': problem,
      'solution': solution,
      'reference': reference.join(', '),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SolutionModel.fromJson(Map<String, dynamic> json) {
    List<String> references =
        List<String>.from((json['reference'] as String).split(', '));
    if (references.length == 1) {
      if (references.first == '') {
        references = [];
      }
    }
    return SolutionModel(
      id: json['id'],
      userId: json['user_id'],
      summary: json['summary'],
      problem: json['problem'],
      solution: json['solution'],
      reference: references,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, String> toJsonRequest() {
    return {
      'id': id.toString(),
      'user_id': userId.toString(),
      'summary': summary,
      'problem': problem,
      'solution': solution,
      'reference': reference.join(', '),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
