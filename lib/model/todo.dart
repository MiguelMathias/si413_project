import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ListItem {
  String name;
  Color? color;
  String uid;

  ListItem(this.color, {required this.name, required this.uid});

  factory ListItem.fromJson(Map<String, dynamic> json) =>
      _$ListItemFromJson(json);
  Map<String, dynamic> toJson() => _$TodoItemToJson(this);
}

@JsonSerializable()
class TodoItem {
  String listUid;
  String title;
  String uid;
  String? notes;
  TodoItemDetails? details;

  TodoItem(this.notes, this.details,
      {required this.listUid, required this.title, required this.uid});

  factory TodoItem.fromJson(Map<String, dynamic> json) =>
      _$TodoItemFromJson(json);
  Map<String, dynamic> toJson() => _$TodoItemToJson(this);
}

@JsonSerializable()
class TodoItemDetails {
  DateTime? date;
  TimeOfDay? time;
  List<String> tags = [];
  bool flag = false;
  Priority? priority;
  String? url;

  TodoItemDetails(
      this.date, this.time, this.tags, this.flag, this.priority, this.url);

  factory TodoItemDetails.fromJson(Map<String, dynamic> json) =>
      _$TodoItemDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$TodoItemDetailsToJson(this);
}

enum Priority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high
}
