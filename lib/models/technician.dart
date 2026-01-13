class Technician {
  final String id;
  final String name;
  final String phone;
  final String specialization;
  final String? email;

  Technician({
    required this.id,
    required this.name,
    required this.phone,
    required this.specialization,
    this.email,
  });
}
