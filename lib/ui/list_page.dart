import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:si413_project/model/todo.dart';
import 'package:si413_project/model/user.dart';
import 'package:si413_project/ui/grouped_component.dart';

class ListPage extends StatefulWidget {
  final DocumentReference<UserData> userDataRef;
  final UserData userData;
  final bool isAdding;
  final ListItem list;
  const ListPage(
      {Key? key,
      required this.userDataRef,
      required this.userData,
      required this.list,
      this.isAdding = false})
      : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late ListItem newList;
  late TextEditingController nameFieldController;

  @override
  void initState() {
    super.initState();
    newList = ListItem.fromJson(widget.list.toJson());
    nameFieldController = TextEditingController(text: newList.name);
  }

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: 'Home',
        middle: Text(newList.name),
        trailing: CupertinoButton(
            child: const Icon(CupertinoIcons.check_mark),
            onPressed: newList.name.isNotEmpty
                ? () {
                    if (widget.isAdding) {
                      widget.userData.lists.add(newList);
                    } else {
                      widget.userData.lists = widget.userData.lists
                          .map((list) =>
                              list.uid == widget.list.uid ? newList : list)
                          .toList();
                    }
                    widget.userDataRef
                        .set(widget.userData)
                        .then((value) => Navigator.pop(context));
                  }
                : null),
      ),
      child: GroupedComponent(
        groups: [
          [
            Container(
              margin: const EdgeInsets.all(10),
              width: 100,
              height: 100,
              decoration:
                  BoxDecoration(color: newList.color, shape: BoxShape.circle),
              child: const Icon(Icons.list, size: 50, color: Colors.white),
            ),
            Row(
              children: [
                Expanded(
                  child: CupertinoListTile(
                    title: CupertinoTextField.borderless(
                      placeholder: 'Name',
                      onChanged: (val) => setState(() => newList.name = val),
                      controller: nameFieldController,
                      autofocus: true,
                    ),
                    trailing: const SizedBox.shrink(),
                  ),
                ),
              ],
            )
          ],
          [
            Container(
              margin: const EdgeInsets.all(10),
              child: Text('Color',
                  style: TextStyle(
                          fontSize: CupertinoTheme.of(context)
                              .textTheme
                              .textStyle
                              .fontSize,
                          fontWeight: FontWeight.bold,
                          color: CupertinoTheme.of(context)
                              .textTheme
                              .textStyle
                              .color)
                      .apply(
                    fontSizeFactor: 1.5,
                  )),
            ),
            Wrap(
              children: Colors.primaries
                  .map((color) => CupertinoButton(
                        child: Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                              color: color.value == newList.color.value
                                  ? color.withAlpha(127)
                                  : color,
                              shape: BoxShape.circle),
                        ),
                        onPressed: () => setState(() => newList.color = color),
                      ))
                  .toList(),
            )
          ]
        ],
      ));
}

class DeleteListDialog extends StatefulWidget {
  final UserData userData;
  final DocumentReference<UserData> userDataRef;
  final String listUid;
  final Function()? deleteAction;

  const DeleteListDialog(
      {Key? key,
      required this.listUid,
      required this.userData,
      required this.userDataRef,
      this.deleteAction})
      : super(key: key);

  @override
  State<DeleteListDialog> createState() => _DeleteListDialogState();
}

class _DeleteListDialogState extends State<DeleteListDialog> {
  late ListItem listItem;
  @override
  void initState() {
    super.initState();
    listItem =
        widget.userData.lists.firstWhere((list) => list.uid == widget.listUid);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
        title: Text('Delete list "${listItem.name}"?'),
        content: const Text('This will delete all reminders in this list.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Delete'),
            isDestructiveAction: true,
            onPressed: () {
              widget.userData.lists
                  .removeWhere((list) => list.uid == listItem.uid);
              widget.userDataRef.set(widget.userData);
              Navigator.pop(context);
              if (widget.deleteAction != null) widget.deleteAction!();
            },
          )
        ]);
  }
}
