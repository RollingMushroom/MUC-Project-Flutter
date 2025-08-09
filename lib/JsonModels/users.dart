class Users {
  int? usrId;
  String name;
  String email;
  int? phone;
  String username;
  String password;

  Users({
    this.usrId,
    required this.name,
    required this.email,
    required this.phone,
    required this.username,
    required this.password,
  });

  factory Users.fromMap(Map<String, dynamic> json) => Users(
        usrId: json["usrId"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        username: json["username"],
        password: json["password"],
      );

  Map<String, dynamic> toMap() {
    return {
      'usrId': usrId,
      'name': name,
      'email': email,
      'phone': phone,
      'username': username,
      'password': password,
    };
  }
}
