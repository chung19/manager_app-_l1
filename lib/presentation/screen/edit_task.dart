import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/services/fire_store_service.dart';
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
  late DateTime _selectedDueDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _isCompleted;
  final FirestoreService _fireStoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _selectedExecutionDate = widget.task.executionDate;
    _selectedDueDate = widget.task.dueDate;
    _startTime = widget.task.startTime!;
    _endTime = widget.task.endTime!;
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
                title: Text(
                    'DueDate: ${DateFormat('dd/MM/yyyy').format(_selectedDueDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _presentDatePickerDue,
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
              ListTile(
                title: const Text('End time'),
                trailing: Text(_endTime.format(context)),
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _endTime,
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _endTime = pickedTime;
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

  void _presentDatePickerDue() {
    showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDueDate = pickedDate;
      });
    });
  }

  Future<void> _updateTask() async {
    final updatedTask = Task(
      id: widget.task.id,
      title: _titleController.text,
      description: _descriptionController.text,
      executionDate: _selectedExecutionDate,
      dueDate: _selectedDueDate,
      startTime: _startTime,
      endTime: _endTime,
      isCompleted: _isCompleted,
    );
    await _fireStoreService.updateTask(updatedTask);
    if (mounted) {
      Navigator.pop(context); // Q
    }
  }
}
