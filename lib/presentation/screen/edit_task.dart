import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/services/fire_store_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/task.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;
  const EditTaskScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedExecutionDate;
  late TimeOfDay _startTime;
  late bool _isCompleted;
  final FirestoreService _fireStoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _selectedExecutionDate = widget.task.executionDate;
    _startTime = widget.task.startTime!;
    _isCompleted = widget.task.isCompleted;
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
        title: const Text('EditTask'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              ListTile(
                title: Text(
                    'Execution: ${DateFormat('dd/MM/yyyy').format(_selectedExecutionDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _presentDatePickerExecution,
              ),
              ListTile(
                title: const Text('Start time:'),
                trailing: Text(_startTime.format(context)),
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
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
                      _updateTask();
                    }
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _presentDatePickerExecution() {
    showDatePicker(
      context: context,
      initialDate: _selectedExecutionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedExecutionDate = pickedDate;
      });
    });
  }

  Future<void> _updateTask() async {
    final updatedTask = Task(
      id: widget.task.id,
      title: _titleController.text,
      description: _descriptionController.text,
      executionDate: _selectedExecutionDate,
      startTime: _startTime,
      isCompleted: _isCompleted,
    );

    DateTime scheduledDateTime = DateTime(
      _selectedExecutionDate.year,
      _selectedExecutionDate.month,
      _selectedExecutionDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    debugPrint("Scheduling notification for ${scheduledDateTime.toString()}");
    if (scheduledDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time in the future')),
      );
      return;
    }
    try {
      await _fireStoreService.updateTask(updatedTask);
      await LocalNotifications.showScheduleNotification(
        id: updatedTask.id.hashCode,
        title: updatedTask.title,
        body: updatedTask.description,
        payload: "This is schedule data",
        scheduledNotificationDateTime: scheduledDateTime,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('successfully update')),
        );
      }
    } catch (e) {
      debugPrint("Error updating task or scheduling notification: $e");
    }
  }
}
