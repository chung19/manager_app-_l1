import 'package:flutter/material.dart';

class Task {
  String id;
  String title;
  String description;
  TimeOfDay startTime;
  TimeOfDay endTime;
  DateTime executionDate;
  DateTime dueDate;
  bool isCompleted = false;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.executionDate,
    required this.dueDate,
    required this.isCompleted,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    DateTime? executionDate,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      executionDate: executionDate ?? this.executionDate,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
