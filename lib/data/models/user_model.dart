class UserModel {
  final int id;
  final String name;
  final String email;
  final String password;
  final String? profilePicture;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.profilePicture,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'profile_picture': profilePicture,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      profilePicture: json['profile_picture'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}