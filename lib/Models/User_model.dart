class UserModel {
  final String uid;
  final String phone;
  final String online;
  final DateTime? last_seen;

  UserModel({
    required this.uid,
    required this.phone,
    required this.online,
    required this.last_seen,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['id'] ?? '',
      phone: map['phone'] ?? '',
      online: map['online'] ?? 'false',
      last_seen: map['last_seen'] != null
          ? DateTime.parse(map['last_seen'])
          : null,
    );
  }
}