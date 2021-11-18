import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:si413_project/model/todo.dart';
import 'package:si413_project/model/user.dart';
import 'package:si413_project/ui/grouped_component.dart';
import 'package:si413_project/util.dart';

///A stateful widget of a page for interacting with and adding/changing a TodoItem
class ItemPage extends StatefulWidget {
  ///The initial item to be editing
  final TodoItem item;

  ///The listUid of the list this item belongs to
  final String listUid;

  ///The document reference we use to update the information stored in firestore
  final DocumentReference<UserData> userDataRef;

  //The current userdata
  final UserData userData;

  ///Are we adding a new TodoItem?
  final bool isAdding;

  ///The title of the previous page
  final String prevPageTitle;

  ///ItemPage constructor
  const ItemPage(
      {Key? key,
      required this.item,
      required this.listUid,
      required this.userData,
      required this.userDataRef,
      required this.prevPageTitle,
      this.isAdding = false})
      : super(key: key);

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  ///The controllers for the text fields of the item's title, notes, and new tags
  late TextEditingController titleFieldController;
  late TextEditingController notesFieldController;
  late TextEditingController newTagFieldController;

  ///A date formatter to display a nice date
  final DateFormat formatter = DateFormat('h:mm E, MMM d, yyyy');

  ///The new TodoItem to replace the one given to the widget by the parent in firestore.
  ///Any changes we make are on this item.
  late TodoItem newItem;

