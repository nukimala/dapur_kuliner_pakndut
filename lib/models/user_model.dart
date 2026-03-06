class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // e.g., 'admin' or 'buyer'

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
  });

  // Convert UserModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
    };
  }

  // Create a UserModel from a Firestore Document
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'buyer',
    );
  }
}
