
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunibet/signin-dealer.dart';

import 'signup-page.dart';
import 'home_page.dart';


class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  
  @override
  void initState(){
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }
  @override
  void dispose(){
    _email.dispose();
    _password.dispose();
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
              const SizedBox(height: 30),
              Image.asset(
                'assets/logo-black.png', 
                height: 150,
              ),
              const SizedBox(height: 16),
              const Text(
                'LOGIN',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Poppins'
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
              const SizedBox(height: 80),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _password,
                obscureText: true,
                autocorrect: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.visibility_off_outlined, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Forgot password ?',
                  style: TextStyle(color: Colors.black54),
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
                    const String apiUrl = "http://10.0.2.2:5000/api/users/login";
                    final response = await http.post(
                    Uri.parse(apiUrl),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "email": email,
                      "password": password,
                      }),
                    );

                    final data = jsonDecode(response.body);

                    if (response.statusCode == 200) {
                      // Save token
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setString("token", data["token"]);
                      await prefs.setString("userEmail", data["user"]["email"]);
                      await prefs.setInt("userId", int.parse(data["user"]["id"].toString()));


                       if (!mounted) return;

                      // Navigate to main page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()));
                    } else {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(data["message"])),
                      );
                    }
                  },
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "don’t have an account? ",
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
                      'Sign Up',
                      style: TextStyle(
                        color: Color(0xFF56021F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),        
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Are you a dealer? ",
                    style: TextStyle(color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInDealer(),
                        ),
                      );
                    },
                    child: const Text(
                      'Dealer Login',
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
