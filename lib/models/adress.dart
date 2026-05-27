class Adress {
  final String userId;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  Adress({
    required this.userId,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

  factory Adress.fromJson(Map<String, dynamic> json) {
    return Adress(
      userId: json['userId'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zipCode'] as String,
      country: json['country'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
    };
  }
}