import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../data/services/fire_store_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/task.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedExecutionDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  bool _isCompleted = false;
  final FirestoreService _firesStoreService = FirestoreService();
  @override
  void initState() {
    tz.initializeTimeZones();
    LocalNotifications.init();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration:
                                const InputDecoration(labelText: 'Title'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _descriptionController,
                            decoration:
                                const InputDecoration(labelText: 'Description'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                                'Execution: ${DateFormat('dd/MM/yyyy').format(_selectedExecutionDate)}'),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: _presentDatePickerExecution,
                          ),
                          ListTile(
                            title: const Text('Start time :'),
                            trailing: Text(_startTime.format(context)),
                            onTap: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                context: context,
                                initialTime: _startTime,
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  _startTime = pickedTime;
                                });
                              }
                            },
                          ),
                          CheckboxListTile(
                            title: const Text('Completed'),
                            value: _isCompleted,
                            onChanged: (value) {
                              setState(() {
                                _isCompleted = value!;
                              });
                            },
                          ),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _addTask();
                                }
                              },
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _presentDatePickerExecution() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2099, 1, 1),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedExecutionDate = pickedDate;
      });
    });
  }

  Future<void> _addTask() async {
    debugPrint("1 xyz");
    final newTask = Task(
      id: '',
      title: _titleController.text,
      description: _descriptionController.text,
      executionDate: _selectedExecutionDate,
      startTime: _startTime,
      isCompleted: _isCompleted,
    );
    debugPrint("2 xyz");
    DateTime scheduledDateTime = DateTime(
      _selectedExecutionDate.year,
      _selectedExecutionDate.month,
      _selectedExecutionDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    debugPrint("3 xyz");
    debugPrint("Scheduling notification for ${scheduledDateTime.toString()}");
    if (scheduledDateTime.isBefore(DateTime.now())) {
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time in the future')),
      );
      return;
    }

    try {
      await _firesStoreService.addTask(newTask);
      debugPrint("Task added successfully");
    } catch (e) {
      debugPrint("Error adding task: $e");
    }

    // Lên lịch thông báo
    debugPrint("4 xyz");
    try {
      await LocalNotifications.showScheduleNotification(
        id: newTask.id.hashCode,
        title: newTask.title,
        body: newTask.description,
        payload: "This is schedule data",
        scheduledNotificationDateTime: scheduledDateTime,
      );
      debugPrint("5 xyz");
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error scheduling notification: $e");
    }
  }
}
