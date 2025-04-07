import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tunibet/edit_dealer_profile_page.dart';
import 'signin_page.dart';
import 'user_helper.dart';
import 'edit_profile_page.dart';
const String baseUrl = 'http://10.0.2.2:5000/api'; 

class User {
  final String id;
  final String email;
  final String fullName;
  final String? profileImage;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? 'email@example.com',
      fullName: json['fullName'] ?? 'Dealer',
      profileImage: json['profileImage'],
    );
  }
}

class DealerProfilePage extends StatefulWidget {
  final String dealerId;
  final bool isDealer;

  const DealerProfilePage({Key? key, required this.dealerId, required this.isDealer}) : super(key: key);

  @override
  State<DealerProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<DealerProfilePage> {
  bool _isLoading = true;
  User? _user;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }
  String getFullImageUrl(String? relativeUrl) {
  const String baseUrl = 'http://10.0.2.2:5000'; // Replace with your backend's base URL
  if (relativeUrl == null || relativeUrl.isEmpty) {
    return '$baseUrl/uploads/default-profile.jpg'; // Default image
  }
  if (relativeUrl.startsWith('http')) {
    return relativeUrl; // Already a full URL
  }
  return '$baseUrl$relativeUrl'; // Append base URL to relative path
}

  Future<void> _fetchUserProfile() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    final response = await http.get(
      Uri.parse("$baseUrl/dealers/${widget.dealerId}"),
    );
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      print('Parsed user data: $userData');
      setState(() {
        _user = User.fromJson(userData);
        print('User data: $_user');
        _isLoading = false;
        });
      
    } else {
      if (mounted) {
        setState(() {
          _error = 'Failed to load user profile: ${response.statusCode}';
          _isLoading = false;
        });
      }
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              // Navigate to settings page
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    final String type = "dealer";
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile image
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: NetworkImage(getFullImageUrl(_user?.profileImage)),
                  child: _user?.profileImage == null || _user!.profileImage!.isEmpty
                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
                ),
                const SizedBox(height: 16),
                
                // User name
                Text(
                  _user?.fullName ?? 'Dealer',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                // User email
                Text(
                  _user?.email ?? 'email@example.com',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Edit profile button
                ElevatedButton(
                  onPressed: () async {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditDealerProfilePage(dealerId: widget.dealerId ?? ''),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF56021F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  ),
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
          ),
          
          // Menu items
          _buildMenuItem(Icons.favorite, 'Favourites'),
          _buildMenuItem(Icons.download, 'Downloads'),
          const Divider(),
          _buildMenuItem(Icons.language, 'Languages'),
          _buildMenuItem(Icons.location_on, 'Location'),
          _buildMenuItem(Icons.subscriptions, 'Subscription'),
          _buildMenuItem(Icons.display_settings, 'Display'),
          const Divider(),
          _buildMenuItem(Icons.delete, 'Clear Cache'),
          _buildMenuItem(Icons.history, 'Clear History'),
          _buildMenuItem(Icons.logout, 'Log Out', isLogout: true),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {bool isLogout = false}) {
  return ListTile(
    leading: Icon(
      icon,
      color: isLogout ? Colors.red : Colors.black87,
    ),
    title: Text(
      title,
      style: TextStyle(
        color: isLogout ? Colors.red : Colors.black87,
        fontWeight: FontWeight.w500,
      ),
    ),
    trailing: const Icon(
      Icons.chevron_right,
      color: Colors.grey,
    ),
    onTap: () {
      // Handle menu item tap
      if (isLogout) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Log Out'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  // Perform logout using UserHelper
                  await UserHelper.logout();
                  
                  // Close dialog and navigate to login page
                  if (!context.mounted) return;
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  
                  // Replace the current route with the login page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                  );
                },
                child: const Text('Log Out'),
              ),
            ],
          ),
        );
      }
    },
  );
}
}