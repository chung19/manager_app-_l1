import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/services/fire_store_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/task.dart';
import 'add_new_task.dart';
import 'edit_task.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách công việc'),
      ),
      body: StreamBuilder<List<Task>>(
        stream: _firestoreService.getTasks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Task> tasks = snapshot.data!;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              Task task = tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text(
                  'Hạn chót: ${DateFormat('dd/MM/yyyy').format(task.dueDate)}\n'
                  'Từ: ${task.startTime?.format(context)} - Đến: ${task.endTime?.format(context)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) {
                        _toggleTaskCompletion(task, value!);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _showDeleteConfirmationDialog(task.id);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTaskScreen(task: task),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _toggleTaskCompletion(Task task, bool isCompleted) async {
    await _firestoreService.updateTask(task.copyWith(isCompleted: isCompleted));

    if (isCompleted) {
      await NotificationService.cancelNotification(task.id.hashCode);
    } else {
      await NotificationService.showNotification(
          task.id.hashCode,
          task.title,
          task.description,
          DateTime(
            task.dueDate.year,
            task.dueDate.month,
            task.dueDate.day,
            task.startTime!.hour,
            task.startTime!.minute,
          ));
    }
  }

  Future<void> _showDeleteConfirmationDialog(String taskId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa công việc này?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await _firestoreService.deleteTask(taskId);
      await NotificationService.cancelNotification(taskId.hashCode);
    }
  }
}
