class Admin {
  int? adminId;
  String username;
  String password;

  Admin({
    this.adminId,
    required this.username,
    required this.password,
  });

  factory Admin.fromMap(Map<String, dynamic> json) => Admin(
    adminId: json["adminId"],
    username: json["username"],
    password: json["password"],
  );

  Map<String, dynamic> toMap() {
    return {
      'adminId': adminId,
      'username': username,
      'password': password,
    };
  }
}
