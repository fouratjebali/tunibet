class Car {
  final String id;
  final String make;
  final String model;
  final int year;
  final double price;
  final int? mileage;
  final String? fuelType;
  final String? transmission;
  final int? horsepower;
  final String? bodyType;
  final String? color;
  final String? condition;
  final String? description;
  final String? location;
  final String imageUrl; 
  final List<String> images;

  Car({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.price,
    this.mileage,
    this.fuelType,
    this.transmission,
    this.horsepower,
    this.bodyType,
    this.color,
    this.condition,
    this.description,
    this.location,
    required this.imageUrl,
    required this.images,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    List<String> imagesList = [];
    if (json['images'] != null) {
      imagesList = List<String>.from(json['images']);
    }

    String mainImage = json['image_url'] ?? (imagesList.isNotEmpty ? imagesList[0] : '');

    return Car(
      id: json['id'].toString(),
      make: json['make'],
      model: json['model'],
      year: json['year'],
      price: double.parse(json['price'].toString()),
      mileage: json['mileage'],
      fuelType: json['fuel_type'],
      transmission: json['transmission'],
      horsepower: json['horsepower'],
      bodyType: json['body_type'],
      color: json['color'],
      condition: json['condition'],
      description: json['description'],
      location: json['location'],
      imageUrl: mainImage,
      images: imagesList,
    );
  }
}