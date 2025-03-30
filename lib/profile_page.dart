import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tunibet/edit_profile_page.dart';
import 'signin_page.dart';
import 'user_helper.dart';
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
      id: json['id'].toString(),
      email: json['email'],
      fullName: json['fullName'],
      profileImage: json['profileImage'],
    );
  }
}

class ProfilePage extends StatefulWidget {
  final String? userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  User? _user;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        setState(() {
          _user = User.fromJson(userData);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load user profile: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
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
                  backgroundImage: _user?.profileImage != null
                      ? NetworkImage(_user!.profileImage!)
                      : null,
                  child: _user?.profileImage == null
                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
                ),
                const SizedBox(height: 16),
                
                // User name
                Text(
                  _user?.fullName ?? 'User',
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
                
                ElevatedButton(
                  onPressed: () async {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(userId: widget.userId!),
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
                  await UserHelper.logout();
                  
                  if (!context.mounted) return;
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  
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