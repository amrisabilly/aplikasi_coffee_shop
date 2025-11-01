class Registrasi {
  final String full_name;
  final String email;
  final String password;

  Registrasi({
    required this.full_name,
    required this.email,
    required this.password,
  });

  factory Registrasi.fromJson(Map<String, dynamic> json) {
    return Registrasi(
      full_name: json['full_name'],
      email: json['email'],
      password: json['password'],
    );
  }
}
