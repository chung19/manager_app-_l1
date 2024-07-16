import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:manager_work_l1/data/task.dart';

class FirestoreService {
  final CollectionReference _tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(Task task) async {
    try {
      await _tasksCollection.add({
        'title': task.title,
        'description': task.description,
        'startTime': Timestamp.fromDate(DateTime(
          task.executionDate.year,
          task.executionDate.month,
          task.executionDate.day,
          task.startTime.hour,
          task.startTime.minute,
        )),
        'executionDate': task.executionDate,
        'isCompleted': task.isCompleted,
      });
    } catch (e) {
      debugPrint("Error adding task: $e xyz");
    }
  }

  Stream<List<Task>> getTasks() {
    return _tasksCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        TimeOfDay? startTime = _convertToTimeOfDay(data['startTime']);
        return Task(
          id: doc.id,
          title: data['title'],
          description: data['description'],
          startTime: startTime!,
          executionDate: (data['executionDate'] as Timestamp).toDate(),
          isCompleted: data['isCompleted'],
        );
      }).toList();
    });
  }

  Future<void> updateTask(Task task) async {
    await _tasksCollection.doc(task.id).update({
      'title': task.title,
      'description': task.description,
      'startTime': Timestamp.fromDate(DateTime(
        task.executionDate.year,
        task.executionDate.month,
        task.executionDate.day,
        task.startTime.hour,
        task.startTime.minute,
      )),
      'executionDate': task.executionDate,
      'isCompleted': task.isCompleted,
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  TimeOfDay? _convertToTimeOfDay(dynamic data) {
    if (data is Timestamp) {
      DateTime dateTime = data.toDate();
      return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    } else if (data is DateTime) {
      return TimeOfDay(hour: data.hour, minute: data.minute);
    }
    return null;
  }
}
