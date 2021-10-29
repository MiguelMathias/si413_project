import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'todo.g.dart';

@JsonSerializable(explicitToJson: true)
class ListItem {
  String name;
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  Color color;
  String uid;

  static Color colorFromJson(Map<String, dynamic> json) =>
      Color.fromARGB(json['a'], json['r'], json['g'], json['b']);
  static Map<String, dynamic> colorToJson(Color color) =>
      {'a': color.alpha, 'r': color.red, 'g': color.green, 'b': color.blue};

  ListItem(this.color, {required this.name, required this.uid});

  factory ListItem.fromJson(Map<String, dynamic> json) =>
      _$ListItemFromJson(json);
  Map<String, dynamic> toJson() => _$ListItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TodoItem {
  String userUid;
  String listUid;
  String title;
  String uid;
  String? notes;
  TodoItemDetails? details;

  @JsonKey(fromJson: tsFromJson, toJson: tsToJson)
  Timestamp added;

  static Timestamp tsFromJson(Map<String, dynamic> json) =>
      Timestamp.fromMillisecondsSinceEpoch(json['millis']);
  static Map<String, dynamic> tsToJson(Timestamp ts) =>
      {'millis': ts.millisecondsSinceEpoch};

  TodoItem(
    this.notes,
    this.details,
    this.added, {
    required this.listUid,
    required this.title,
    required this.uid,
    required this.userUid,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) =>
      _$TodoItemFromJson(json);
  Map<String, dynamic> toJson() => _$TodoItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TodoItemDetails {
  DateTime? date;
  List<String> tags = [];
  bool flag = false;
  Priority? priority;
  String? url;

  TodoItemDetails(this.date, this.tags, this.flag, this.priority, this.url);

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
