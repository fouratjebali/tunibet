import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationsPage extends StatefulWidget {
  final String userId;

  const NotificationsPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications(); // Fetch notifications when the page loads
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/notifications?user_id=${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final notifications = List<Map<String, dynamic>>.from(json.decode(response.body));
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      } else {
        print('Failed to fetch notifications: ${response.body}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('No notifications available.'))
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return ListTile(
                      title: Text(notification['title']),
                      subtitle: Text(notification['message']),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Contact Dealer'),
                              content: Text('Phone: ${notification['phone_number']}'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
    );
  }
}