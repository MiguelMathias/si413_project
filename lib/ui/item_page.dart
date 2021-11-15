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

class ItemPage extends StatefulWidget {
  final TodoItem item;
  final String listUid;
  final DocumentReference<UserData> userDataRef;
  final UserData userData;
  final bool isAdding;
  final String prevPageTitle;

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
  late TextEditingController titleFieldController;
  late TextEditingController notesFieldController;
  late TextEditingController newTagFieldController;
  final DateFormat formatter = DateFormat('h:mm E, MMM d, yyyy');
  late TodoItem newItem;

  @override
  void initState() {
    super.initState();
    newItem = TodoItem.fromJson(widget.item.toJson());
    titleFieldController = TextEditingController(text: newItem.title);
    notesFieldController = TextEditingController(text: newItem.notes);
    newTagFieldController = TextEditingController(text: '');
  }

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          previousPageTitle: widget.prevPageTitle,
          middle: Text(newItem.title),
          trailing: CupertinoButton(
            child: const Icon(CupertinoIcons.check_mark),
            onPressed: newItem.title.isNotEmpty
                ? () {
                    if (widget.isAdding) {
                      newItem.added = DateTime.now().millisecondsSinceEpoch;
                      widget.userData.lists
                          .firstWhere((list) => list.uid == widget.listUid)
                          .items
                          .add(newItem);
                    } else {
                      final listToModify = widget.userData.lists.firstWhere(
                          (list) => list.items
                              .where((item) => item.uid == widget.item.uid)
                              .isNotEmpty);
                      listToModify.items = listToModify.items
                          .map((item) =>
                              item.uid == widget.item.uid ? newItem : item)
                          .toList();
                    }

                    widget.userDataRef
                        .set(widget.userData)
                        .then((value) => Navigator.pop(context));
                  }
                : null,
          )),
      child: GroupedComponent(
        groups: [
          [
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
                  onChanged: (newVal) => newVal
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
                                        CupertinoButton(
                                          child: const Text('Cancel'),
                                          onPressed: () => setState(() {
                                            newItem.date = null;
                                            Navigator.of(context).pop();
                                          }),
                                        ),
                                        const Spacer(),
                                        CupertinoButton(
                                          child: const Text('Select'),
                                          onPressed: () => setState(() {
                                            newItem.date =
                                                newItem.date ?? DateTime.now();
                                            Navigator.of(context).pop();
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
                      : setState(() => newItem.date = null)),
            )
          ],
          [
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
