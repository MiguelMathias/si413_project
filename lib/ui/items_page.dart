import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:si413_project/model/user.dart';
import 'package:si413_project/ui/item_page.dart';
import 'package:si413_project/ui/list_page.dart';

import '../model/todo.dart';
import 'loading.dart';

class ItemsPage extends StatefulWidget {
  final String listItemUid;
  final UserData userData;
  final DocumentReference<UserData> userDataRef;
  final String? title;
  final int Function(TodoItem, TodoItem)? sort;
  final bool Function(TodoItem)? filter;

  const ItemsPage(
      {Key? key,
      required this.listItemUid,
      required this.userData,
      required this.userDataRef,
      this.title,
      this.sort,
      this.filter})
      : super(key: key);

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  late Iterable<TodoItem> items;
  bool showCompleted = false;
  Sort? sortStrat;
  String searchText = '';

  @override
  Widget build(BuildContext context) => StreamBuilder<
          DocumentSnapshot<UserData>>(
      stream: widget.userDataRef.snapshots(),
      builder: (context, snapshot) {
        items = widget.listItemUid.isEmpty
            ? allItemsOfLists(widget.userData.lists)
                .sorted(widget.sort ?? (i1, i2) => 0)
                .where(widget.filter ?? (item) => true)
            : widget.userData.lists
                .firstWhere((list) => list.uid == widget.listItemUid)
                .items;

        if (!snapshot.hasData) {
          return const Loading();
        }
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            previousPageTitle: 'Home',
            middle: Text(widget.title ??
                widget.userData.lists
                    .firstWhere((list) => list.uid == widget.listItemUid)
                    .name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.listItemUid.isNotEmpty)
                  CupertinoButton(
                    child: const Icon(CupertinoIcons.add),
                    onPressed: () => showCupertinoModalBottomSheet(
                        context: context,
                        builder: (context) => ItemPage(
                              prevPageTitle: widget.title ??
                                  widget.userData.lists
                                      .firstWhere((list) =>
                                          list.uid == widget.listItemUid)
                                      .name,
                              item: TodoItem('', null, [], false, null,
                                  added: 0, done: 0, title: ''),
                              listUid: widget.listItemUid,
                              userData: widget.userData,
                              userDataRef: widget.userDataRef,
                              isAdding: true,
                            )),
                  ),
                CupertinoButton(
                  child: const Icon(CupertinoIcons.ellipsis_circle),
                  onPressed: () => showCupertinoModalPopup(
                      context: context,
                      builder: (context) => CupertinoActionSheet(
                              title: const Text('Options'),
                              cancelButton: CupertinoActionSheetAction(
                                child: const Text('Cancel'),
                                onPressed: () => Navigator.pop(context),
                              ),
                              actions: [
                                ...{
                                  'Due Date': Sort.dueDate,
                                  'Creation Date': Sort.creationDate,
                                  'Priority': Sort.priority,
                                  'Title': Sort.title
                                }
                                    .map((sortStratName, strat) => MapEntry(
                                        sortStratName,
                                        CupertinoActionSheetAction(
                                          child: Row(
                                            children: [
                                              const Spacer(),
                                              if (sortStrat == strat)
                                                Row(
                                                  children: const [
                                                    Icon(CupertinoIcons
                                                        .check_mark),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                  ],
                                                ),
                                              Text('Sort by $sortStratName'),
                                              const Spacer(),
                                            ],
                                          ),
                                          onPressed: () {
                                            setState(() => sortStrat =
                                                sortStrat == strat
                                                    ? null
                                                    : strat);
                                            Navigator.pop(context);
                                          },
                                        )))
                                    .values,
                                CupertinoActionSheetAction(
                                  child: Row(
                                    children: [
                                      const Spacer(),
                                      Text(
                                          '${showCompleted ? 'Hide' : 'Show'} Completed'),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      if (showCompleted)
                                        const Icon(CupertinoIcons.eye_slash)
                                      else
                                        const Icon(CupertinoIcons.eye),
                                      const Spacer(),
                                    ],
                                  ),
                                  onPressed: () {
                                    setState(
                                        () => showCompleted = !showCompleted);
                                    Navigator.pop(context);
                                  },
                                ),
                                if (widget.listItemUid.isNotEmpty)
                                  CupertinoActionSheetAction(
                                      child: const Text('Show List Details'),
                                      onPressed: () => showCupertinoModalBottomSheet(
                                              context: context,
                                              builder: (context) =>
                                                  ListPage(
                                                      userData: snapshot.data!
                                                          .data()!,
                                                      userDataRef: widget
                                                          .userDataRef,
                                                      list: widget
                                                          .userData.lists
                                                          .firstWhere((list) =>
                                                              list.uid ==
                                                              widget
                                                                  .listItemUid)))
                                          .whenComplete(
                                              () => Navigator.pop(context))),
                                if (widget.listItemUid.isNotEmpty)
                                  CupertinoActionSheetAction(
                                    child: const Text('Delete List',
                                        style: TextStyle(color: Colors.red)),
                                    onPressed: () {
                                      showCupertinoDialog(
                                          context: context,
                                          builder: (context) =>
                                              DeleteListDialog(
                                                  listUid: widget.listItemUid,
                                                  userData: widget.userData,
                                                  deleteAction: () =>
                                                      Navigator.pop(context),
                                                  userDataRef:
                                                      widget.userDataRef)).then(
                                          (value) {
                                        Navigator.pop(context);
                                      });
                                    },
                                  )
                              ])),
                )
              ],
            ),
          ),
          child: ListView(children: [
            Container(
                padding: const EdgeInsets.all(10),
                child: CupertinoSearchTextField(
                  onChanged: (val) => setState(() => searchText = val),
                )),
            ...items
                .where((item) {
                  if (showCompleted) return true;
                  return item.done == 0;
                })
                .where((item) => searchText.isEmpty
                    ? true
                    : item.tags.any((tag) => tag
                            .toLowerCase()
                            .contains(searchText.toLowerCase())) ||
                        item.title
                            .toLowerCase()
                            .contains(searchText.toLowerCase()) ||
                        item.notes.contains(searchText.toLowerCase()))
                .sorted((itemA, itemB) {
                  switch (sortStrat) {
                    case Sort.dueDate:
                      if (itemA.date != null && itemB.date != null) {
                        return itemA.date!.compareTo(itemB.date!);
                      }
                      return 0;
                    case Sort.creationDate:
                      return itemA.added.compareTo(itemB.added);
                    case Sort.priority:
                      if (itemA.priority != null && itemB.priority != null) {
                        return itemB.priority!.index
                            .compareTo(itemA.priority!.index);
                      }
                      return 0;
                    case Sort.title:
                      return itemA.title.compareTo(itemB.title);
                    default:
                      return 0;
                  }
                })
                .map(
                  (todoItem) => Slidable(
                      child: CupertinoListTile(
                        leading: CupertinoButton(
                          child: Icon(todoItem.done > 0
                              ? CupertinoIcons.largecircle_fill_circle
                              : CupertinoIcons.circle),
                          onPressed: () {
                            todoItem.done = todoItem.done == 0
                                ? DateTime.now().millisecondsSinceEpoch
                                : 0;
                            final listToModify = widget.userData.lists
                                .firstWhere((list) => list.items
                                    .where((item) => item.uid == todoItem.uid)
                                    .isNotEmpty);
                            listToModify.items
                                .firstWhere((item) => todoItem.uid == item.uid)
                                .done = todoItem.done;
                            widget.userDataRef.set(widget.userData);
                          },
                        ),
                        title: Text(todoItem.title),
                        trailing: todoItem.flag
                            ? const Icon(CupertinoIcons.flag_fill,
                                color: Colors.orange)
                            : const SizedBox.shrink(),
                      ),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        children: [
                          SlidableAction(
                              backgroundColor: Colors.grey.shade700,
                              label: 'Details',
                              icon: CupertinoIcons.info_circle_fill,
                              onPressed: (context) =>
                                  showCupertinoModalBottomSheet(
                                      context: context,
                                      builder: (context) => ItemPage(
                                          prevPageTitle: widget
                                                  .title ??
                                              widget
                                                  .userData.lists
                                                  .firstWhere((list) =>
                                                      list.uid ==
                                                      widget.listItemUid)
                                                  .name,
                                          item: todoItem,
                                          listUid: widget.listItemUid,
                                          userData: widget.userData,
                                          userDataRef: widget.userDataRef))),
                          SlidableAction(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              label: todoItem.flag ? 'Unflag' : 'Flag',
                              icon: CupertinoIcons.flag_fill,
                              onPressed: (context) {
                                final listToModify = widget.userData.lists
                                    .firstWhere((list) => list.items
                                        .where(
                                            (item) => item.uid == todoItem.uid)
                                        .isNotEmpty);
                                listToModify.items
                                    .firstWhere(
                                        (item) => item.uid == todoItem.uid)
                                    .flag = !todoItem.flag;
                                widget.userDataRef.set(widget.userData);
                              }),
                          SlidableAction(
                              backgroundColor: Colors.red,
                              label: 'Delete',
                              icon: CupertinoIcons.delete,
                              onPressed: (context) {
                                final listToModify = widget.userData.lists
                                    .firstWhere((list) => list.items
                                        .where(
                                            (item) => item.uid == todoItem.uid)
                                        .isNotEmpty);
                                listToModify.items.removeWhere(
                                    (item) => item.uid == todoItem.uid);
                                widget.userDataRef.set(widget.userData);
                              })
                        ],
                      )),
                )
          ]),
        );
      });
}

enum Sort { dueDate, creationDate, priority, title }
