import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PostCarPage extends StatefulWidget {
  final String dealerId;

  const PostCarPage({Key? key, required this.dealerId}) : super(key: key);

  @override
  _PostCarPageState createState() => _PostCarPageState();
}

class _PostCarPageState extends State<PostCarPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _carData = {
    'make': '',
    'model': '',
    'year': '',
    'price': '',
    'mileage': '',
    'fuel_type': '',
    'transmission': '',
    'horsepower': '',
    'body_type': '',
    'color': '',
    'condition': '',
    'description': '',
    'location': '',
  };

  final List<File> _selectedImages = []; 
  final ImagePicker _imagePicker = ImagePicker(); 

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _imagePicker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();
    _carData['dealer_id'] = widget.dealerId;

    try {
      final uri = Uri.parse('http://10.0.2.2:5000/api/cars'); 
      final request = http.MultipartRequest('POST', uri);

      _carData.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      for (var image in _selectedImages) {
        final imageFile = await http.MultipartFile.fromPath(
          'images', 
          image.path,
        );
        request.files.add(imageFile);
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Car posted successfully!')),
        );
        Navigator.of(context).pop(true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post car: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error submitting form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while posting the car.')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a New Car'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Make'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter car make' : null,
                  onSaved: (value) => _carData['make'] = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Model'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter car model' : null,
                  onSaved: (value) => _carData['model'] = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Year'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter car year' : null,
                  onSaved: (value) => _carData['year'] = int.parse(value!),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter car price' : null,
                  onSaved: (value) => _carData['price'] = double.parse(value!),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Mileage'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) =>
                      _carData['mileage'] = value != null && value.isNotEmpty
                          ? int.parse(value)
                          : null,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Fuel Type'),
                  items: const [
                    DropdownMenuItem(value: 'Petrol', child: Text('Petrol')),
                    DropdownMenuItem(value: 'Diesel', child: Text('Diesel')),
                    DropdownMenuItem(value: 'Electric', child: Text('Electric')),
                    DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                    DropdownMenuItem(value: 'CNG', child: Text('CNG')),
                    DropdownMenuItem(value: 'LPG', child: Text('LPG')),
                  ],
                  onChanged: (value) => _carData['fuel_type'] = value,
                  validator: (value) =>
                      value == null ? 'Select fuel type' : null,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Transmission'),
                  items: const [
                    DropdownMenuItem(value: 'Manual', child: Text('Manual')),
                    DropdownMenuItem(
                        value: 'Automatic', child: Text('Automatic')),
                    DropdownMenuItem(value: 'CVT', child: Text('CVT')),
                    DropdownMenuItem(
                        value: 'Dual-Clutch', child: Text('Dual-Clutch')),
                  ],
                  onChanged: (value) => _carData['transmission'] = value,
                  validator: (value) =>
                      value == null ? 'Select transmission' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Horsepower'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) =>
                      _carData['horsepower'] = value != null && value.isNotEmpty
                          ? int.parse(value)
                          : null,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Body Type'),
                  items: const [
                    DropdownMenuItem(value: 'Sedan', child: Text('Sedan')),
                    DropdownMenuItem(value: 'SUV', child: Text('SUV')),
                    DropdownMenuItem(value: 'Truck', child: Text('Truck')),
                    DropdownMenuItem(value: 'Coupe', child: Text('Coupe')),
                    DropdownMenuItem(
                        value: 'Convertible', child: Text('Convertible')),
                    DropdownMenuItem(
                        value: 'Hatchback', child: Text('Hatchback')),
                    DropdownMenuItem(value: 'Wagon', child: Text('Wagon')),
                    DropdownMenuItem(value: 'Van', child: Text('Van')),
                  ],
                  onChanged: (value) => _carData['body_type'] = value,
                  validator: (value) =>
                      value == null ? 'Select body type' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Color'),
                  onSaved: (value) => _carData['color'] = value,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Condition'),
                  items: const [
                    DropdownMenuItem(value: 'New', child: Text('New')),
                    DropdownMenuItem(value: 'Used', child: Text('Used')),
                    DropdownMenuItem(
                        value: 'Certified Pre-Owned',
                        child: Text('Certified Pre-Owned')),
                  ],
                  onChanged: (value) => _carData['condition'] = value,
                  validator: (value) =>
                      value == null ? 'Select condition' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  onSaved: (value) => _carData['description'] = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter location' : null,
                  onSaved: (value) => _carData['location'] = value,
                ),
                const SizedBox(height: 20),
                // Image picker button
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.image),
                  label: const Text('Pick Images'),
                ),
                const SizedBox(height: 10),
                // Display selected images
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _selectedImages
                      .map((image) => Stack(
                            children: [
                              Image.file(
                                image,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.remove(image);
                                    });
                                  },
                                  child: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Post Car'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}