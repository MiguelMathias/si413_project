import 'package:json_annotation/json_annotation.dart';

import 'todo.dart';

part 'user.g.dart';

//A class representing a user's data, including their display name, uid, and a list of their todo lists.
@JsonSerializable(explicitToJson: true)
class UserData {
  final String displayName;
  final String uid;
  List<ListItem> lists = [];

  //UserData constructor with optional list of ListItems and required displayName and uid
  UserData(this.lists, {required this.displayName, required this.uid});

  ///The json_annotation package generated conversion methods to and from json
  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);
  Map<String, Object?> toJson() => _$UserDataToJson(this);
}
