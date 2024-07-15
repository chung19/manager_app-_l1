import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/services/fire_store_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/task.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedExecutionDate = DateTime.now();
  DateTime _selectedDueDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  bool _isCompleted = false;
  final FirestoreService _firestoreService = FirestoreService();

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
        title: const Text('Thêm công việc'),
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
                                const InputDecoration(labelText: 'Tiêu đề'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập tiêu đề';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _descriptionController,
                            decoration:
                                const InputDecoration(labelText: 'Mô tả'),
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
                                'Ngày thực hiện: ${DateFormat('dd/MM/yyyy').format(_selectedExecutionDate)}'),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: _presentDatePickerExecution,
                          ),
                          ListTile(
                            title: Text(
                                'Hạn chót: ${DateFormat('dd/MM/yyyy').format(_selectedDueDate)}'),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: _presentDatePickerDue,
                          ),
                          ListTile(
                            title: const Text('Giờ bắt đầu thông báo:'),
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
                          ListTile(
                            title: const Text('Giờ kết thúc thông báo:'),
                            trailing: Text(_endTime.format(context)),
                            onTap: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
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
                            title: const Text('Đã hoàn thành'),
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
                              child: const Text('Lưu'),
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

  Future<void> _addTask() async {
    final newTask = Task(
      id: '',
      // FireStore auto create id
      title: _titleController.text,
      description: _descriptionController.text,
      executionDate: _selectedExecutionDate,
      dueDate: _selectedDueDate,
      startTime: _startTime,
      endTime: _endTime,
      isCompleted: _isCompleted,
    );
    await _firestoreService.addTask(newTask);
    // Lên lịch thông báo
    await NotificationService.showNotification(
      newTask.id.hashCode,
      newTask.title,
      newTask.description,
      DateTime(
        newTask.dueDate.year,
        newTask.dueDate.month,
        newTask.dueDate.day,
        newTask.startTime!.hour,
        newTask.startTime!.minute,
      ),
    );
    if (mounted) {
      Navigator.pop(context); // Quay lại màn hình danh sách công việc
    }
  }
}
