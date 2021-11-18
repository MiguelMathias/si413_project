import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:si413_project/model/todo.dart';
import 'package:si413_project/model/user.dart';
import 'package:si413_project/ui/grouped_component.dart';

///A widget to edit or add a new list
class ListPage extends StatefulWidget {
  ///Firestore user data doc reference
  final DocumentReference<UserData> userDataRef;

  ///The current user data
  final UserData userData;

  ///Whether or not we're adding a new item
  final bool isAdding;

  ///The initial list to be edited
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
  ///The new list item
  late ListItem newList;

  ///The controller for the name field
  late TextEditingController nameFieldController;

  @override
  void initState() {
    super.initState();

    ///Initialize the newList item via deep copy
    newList = ListItem.fromJson(widget.list.toJson());

    ///Initialize the nameFieldController
    nameFieldController = TextEditingController(text: newList.name);
  }

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
      //A Cupertino Page with a navigation bar
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: 'Home',
        middle: Text(newList.name),
        trailing: CupertinoButton(
            //The button to submit changes
            child: const Icon(CupertinoIcons.check_mark),
            onPressed: newList.name.isNotEmpty //If the list name isn't empty
                ? () {
                    if (widget.isAdding) {
                      //If we're adding, add the new list to the current user data lists
                      widget.userData.lists.add(newList);
                    } else {
                      //If we're editing, find the list of the given list uid and replace it
                      widget.userData.lists = widget.userData.lists
                          .map((list) =>
                              list.uid == widget.list.uid ? newList : list)
                          .toList();
                    }
                    //Send the changes to firestore
                    widget.userDataRef
                        .set(widget.userData)
                        .whenComplete(() => Navigator.pop(context));
                  } //If the list name is empty, this button should be disabled
                : null),
      ),
      child: GroupedComponent(
        groups: [
          [
            //The first group is the big colored list icon and the list name text field
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
            //The second group is the color selection group
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

///A widget to bring up a Cupertino style warning alert when the user is trying to delete a list
class DeleteListDialog extends StatefulWidget {
  ///The user data
  final UserData userData;

  ///The firestore user data document reference
  final DocumentReference<UserData> userDataRef;

  ///The listUid to be deleting
  final String listUid;

  ///An optional action to run on completion of deletion
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
  ///The list item that we're deleting
  late ListItem listItem;
  @override
  void initState() {
    super.initState();
    //Find the list item via uid and set listItem
    listItem =
        widget.userData.lists.firstWhere((list) => list.uid == widget.listUid);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
        //A Cupertino Alert Dialog of actions 'Cancel' and 'Delete'
        title: Text('Delete list "${listItem.name}"?'),
        content: const Text('This will delete all reminders in this list.'),
        actions: [
          CupertinoDialogAction(
            //Cancelling simply pops the dialog off the navigator stack
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            //Deletion deletes the item from firestore
            child: const Text('Delete'),
            isDestructiveAction: true,
            onPressed: () {
              //Remove the list from user data
              widget.userData.lists
                  .removeWhere((list) => list.uid == listItem.uid);
              //Pop the dialog off the navigator stack
              Navigator.pop(context);
              //Run the delete action
              if (widget.deleteAction != null) widget.deleteAction!();
              //Set the user data in firestore
              widget.userDataRef.set(widget.userData);
            },
          )
        ]);
  }
}
