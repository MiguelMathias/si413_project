import 'package:json_annotation/json_annotation.dart';

import 'todo.dart';

@JsonSerializable()
class User {
  final String displayName;
  final String uid;
  final List<ListItem> listItems = [];

  User({required this.displayName, required this.uid});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, Object?> toJson() => _$UserToJson(this);
}
