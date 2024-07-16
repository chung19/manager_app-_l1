import 'package:flutter/material.dart';

class Task {
  String id;
  String title;
  String description;
  DateTime executionDate;
  TimeOfDay startTime;
  bool isCompleted = false;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.executionDate,
    required this.startTime,
    required this.isCompleted,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TimeOfDay? startTime,
    DateTime? executionDate,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      executionDate: executionDate ?? this.executionDate,
      startTime: startTime ?? this.startTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
