import 'package:flutter/material.dart';
import 'package:tunibet/dealer_home_page.dart';
import 'package:tunibet/signin-dealer.dart';
import 'signin_page.dart';
import 'home_page.dart'; // Import your home page
import 'package:shared_preferences/shared_preferences.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userType = prefs.getString('userType');
    final int? userId = prefs.getInt('userId');

    if (userType == 'user' && userId != null) {
      // Navigate to HomePage for users
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (userType == 'dealer' && userId != null) {
      // Navigate to DealerHomePage for dealers
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DealerHomePage(dealerId: userId.toString()),
        ),
      );
    } else {
      // No one is logged in, navigate to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInDealer()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF56021F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 250),
            Image.asset(
              'assets/logo-white.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              'TUNIBET',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.white, 
            ),
            const SizedBox(height: 220),
            const Text(
              'Powered By EL KING',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
