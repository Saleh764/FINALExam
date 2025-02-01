import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Device List', home: DeviceListScreen());
  }
}

class DeviceListScreen extends StatefulWidget {
  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Toggle status for a specific device
  Future<void> _toggleStatus(String documentId, bool currentStatus) async {
    bool newStatus = !currentStatus;
    try {
      await _db.collection('devices').doc(documentId).update({
        'status': newStatus,
      });
      log("Updated status of $documentId to: $newStatus");
    } catch (e) {
      log("Error updating status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Devices List')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('devices').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No devices found'));
          }

          var devices = snapshot.data!.docs;

          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              var device = devices[index];
              String documentId = device.id;
              String name = device['name'] ?? 'Unknown';
              bool status = device['status'] ?? false;

              return ListTile(
                title: Text(
                  name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Status: ${status ? 'ON' : 'OFF'}"),
                trailing: Switch(
                  value: status,
                  onChanged: (value) {
                    _toggleStatus(documentId, status);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
