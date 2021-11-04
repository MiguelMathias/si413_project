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
    );

Map<String, dynamic> _$ListItemToJson(ListItem instance) => <String, dynamic>{
      'name': instance.name,
      'color': ListItem.colorToJson(instance.color),
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

TodoItem _$TodoItemFromJson(Map<String, dynamic> json) => TodoItem(
      json['notes'] as String?,
      json['details'] == null
          ? null
          : TodoItemDetails.fromJson(json['details'] as Map<String, dynamic>),
      done: json['done'] as int,
      added: json['added'] as int,
      title: json['title'] as String,
    );

Map<String, dynamic> _$TodoItemToJson(TodoItem instance) => <String, dynamic>{
      'title': instance.title,
      'notes': instance.notes,
      'details': instance.details?.toJson(),
      'added': instance.added,
      'done': instance.done,
    };

TodoItemDetails _$TodoItemDetailsFromJson(Map<String, dynamic> json) =>
    TodoItemDetails(
      json['date'] == null ? null : DateTime.parse(json['date'] as String),
      (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      json['flag'] as bool,
      $enumDecodeNullable(_$PriorityEnumMap, json['priority']),
      json['url'] as String?,
    );

Map<String, dynamic> _$TodoItemDetailsToJson(TodoItemDetails instance) =>
    <String, dynamic>{
      'date': instance.date?.toIso8601String(),
      'tags': instance.tags,
      'flag': instance.flag,
      'priority': _$PriorityEnumMap[instance.priority],
      'url': instance.url,
    };

const _$PriorityEnumMap = {
  Priority.low: 'low',
  Priority.medium: 'medium',
  Priority.high: 'high',
};
