import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tunibet/dealer_profile_page.dart';
import 'package:tunibet/notification.dart';
import 'car_model.dart';
import 'place_bet_page.dart';

class DealerHomePage extends StatefulWidget {
  final String dealerId;

  const DealerHomePage({Key? key, required this.dealerId}) : super(key: key);

  @override
  State<DealerHomePage> createState() => _DealerHomePageState();
}

class _DealerHomePageState extends State<DealerHomePage> {
  List<Car> _dealerCars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDealerCars();
  }

  Future<void> _fetchDealerCars() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Fetching cars for dealer ID: ${widget.dealerId}');
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/dealercars/${widget.dealerId}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> carsJson = jsonDecode(response.body);
        setState(() {
          _dealerCars = carsJson.map((car) => Car.fromJson(car)).toList();
          _isLoading = false;
        });
      } else {
        print('Failed to load dealer cars: ${response.body}');
        throw Exception('Failed to load dealer cars');
      }
    } catch (e) {
      print('Error fetching dealer cars: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load cars')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Dealer Dashboard',
          style: TextStyle(
            color: Color(0xFF56021F),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DealerProfilePage(dealerId: widget.dealerId, userId: widget.dealerId),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to a page to post a new car
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF56021F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 60,
                child: const Center(
                  child: Text(
                    'Post a New Car',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Cars',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _dealerCars.isEmpty
                      ? const Center(child: Text('No cars posted yet'))
                      : ListView.builder(
                          itemCount: _dealerCars.length,
                          itemBuilder: (context, index) {
                            final car = _dealerCars[index];
                            return CarCard(
                              car: car,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlaceBetPage(
                                      car: car,
                                      isDealer: true,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback onTap;

  const CarCard({Key? key, required this.car, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(car.imageUrl ?? 'https://via.placeholder.com/100'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${car.make} ${car.model}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Price: ${car.price} DT',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}