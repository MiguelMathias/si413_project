import 'package:json_annotation/json_annotation.dart';

import 'todo.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class UserData {
  final String displayName;
  final String uid;
  List<ListItem> lists = [];

  UserData(this.lists, {required this.displayName, required this.uid});

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  Map<String, Object?> toJson() => _$UserDataToJson(this);
}
