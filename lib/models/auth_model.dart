class AuthModel {
  int? id_auth;
  String? UID, username, Email, password, role;
  DateTime? createdAt, updatedAt;

  AuthModel(
      {this.id_auth,
      this.UID,
      this.username,
      required this.Email,
      this.password,
      this.role,
      this.createdAt,
      this.updatedAt});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{'Email': Email};

    if (id_auth != null) {
      data['id_auth'] = id_auth;
    }

    if (UID != null) {
      data['UID'] = UID;
    }

    if (username != null) {
      data['username'] = username;
    }

    if (password != null) {
      data['password'] = password;
    }

    if (role != null) {
      data['role'] = role;
    }

    if (createdAt != null) {
      data['createdAt'] = createdAt;
    }

    if (updatedAt != null) {
      data['updatedAt'] = updatedAt;
    }
    return data;
  }

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      id_auth: json['id_auth'],
      UID: json['UID'],
      username: json['username'],
      Email: json['Email'],
      password: json['password'],
      role: json['role'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  @override
  String toString() {
    return 'AuthModel(id_auth: id_auth, UID: UID, username: username, Email: Email, role:role)';
  }
}
