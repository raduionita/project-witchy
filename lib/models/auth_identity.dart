class AuthIdentity {
  const AuthIdentity({required this.method, this.name, this.email});

  final String method;
  final String? name;
  final String? email;

  factory AuthIdentity.fromMap(Map<String, String> map) => AuthIdentity(
    method: map['method'] ?? 'email',
    name: map['name'],
    email: map['email'],
  );

  Map<String, String> toMap() => {
    'method': method,
    if (name != null && name!.isNotEmpty) 'name': name!,
    if (email != null && email!.isNotEmpty) 'email': email!,
  };
}
