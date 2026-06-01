class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String address;
  final bool isAdmin;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.address,
    required this.isAdmin,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'isAdmin': isAdmin,
    };
  }
}