import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tunibet/signin-dealer.dart';
import 'package:tunibet/signin_page.dart';
import 'dart:convert';
import 'signup-page.dart';
import 'package:http/http.dart' as http;

class SignUpDealer extends StatefulWidget {
  const SignUpDealer({super.key});
  @override
  State<SignUpDealer> createState() => _SignUpPageState();
}
  
class _SignUpPageState extends State<SignUpDealer> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _phone;
  late final TextEditingController _dealername;
  File? _selectedImage;
  String? _userId;


  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
    _dealername = TextEditingController();
    _phone = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _dealername.dispose();
    super.dispose();
  }
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }
  Future<void> _uploadProfilePicture() async {
    if (_selectedImage == null || _userId == null) return;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:5000/api/dealers/upload-profile'),
    );

    request.fields['dealer_id'] = _userId!;
    request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));

    final response = await request.send();

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture uploaded successfully!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInDealer()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    }
  }
  Future<void> _onSignUpSuccess(String userId) async {
    setState(() {
      _userId = userId;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Profile Picture'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 100, width: 100)
                : const Icon(Icons.person, size: 100),
            TextButton(
              onPressed: _pickImage,
              child: const Text('Choose Image'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _uploadProfilePicture,
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 0),
              Image.asset(
                'assets/logo-black.png',
                height: 150,
              ),
              const SizedBox(height: 16),
              const Text(
                'SIGN UP AS A DEALER',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Welcome to TUNIBET',
                style: TextStyle(fontSize: 16,
                color: Colors.black,
                fontFamily: 'Poppins',
                 ),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: _dealername,
                decoration: InputDecoration(
                  fillColor: Colors.grey[100],
                  filled: true,
                  hintText: 'Dealer Name',
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  )
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _email,
                decoration: InputDecoration(
                  fillColor: Colors.grey[100],
                  filled: true,
                  hintText: 'Email address for customer inquiries',
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  )
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  fillColor: Colors.grey[100],
                  filled: true,
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  )
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phone,
                decoration: InputDecoration(
                  fillColor: Colors.grey[100],
                  filled: true,
                  hintText: 'Dealer Mobile Phone Number',
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  )
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF56021F), // Couleur rouge foncé
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;
                    final phone = _phone.text;
                    final name = _dealername.text;
                    
                    const String apiUrl = "http://10.0.2.2:5000/api/dealers/register";

                    final response = await http.post(
                      Uri.parse(apiUrl),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "dealerName": name,
                        "email": email,
                        "password": password,
                        "phoneNumber": phone,
                      }),
                    );

                    if (response.statusCode == 201) {
                      final responseData = jsonDecode(response.body);
                      _onSignUpSuccess(responseData['dealer']['dealer_id'].toString());
                      print("Dealer Created: ${responseData['dealer']}");

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Dealer created successfully!")),
                      );
                    } else {
                      print("Error: ${response.body}");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to create Dealer")),
                      );
                    }
                  },
                  child: const Text(
                    'SIGN UP',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Are you a simple user? ",
                    style: TextStyle(color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'User Sign up',
                      style: TextStyle(
                        color: Color(0xFF56021F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),        
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}