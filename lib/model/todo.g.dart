// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListItem _$ListItemFromJson(Map<String, dynamic> json) => ListItem(
      ListItem.colorFromJson(json['color'] as Map<String, dynamic>),
      name: json['name'] as String,
      uid: json['uid'] as String,
    );

Map<String, dynamic> _$ListItemToJson(ListItem instance) => <String, dynamic>{
      'name': instance.name,
      'color': ListItem.colorToJson(instance.color),
      'uid': instance.uid,
    };

TodoItem _$TodoItemFromJson(Map<String, dynamic> json) => TodoItem(
      json['notes'] as String?,
      json['details'] == null
          ? null
          : TodoItemDetails.fromJson(json['details'] as Map<String, dynamic>),
      TodoItem.tsFromJson(json['added'] as Map<String, dynamic>),
      listUid: json['listUid'] as String,
      title: json['title'] as String,
      uid: json['uid'] as String,
      userUid: json['userUid'] as String,
    );

Map<String, dynamic> _$TodoItemToJson(TodoItem instance) => <String, dynamic>{
      'userUid': instance.userUid,
      'listUid': instance.listUid,
      'title': instance.title,
      'uid': instance.uid,
      'notes': instance.notes,
      'details': instance.details?.toJson(),
      'added': TodoItem.tsToJson(instance.added),
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
