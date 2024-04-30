import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MongoDB Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> employees = [];

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    final response = await http.get(Uri.parse('YOUR_BACKEND_ENDPOINT_HERE'));
    if (response.statusCode == 200) {
      setState(() {
        employees = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to fetch employees');
    }
  }

  Future<void> addEmployee() async {
    final response = await http.post(
      Uri.parse('YOUR_BACKEND_ENDPOINT_HERE'),
      body: json.encode({
        'name': 'New Employee Name',
        'joinDate': DateTime.now().toIso8601String(),
        'isActive': true,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Employee added successfully, fetch updated employee list
      fetchEmployees();
    } else {
      throw Exception('Failed to add employee');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee List'),
      ),
      body: ListView.builder(
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          return ListTile(
            title: Text(employee['name']),
            subtitle: Text('Joined: ${employee['joinDate']}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addEmployee,
        tooltip: 'Add Employee',
        child: Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