  ///Initialize all the late variables
  @override
  void initState() {
    super.initState();
    //Deep copy the given widget TodoItem into newItem to ensure no
    //original fields are accidentally referenced by the new item
    newItem = TodoItem.fromJson(widget.item.toJson());
    titleFieldController = TextEditingController(text: newItem.title);
    notesFieldController = TextEditingController(text: newItem.notes);
    newTagFieldController = TextEditingController(text: '');
  }

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
      //A Cupertino Page with a navigation bar
      navigationBar: CupertinoNavigationBar(
          previousPageTitle: widget.prevPageTitle,
          middle: Text(newItem.title),
          trailing: CupertinoButton(
            //A button to navigate back from this page and push changes to firestore
            child: const Icon(CupertinoIcons.check_mark),
            //Button should only be enabled if the newItem title isn't empty
            onPressed: newItem.title.isNotEmpty
                ? () {
                    if (widget.isAdding) {
                      //If we're adding, set the added to the current Unix epoch time
                      newItem.added = DateTime.now().millisecondsSinceEpoch;
                      //Add the item to the user's data's list where the listUid is equal to the given widget listUid
                      widget.userData.lists
                          .firstWhere((list) => list.uid == widget.listUid)
                          .items
                          .add(newItem);
                    } else {
                      //If we're updating, replace the list where the listUid is equal to the given widget listUid
                      //with the same list, but with the original widget item (as by uid) replaced with the new item
                      final listToModify = widget.userData.lists.firstWhere(
                          (list) => list.items
                              .where((item) => item.uid == widget.item.uid)
                              .isNotEmpty);
                      listToModify.items = listToModify.items
                          .map((item) =>
                              item.uid == widget.item.uid ? newItem : item)
                          .toList();
                    }

                    //Update the user data in firestore
                    widget.userDataRef
                        .set(widget.userData)
                        .whenComplete(() => Navigator.pop(context));
                  }
                : null,
          )),
      child: GroupedComponent(
        groups: [
          [
            //The first group of components is the name and notes text fields
            CupertinoListTile(
              title: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField.borderless(
                      autofocus: true,
                      placeholder: 'Name',
                      onChanged: (val) => setState(() => newItem.title = val),
                      controller: titleFieldController,
                    ),
                  ),
                ],
              ),
              trailing: const SizedBox.shrink(),
            ),
            CupertinoListTile(
              title: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField.borderless(
                        placeholder: 'Notes',
                        maxLines: 5,
                        minLines: 1,
                        onChanged: (val) => setState(() => newItem.notes = val),
                        controller: notesFieldController),
                  ),
                ],
              ),
              trailing: const SizedBox.shrink(),
            )
          ],
          [
            //The second group of components is just the due date editor
            CupertinoListTile(
              leading: const IconWithBackground(
                color: Colors.red,
                icon: CupertinoIcons.calendar,
              ),
              title: const Text('Due Date'),
              subtitle: newItem.date != null
                  ? Text(formatter.format(newItem.date!),
                      style: TextStyle(
                          color: CupertinoTheme.of(context).primaryColor))
                  : null,
              trailing: CupertinoSwitch(
                  value: newItem.date != null,
                  onChanged: (newVal) =>
                      newVal //If the switch is on, show the date selection popup
                          ? showCupertinoModalPopup(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Container(
                                    height: 452,
                                    color: CupertinoTheme.of(context)
                                        .scaffoldBackgroundColor,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            //The date selection popup has cancel and confirm buttons
                                            CupertinoButton(
                                              child: const Text('Cancel'),
                                              onPressed: () => setState(() {
                                                newItem.date = null;
                                                Navigator.pop(context);
                                              }),
                                            ),
                                            const Spacer(),
                                            CupertinoButton(
                                              child: const Text('Confirm'),
                                              onPressed: () => setState(() {
                                                newItem.date = newItem.date ??
                                                    DateTime.now();
                                                Navigator.pop(context);
                                              }),
                                            )
                                          ],
                                        ),
                                        // ignore: sized_box_for_whitespace
                                        Container(
                                          height: 400,
                                          child: CupertinoDatePicker(
                                              initialDateTime: newItem.date,
                                              onDateTimeChanged: (newDate) =>
                                                  newItem.date = newDate),
                                        ),
                                      ],
                                    ),
                                  ))
                          //If the switch is off, set the new date to null
                          : setState(() => newItem.date = null)),
            )
          ],
          [
            //The third group of components is the tags group.
            //This group has a title list tile which only says 'Tags",
            //a list of tags that the item currently has, and
            //a field to add a tag
            const CupertinoListTile(
              leading: IconWithBackground(
                color: Colors.grey,
                icon: CupertinoIcons.tag,
              ),
              title: Text('Tags'),
              trailing: SizedBox.shrink(),
            ),
            ...newItem.tags.map((tag) => Slidable(
                  child: CupertinoListTile(
                    title: Text(tag,
                        style: TextStyle(
                            color: CupertinoTheme.of(context).primaryColor)),
                    trailing: const SizedBox.shrink(),
                  ),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        backgroundColor: Colors.red,
                        label: 'Delete',
                        icon: CupertinoIcons.delete,
                        onPressed: (context) =>
                            setState(() => newItem.tags.remove(tag)),
                      )
                    ],
                  ),
                )),
            CupertinoListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: CupertinoTextField.borderless(
                        placeholder: 'New Tag',
                        controller: newTagFieldController,
                      ),
                    ),
                  ],
                ),
                trailing: CupertinoButton(
                    child: const Icon(CupertinoIcons.add),
                    onPressed: () => setState(() {
                          newItem.tags.add(newTagFieldController.text);
                          newTagFieldController.text = '';
                        }))),
          ],
          [
            //The fourth group is just a switch to flag this item
            CupertinoListTile(
              leading: const IconWithBackground(
                  color: Colors.orange, icon: CupertinoIcons.flag_fill),
              title: const Text('Flag'),
              trailing: CupertinoSwitch(
                value: newItem.flag,
                onChanged: (newFlag) => setState(() => newItem.flag = newFlag),
              ),
            )
          ],
          [
            //The last group is the priority (none = null, low, medium, high) for the item
            const CupertinoListTile(
              leading: IconWithBackground(
                  color: Colors.blue,
                  icon: CupertinoIcons.exclamationmark_circle_fill),
              title: Text('Priority'),
              trailing: SizedBox.shrink(),
            ),
            CupertinoListTile(
              title: const Text('None'),
              trailing: newItem.priority == null
                  ? const Icon(CupertinoIcons.check_mark)
                  : const SizedBox.shrink(),
              onTap: () => setState(() => newItem.priority = null),
            ),
            ...Priority.values.map((priority) => CupertinoListTile(
                  title: Text(priority
                      .toString()
                      .replaceAll('Priority.', '')
                      .capitalize()),
                  trailing: newItem.priority == priority
                      ? const Icon(CupertinoIcons.check_mark)
                      : const SizedBox.shrink(),
                  onTap: () => setState(() => newItem.priority = priority),
                ))
          ]
        ],
      ));
}

///A widget to show an icon with a rounded square background of a given color
class IconWithBackground extends StatelessWidget {
  final Color color;
  final IconData icon;
  const IconWithBackground({
    required this.color,
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: Icon(
          icon,
          color: Colors.white,
        ));
  }
}
