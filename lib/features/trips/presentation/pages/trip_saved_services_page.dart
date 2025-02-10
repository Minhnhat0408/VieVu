import 'package:flutter/material.dart';

class TripSavedServicesPage extends StatefulWidget {
  const TripSavedServicesPage({super.key});

  @override
  State<TripSavedServicesPage> createState() => _TripSavedServicesPageState();
}

class _TripSavedServicesPageState extends State<TripSavedServicesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dịch vụ đã lưu'),
      ),
      body: const SingleChildScrollView(
        child: SizedBox(
          height: 1000,
          child: Center(
            child: Text('Danh sách dịch vụ đã lưu'),
          ),
        ),
      ),
    );
  }
}
