import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:manager_work_l1/data/task.dart';

class FirestoreService {
  final CollectionReference _tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(Task task) async {
    await _tasksCollection.add({
      'title': task.title,
      'description': task.description,
      'startTime': {
        'hour': task.startTime?.hour,
        'minute': task.startTime?.minute,
      },
      'endTime': {
        'hour': task.endTime?.hour,
        'minute': task.endTime?.minute,
      },
      'executionDate': task.executionDate,
      'dueDate': task.dueDate,
      'isCompleted': task.isCompleted,
    });
  }

  Stream<List<Task>> getTasks() {
    return _tasksCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Task(
          id: doc.id,
          title: data['title'],
          description: data['description'],
          startTime: _convertToTimeOfDay(data['startTime'])!,
          endTime: _convertToTimeOfDay(data['endTime'])!,
          executionDate: (data['executionDate'] as Timestamp).toDate(),
          dueDate: (data['dueDate'] as Timestamp).toDate(),
          isCompleted: data['isCompleted'],
        );
      }).toList();
    });
  }

  Future<void> updateTask(Task task) async {
    await _tasksCollection.doc(task.id).update({
      'title': task.title,
      'description': task.description,
      'startTime': {
        'hour': task.startTime?.hour,
        'minute': task.startTime?.minute
      },
      'endTime': {'hour': task.endTime?.hour, 'minute': task.endTime?.minute},
      'executionDate': task.executionDate,
      'dueDate': task.dueDate,
      'isCompleted': task.isCompleted,
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  TimeOfDay? _convertToTimeOfDay(dynamic data) {
    if (data is Map) {
      return TimeOfDay(hour: data['hour'], minute: data['minute']);
    }
    return null;
  }
}
