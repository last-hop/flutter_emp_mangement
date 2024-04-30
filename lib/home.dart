import 'package:flutter/material.dart';
import 'database_helper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Employee> employees = [];
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    final List<Employee> fetchedEmployees = await DatabaseHelper.instance.getEmployees();
    setState(() {
      employees = fetchedEmployees;
    });
  }

  Future<void> _showAddEmployeeDialog() async {
    TextEditingController nameController = TextEditingController();
    TextEditingController joinDateController = TextEditingController(text: DateTime.now().toString());
    bool isActive = true;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Employee'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: joinDateController,
                  decoration: InputDecoration(labelText: 'Join Date'),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null && pickedDate != DateTime.now()) {
                      joinDateController.text = pickedDate.toString();
                    }
                  },
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text('Active: '),
                    Switch(
                      value: isActive,
                      onChanged: (value) {
                        setState(() {
                          isActive = value;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final newEmployee = Employee(
                      id: 0,
                      name: nameController.text,
                      joinDate: DateTime.parse(joinDateController.text),
                      isActive: isActive,
                    );
                    await DatabaseHelper.instance.insertEmployee(newEmployee);
                    fetchEmployees();
                    Navigator.of(context).pop();
                    // Scroll to the bottom after adding a new employee
                    _controller.animateTo(
                      _controller.position.maxScrollExtent,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                  child: Text('Add Employee'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee List'),
      ),
      body: ListView.builder(
        controller: _controller,
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          final yearsWithCompany = DateTime.now().difference(employee.joinDate).inDays ~/ 365;

          Color flagColor = Colors.transparent;
          if (yearsWithCompany >= 5 && employee.isActive) {
            flagColor = Colors.green;
          }

          return ListTile(
            title: Text(employee.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Joined: ${employee.joinDate.toString()}'),
                Text('Active: ${employee.isActive ? 'Yes' : 'No'}'),
              ],
            ),
            trailing: Icon(Icons.flag, color: flagColor),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEmployeeDialog,
        tooltip: 'Add Employee',
        child: Icon(Icons.add),
      ),
    );
  }
}
