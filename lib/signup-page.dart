import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'signin_page.dart';
import 'signup-dealer.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}
  
class _SignUpPageState extends State<SignUpPage> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _phone;
  late final TextEditingController _name;


  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
    _name = TextEditingController();
    _phone = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _name.dispose();
    super.dispose();
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
                'SIGN UP',
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
                controller: _name,
                decoration: InputDecoration(
                  fillColor: Colors.grey[100],
                  filled: true,
                  hintText: 'Full Name',
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
                  hintText: 'Email',
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
                  hintText: 'Phone Number',
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
                    final name = _name.text;
                    
                    const String apiUrl = "http://10.0.2.2:5000/api/users/register";

                    final response = await http.post(
                      Uri.parse(apiUrl),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "fullName": name,
                        "email": email,
                        "password": password,
                        "phoneNumber": phone,
                      }),
                    );

                    if (response.statusCode == 201) {
                      final responseData = jsonDecode(response.body);
                      print("User Created: ${responseData['user']}");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("User created successfully!")),
                      );
                    } else {
                      print("Error: ${response.body}");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to create user")),
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
              const Text(
                'OR'
              ),
              const SizedBox(height: 5),
              const Text(
                'Sign Up with :'
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                    
                    },
                    child: const Icon(
                      FontAwesomeIcons.google,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      
                    },
                    child: const Icon(
                      FontAwesomeIcons.apple,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      
                    },
                    child: const Icon(
                      FontAwesomeIcons.facebook,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Are you a dealer?",
                    style: TextStyle(color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpDealer(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign up As A Dealer',
                      style: TextStyle(
                        color: Color(0xFF56021F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),        
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'login',
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