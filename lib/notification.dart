import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  final String dealerId;
  NotificationsPage({super.key, required this.dealerId});
  final List<Map<String, dynamic>> notifications = [
    {
      'message': 'Dealer accepted your bet for Car X',
      'dealerPhone': '123-456-7890',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            title: Text(notification['message']),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Contact Dealer'),
                    content: Text('Phone: ${notification['dealerPhone']}'),
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