import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../data/services/fire_store_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/task.dart';
import 'add_new_task.dart';
import 'edit_task.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    tz.initializeTimeZones();
    super.initState();
  }

  final FirestoreService _fireStoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Task List')),
      ),
      body: StreamBuilder<List<Task>>(
        stream: _fireStoreService.getTasks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
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
                title: Column(
                  children: [
                    Text('Task:${task.title}'),
                    Text('Description:${task.description}'),
                  ],
                ),
                subtitle: Text(
                    'Execution: ${DateFormat('dd/MM/yyyy').format(task.executionDate)}\n'
                    '''
Start Time: ${task.startTime?.format(context)}'''),
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
                    ElevatedButton.icon(
                      icon: Icon(Icons.notifications_outlined),
                      onPressed: () async {
                        // Hiển thị DatePicker để chọn ngày
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000, 1, 1),
                          lastDate: DateTime(2099, 1, 1),
                        );

                        if (pickedDate != null) {
                          // Hiển thị TimePicker để chọn thời gian
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime != null) {
                            // Kết hợp ngày và thời gian
                            DateTime scheduledDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );

                            // Lập lịch thông báo
                            await LocalNotifications.showScheduleNotification(
                              id: task.id.hashCode,
                              title: task.title,
                              body: task.description,
                              payload: "This is schedule data",
                              scheduledNotificationDateTime: scheduledDateTime,
                            );
                          }
                        }
                      },
                      label: Text("schedule"),
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
    await _fireStoreService.updateTask(task.copyWith(isCompleted: isCompleted));

    if (isCompleted) {
      await LocalNotifications.cancel(task.id.hashCode);
    } else {
      await LocalNotifications.showScheduleNotification(
        id: task.id.hashCode,
        title: task.title,
        body: task.description,
        scheduledNotificationDateTime: DateTime(
          task.executionDate.year,
          task.executionDate.month,
          task.executionDate.day,
          task.startTime.hour,
          task.startTime.minute,
        ),
      );
    }
  }

  Future<void> _showDeleteConfirmationDialog(String taskId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const Text('Do you want to delete'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await _fireStoreService.deleteTask(taskId);
      await LocalNotifications.cancelAll();
    }
  }
}
