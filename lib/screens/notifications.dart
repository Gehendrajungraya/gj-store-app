import 'package:flutter/material.dart';

import '../services/api.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _friendlyMessage(Object error) {
    final text = error.toString().toLowerCase();
    if (text.contains('socketexception') || text.contains('failed host lookup') || text.contains('clientexception')) {
      return 'Unable to connect to the server. Please check your internet connection.';
    }
    if (text.contains('timeout')) {
      return 'The server is taking too long to respond. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: FutureBuilder<dynamic>(
        future: ApiService.notifications(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.notifications_off_outlined, size: 48),
                    const SizedBox(height: 14),
                    Text(
                      _friendlyMessage(snapshot.error ?? 'Something went wrong. Please try again.'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final raw = snapshot.data;
          final list = raw is List
              ? raw
              : (raw is Map && raw['notifications'] is List ? raw['notifications'] : const []);

          if (list.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final n = Map<String, dynamic>.from(list[index]);
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.notifications)),
                title: Text('${n['title'] ?? 'Notification'}'),
                subtitle: Text('${n['message'] ?? n['body'] ?? ''}'),
              );
            },
          );
        },
      ),
    );
  }
}
