// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListItem _$ListItemFromJson(Map<String, dynamic> json) => ListItem(
      color: ListItem.colorFromJson(json['color'] as Map<String, dynamic>),
      name: json['name'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    )..uid = json['uid'] as String;

Map<String, dynamic> _$ListItemToJson(ListItem instance) => <String, dynamic>{
      'name': instance.name,
      'color': ListItem.colorToJson(instance.color),
      'items': instance.items.map((e) => e.toJson()).toList(),
      'uid': instance.uid,
    };

TodoItem _$TodoItemFromJson(Map<String, dynamic> json) => TodoItem(
      json['notes'] as String,
      json['date'] == null ? null : DateTime.parse(json['date'] as String),
      (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      json['flag'] as bool,
      $enumDecodeNullable(_$PriorityEnumMap, json['priority']),
      done: json['done'] as int,
      added: json['added'] as int,
      title: json['title'] as String,
    )..uid = json['uid'] as String;

Map<String, dynamic> _$TodoItemToJson(TodoItem instance) => <String, dynamic>{
      'title': instance.title,
      'notes': instance.notes,
      'date': instance.date?.toIso8601String(),
      'tags': instance.tags,
      'flag': instance.flag,
      'priority': _$PriorityEnumMap[instance.priority],
      'added': instance.added,
      'done': instance.done,
      'uid': instance.uid,
    };

const _$PriorityEnumMap = {
  Priority.low: 'low',
  Priority.medium: 'medium',
  Priority.high: 'high',
};
