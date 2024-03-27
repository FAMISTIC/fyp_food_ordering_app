class AppUser {
  final String uid;
  final String email; // Add email property
  late final String name;
  late final String phone;
  late final String imageLink;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.imageLink,
  });
  
}