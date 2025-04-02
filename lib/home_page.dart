import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'car_model.dart'; 
import 'car_detail_page.dart';
import 'user_helper.dart';
import 'profile_page.dart';
import 'dealer_profile_page.dart';

const String baseUrl = 'http://10.0.2.2:5000/api'; 

class CarService {
  final http.Client _client = http.Client();

  Future<List<Car>> getCars() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/cars'));
      
      if (response.statusCode == 200) {
        final List<dynamic> carsJson = jsonDecode(response.body);
        return carsJson.map((car) => Car.fromJson(car)).toList();
      } else {
        throw Exception('Failed to load cars: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching cars: $error');
      throw Exception('Failed to load cars: $error');
    }
  }

  Future<List<Car>> getRecommendedCars() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/cars/recommended'));
      
      if (response.statusCode == 200) {
        final List<dynamic> carsJson = jsonDecode(response.body);
        return carsJson.map((car) => Car.fromJson(car)).toList();
      } else {
        throw Exception('Failed to load recommended cars: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching recommended cars: $error');
      throw Exception('Failed to load recommended cars: $error');
    }
  }

  Future<List<Car>> searchCars(String query) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/cars/search?query=$query'),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> carsJson = jsonDecode(response.body);
        return carsJson.map((car) => Car.fromJson(car)).toList();
      } else {
        throw Exception('Failed to search cars: ${response.statusCode}');
      }
    } catch (error) {
      print('Error searching cars: $error');
      throw Exception('Failed to search cars: $error');
    }
  }

  void dispose() {
    _client.close();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CarService _carService = CarService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Car> _cars = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRecommendedCars();
  }

  Future<void> _loadRecommendedCars() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cars = await _carService.getRecommendedCars();
      setState(() {
        _cars = cars;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load cars');
    }
  }

  Future<void> _searchCars(String query) async {
    if (query.isEmpty) {
      _loadRecommendedCars();
      return;
    }

    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });

    try {
      final cars = await _carService.searchCars(query);
      setState(() {
        _cars = cars;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      _showErrorSnackBar('Failed to search cars');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'TUNIBET',
          style: TextStyle(
            color: Color(0xFF56021F),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.black),
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            final userId = await UserHelper.getUserId();
            final String? userType = prefs.getString("userType");
            if(!mounted) return;
            if (userId != null && userId.isNotEmpty){
              
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage(userId: userId)),
                );
            
          }else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User not authenticated')),
              );
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'search for a car',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        onSubmitted: (value) {
                          _searchCars(value);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune, color: Colors.black),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    _isSearching ? 'Search results for "$_searchQuery"' : 'recommended',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_isSearching) 
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        _loadRecommendedCars();
                      },
                      child: const Text('Clear'),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Loading indicator or car grid
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF56021F),
                      ),
                    )
                  : _cars.isEmpty
                      ? const Center(
                          child: Text(
                            'No cars found',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _cars.length,
                          itemBuilder: (context, index) {
                            final car = _cars[index];
                            return CarCard(car: car);
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _carService.dispose();
    super.dispose();
  }
}

class CarCard extends StatelessWidget {
  final Car car;

  const CarCard({
    Key? key,
    required this.car,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the car detail page when the card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarDetailPage(car: car),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Main image
                    if (car.imageUrl.isNotEmpty)
                      Image.network(
                        car.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / 
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: const Color(0xFF800020),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.directions_car,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.directions_car,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                      
                    // Image count indicator
                    if (car.images.length > 1)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${car.images.length} photos',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Car Details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${car.make} ${car.model}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${car.year} • ${car.fuelType ?? ""}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Initial bet : ${car.price.toStringAsFixed(0)} DT',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}