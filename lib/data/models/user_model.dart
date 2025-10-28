

class UserModel {
  final int id;
  final String name;
  final String email;
  final String password;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ,
      email: json['email'] ,
      password: json['password'] ,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
