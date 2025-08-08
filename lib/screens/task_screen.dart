import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';
import 'login_screen.dart';
import '../l10n/app_localizations.dart';
import 'settings_screen.dart';

class TaskScreen extends StatefulWidget {
  final Function(bool, Locale) updateThemeAndLocale;

  const TaskScreen({super.key, required this.updateThemeAndLocale});

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF3D2C8D) : Colors.white;
    final inputColor = isDark ? const Color(0xFF4A3F87) : Colors.grey[200]!;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white70 : Colors.black45;
    final buttonColor = isDark ? const Color(0xFF9336B4) : Theme.of(context).primaryColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalizations.of(context)!.addTask, style: TextStyle(color: textColor)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_nameController, AppLocalizations.of(context)!.taskName, inputColor, textColor, hintColor),
              const SizedBox(height: 10),
              _buildTextField(_descriptionController, AppLocalizations.of(context)!.description, inputColor, textColor, hintColor),
              const SizedBox(height: 10),
              _buildDropdown(_selectedMonth, _months, AppLocalizations.of(context)!.selectMonth, (value) => setState(() => _selectedMonth = value), inputColor, textColor, hintColor),
              const SizedBox(height: 10),
              _buildDropdown(_selectedDay, _days, AppLocalizations.of(context)!.selectDay, (value) => setState(() => _selectedDay = value), inputColor, textColor, hintColor),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: hintColor)),
          ),
          ElevatedButton(
            onPressed: _addTask,
            style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
            child: Text(AppLocalizations.of(context)!.add, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, Color fillColor, Color textColor, Color hintColor) {
    return TextField(
      controller: controller,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: hintColor),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown(String? value, List<String> items, String hint, void Function(String?) onChanged, Color fillColor, Color textColor, Color hintColor) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: fillColor,
      iconEnabledColor: textColor,
      hint: Text(hint, style: TextStyle(color: hintColor)),
      style: TextStyle(color: textColor),
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item, style: TextStyle(color: textColor)),
      )).toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2E0249) : Colors.white;
    final cardColor = isDark ? const Color(0xFF4A3F87) : Colors.grey[100]!;
    final appBarColor = isDark ? const Color(0xFF3D2C8D) : Theme.of(context).primaryColor;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Row(
          children: [
            Image.asset('lib/assets/images/icon.png', height: 40),
            const SizedBox(width: 10),
            Text('Do-ily', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: textColor)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: textColor),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
            tooltip: AppLocalizations.of(context)!.logout,
          ),
          IconButton(
            icon: Icon(Icons.settings, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    updateThemeAndLocale: widget.updateThemeAndLocale,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _tasks.length,
        itemBuilder: (context, index) => Card(
          color: cardColor,
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(_tasks[index].name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            subtitle: Text(
              '${_tasks[index].description}\nDue: ${_tasks[index].month} ${_tasks[index].day}',
              style: TextStyle(color: textColor.withOpacity(0.7)),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: textColor),
              onPressed: () => _deleteTask(index),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: appBarColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.add, size: 30, color: textColor),
              onPressed: _showAddTaskDialog,
            ),
          ],
        ),
      ),
    );
  }
}