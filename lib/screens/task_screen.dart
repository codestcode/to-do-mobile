import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';
import 'login_screen.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedMonth;
  String? _selectedDay;
  List<Task> _tasks = [];
  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final List<String> _days = List.generate(31, (index) => (index + 1).toString());

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> decoded = jsonDecode(tasksJson);
      setState(() {
        _tasks = decoded.map((task) => Task.fromJson(task)).toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksJson = jsonEncode(_tasks.map((task) => task.toJson()).toList());
    await prefs.setString('tasks', tasksJson);
  }

  void _addTask() {
    if (_nameController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _selectedMonth != null &&
        _selectedDay != null) {
      setState(() {
        _tasks.add(Task(
          name: _nameController.text,
          description: _descriptionController.text,
          month: _selectedMonth!,
          day: _selectedDay!,
        ));
        _nameController.clear();
        _descriptionController.clear();
        _selectedMonth = null;
        _selectedDay = null;
        _saveTasks();
      });
      Navigator.pop(context);
    }
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      _saveTasks();
    });
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Task Name'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedMonth,
                hint: const Text('Select Month'),
                items: _months.map((month) => DropdownMenuItem(
                  value: month,
                  child: Text(month),
                )).toList(),
                onChanged: (value) => setState(() => _selectedMonth = value),
              ),
              DropdownButtonFormField<String>(
                value: _selectedDay,
                hint: const Text('Select Day'),
                items: _days.map((day) => DropdownMenuItem(
                  value: day,
                  child: Text(day),
                )).toList(),
                onChanged: (value) => setState(() => _selectedDay = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addTask,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _tasks.length,
        itemBuilder: (context, index) => Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text(_tasks[index].name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${_tasks[index].description}\nDue: ${_tasks[index].month} ${_tasks[index].day}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteTask(index),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.add, size: 30),
              onPressed: _showAddTaskDialog,
            ),
          ],
        ),
      ),
    );
  }
}