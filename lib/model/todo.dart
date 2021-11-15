import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'todo.g.dart';

@JsonSerializable(explicitToJson: true)
class ListItem {
  String name;
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  Color color;
  List<TodoItem> items;
  String uid = const Uuid().v4();

  static Color colorFromJson(Map<String, dynamic> json) =>
      Color.fromARGB(json['a'], json['r'], json['g'], json['b']);
  static Map<String, dynamic> colorToJson(Color color) =>
      {'a': color.alpha, 'r': color.red, 'g': color.green, 'b': color.blue};

  ListItem({required this.color, required this.name, required this.items});

  factory ListItem.fromJson(Map<String, dynamic> json) =>
      _$ListItemFromJson(json);
  Map<String, dynamic> toJson() => _$ListItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TodoItem {
  String title;
  String notes = '';
  DateTime? date;
  List<String> tags = [];
  bool flag = false;
  Priority? priority;
  int added;
  int done;
  String uid = const Uuid().v4();

  TodoItem(
    this.notes,
    this.date,
    this.tags,
    this.flag,
    this.priority, {
    required this.done,
    required this.added,
    required this.title,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) =>
      _$TodoItemFromJson(json);
  Map<String, dynamic> toJson() => _$TodoItemToJson(this);
}

enum Priority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high
}

List<TodoItem> allItemsOfLists(List<ListItem> lists) =>
    lists.fold<List<TodoItem>>(
        [], (itemsAccum, list) => itemsAccum.toList() + list.items).toList();
