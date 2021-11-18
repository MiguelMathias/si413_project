import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'todo.g.dart';

///A class representing a list of todo items each list has a name, color, list of todoitems, and uid generating once on construction
@JsonSerializable(explicitToJson: true)
class ListItem {
  String name;
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  Color color;
  List<TodoItem> items;
  String uid = const Uuid().v4();

  ///Conversion methods for colors to json and back (each color is stored in rgba format)
  static Color colorFromJson(Map<String, dynamic> json) =>
      Color.fromARGB(json['a'], json['r'], json['g'], json['b']);
  static Map<String, dynamic> colorToJson(Color color) =>
      {'a': color.alpha, 'r': color.red, 'g': color.green, 'b': color.blue};

  ///ListItem constructor takign a color, name, and items
  ListItem({required this.color, required this.name, required this.items});

  ///The json_annotation package generated conversion methods to and from json
  factory ListItem.fromJson(Map<String, dynamic> json) =>
      _$ListItemFromJson(json);
  Map<String, dynamic> toJson() => _$ListItemToJson(this);
}

///A single todo item. Has a title, notes, Unix epoch time added/marked done, uid generating once on construction,
///and optionally a date, list of tags, flag other than false, and priority
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

  ///TodoItem constructor, optional notes, date, tags, flag, and priority with required done, added, and title.
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

  ///The json_annotation package generated conversion methods to and from json
  factory TodoItem.fromJson(Map<String, dynamic> json) =>
      _$TodoItemFromJson(json);
  Map<String, dynamic> toJson() => _$TodoItemToJson(this);
}

//Priority enum with json converter values
enum Priority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high
}

//Get all the items of a list of lists
List<TodoItem> allItemsOfLists(List<ListItem> lists) =>
    lists.fold<List<TodoItem>>(
        [], (itemsAccum, list) => itemsAccum.toList() + list.items).toList();
