class Patient {
  final String id;
  final String name;
  final String drugName;
  final String regimen;

  Patient(
      {required this.id,
      required this.name,
      required this.drugName,
      required this.regimen});

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['patient Name'],
      drugName: json['Drug Name'] ?? '',
      regimen: json['regimen'] ?? '',
    );
  }
}
