import 'package:flutter/material.dart';
import '../services/fcm_broadcast_service.dart';

class BroadcastNotificationPage extends StatefulWidget {
  const BroadcastNotificationPage({super.key});

  @override
  State<BroadcastNotificationPage> createState() => _BroadcastNotificationPageState();
}

class _BroadcastNotificationPageState extends State<BroadcastNotificationPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _audioIdController = TextEditingController();
  bool _isSending = false;
  String _lastResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Broadcast Notification'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.notifications_active, size: 50, color: Colors.blue),
                    const SizedBox(height: 10),
                    const Text(
                      'Send to All Users',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'This will notify all Diamondnib users',
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Notification Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Notification Title *',
                hintText: 'Enter notification title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),

            const SizedBox(height: 16),

            // Notification Message
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Notification Message *',
                hintText: 'Enter the message for all users',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            // Audio ID
            TextField(
              controller: _audioIdController,
              decoration: const InputDecoration(
                labelText: 'Content ID *',
                hintText: 'Enter unique ID for this content',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.audiotrack),
              ),
            ),

            const SizedBox(height: 24),

            // Send Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _sendBroadcastNotification,
                icon: _isSending 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_isSending ? 'Sending...' : 'Send to All Users'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Quick Action Buttons
            const Text('Quick Actions:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickButton('New Audio', Icons.audio_file, Colors.green, _fillNewAudio),
                _buildQuickButton('App Update', Icons.update, Colors.orange, _fillAppUpdate),
                _buildQuickButton('Maintenance', Icons.engineering, Colors.red, _fillMaintenance),
                _buildQuickButton('Feature', Icons.new_releases, Colors.purple, _fillNewFeature),
              ],
            ),

            const SizedBox(height: 24),

            // Result Display
            if (_lastResult.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _lastResult.contains('✅') ? Colors.green.shade50 : Colors.red.shade50,
                  border: Border.all(
                    color: _lastResult.contains('✅') ? Colors.green : Colors.red,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _lastResult,
                  style: TextStyle(
                    color: _lastResult.contains('✅') ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: _isSending ? null : onTap,
      icon: Icon(icon, size: 16),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Future<void> _sendBroadcastNotification() async {
    if (_titleController.text.isEmpty || 
        _messageController.text.isEmpty || 
        _audioIdController.text.isEmpty) {
      _showResult('Please fill all required fields', isSuccess: false);
      return;
    }

    setState(() {
      _isSending = true;
      _lastResult = '';
    });

    try {
      final result = await FCMBroadcastService.sendToAllUsers(
        title: _titleController.text,
        body: _messageController.text,
        audioId: _audioIdController.text,
        description: _messageController.text,
      );

      if (result['success'] == true) {
        _showResult('✅ Notification sent successfully to all users!\nMessage ID: ${result['messageId']}');
        _clearForm();
      } else {
        _showResult('❌ Failed to send: ${result['message']}', isSuccess: false);
      }
    } catch (e) {
      _showResult('❌ Error: $e', isSuccess: false);
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _fillNewAudio() {
    setState(() {
      _titleController.text = 'New Audio Available';
      _messageController.text = 'We have added new audio content for you to enjoy!';
      _audioIdController.text = 'audio_${DateTime.now().millisecondsSinceEpoch}';
    });
  }

  void _fillAppUpdate() {
    setState(() {
      _titleController.text = 'App Update Available';
      _messageController.text = 'A new version of the app is available with exciting features!';
      _audioIdController.text = 'update_${DateTime.now().millisecondsSinceEpoch}';
    });
  }

  void _fillMaintenance() {
    setState(() {
      _titleController.text = 'Scheduled Maintenance';
      _messageController.text = 'The app will undergo maintenance to improve your experience.';
      _audioIdController.text = 'maintenance_${DateTime.now().millisecondsSinceEpoch}';
    });
  }

  void _fillNewFeature() {
    setState(() {
      _titleController.text = 'New Feature Released';
      _messageController.text = 'Check out the latest features we have added to enhance your experience!';
      _audioIdController.text = 'feature_${DateTime.now().millisecondsSinceEpoch}';
    });
  }

  void _showResult(String message, {bool isSuccess = true}) {
    setState(() {
      _lastResult = message;
    });
  }

  void _clearForm() {
    _titleController.clear();
    _messageController.clear();
    _audioIdController.clear();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _audioIdController.dispose();
    super.dispose();
  }
}