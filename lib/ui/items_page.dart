import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: implementation_imports
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

///A page to display a list of TodoItems
class ItemsPage extends StatefulWidget {
  ///The list uid of the list we're viewing/editing. If empty, we're in one of the 4 filtered lists: list can't be edited.
  ///Also, if empty, sort and filter all the list items in `userData` by the given `sort` and `filter` props.
  final String listItemUid;

  ///The user data object
  final UserData userData;

  ///The firestore doc reference for the user data
  final DocumentReference<UserData> userDataRef;

  ///The title to be displayed on the page
  final String? title;

  ///Optional functions only used when `listItemUid` is empty
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
  ///The items to be displayed in list form
  late Iterable<TodoItem> items;

  ///Whether or not to show the completed todo items.
  bool showCompleted = false;

  ///The sort strategy for the todo items (dueDate, creationDate - default, priority, title)
  Sort? sortStrat;

  ///The current search text (searches todo items' title, notes, and tags via case insensitive contains)
  String searchText = '';

  @override
  Widget build(BuildContext context) => StreamBuilder<
          DocumentSnapshot<UserData>>(
      //Use a stream builder that listens to the user data doc in firestore for changes so that updated information is displayed
      stream: widget.userDataRef.snapshots(),
      builder: (context, snapshot) {
        //If widget listItemUid is empty, we're in one of the 4 filtered lists.
        //Sort and filter all the user items via the given functions.
        items = widget.listItemUid.isEmpty
            ? allItemsOfLists(widget.userData.lists)
                .sorted(widget.sort ?? (i1, i2) => 0)
                .where(widget.filter ?? (item) => true)
            : widget.userData.lists
                .firstWhere((list) => list.uid == widget.listItemUid)
                .items;
        //If the firestore user data doc stream snapshot has no data, show the loading page
        if (!snapshot.hasData) {
          return const Loading();
        }

        return CupertinoTheme(
          //The current theme should be the list's color, or the default
          data: widget.listItemUid.isNotEmpty
              ? CupertinoTheme.of(context).copyWith(
                  primaryColor: widget.userData.lists
                      .firstWhere((list) => list.uid == widget.listItemUid)
                      .color)
              : CupertinoTheme.of(context),
          child: CupertinoPageScaffold(
            //A Cupertino Page with a nav bar
            navigationBar: CupertinoNavigationBar(
              previousPageTitle: 'Home',
              middle: Text(widget
                      .title ?? //If no title provided, show the list's (found by list uid) name
                  widget.userData.lists
                      .firstWhere((list) => list.uid == widget.listItemUid)
                      .name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.listItemUid.isNotEmpty)
                    CupertinoButton(
                      //A button to add a new item
                      child: const Icon(CupertinoIcons.add),
                      onPressed: () => showCupertinoModalBottomSheet(
                          //Show a new todo item modal on click
                          context: context,
                          builder: (context) => CupertinoTheme(
                                data: CupertinoTheme.of(context).copyWith(
                                    primaryColor: widget.listItemUid.isNotEmpty
                                        ? widget.userData.lists
                                            .firstWhere((list) =>
                                                list.uid == widget.listItemUid)
                                            .color
                                        : CupertinoTheme.of(context)
                                            .primaryColor),
                                child: ItemPage(
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
                                ),
                              )),
                    ),
                  CupertinoButton(
                    //A button to bring up an action sheet where we select the sort strategy, view completed items, and can delete the list
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
                                                    userDataRef: widget
                                                        .userDataRef)).then(
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
              //Show a list of all the items
              Container(
                  //The first item in the listview is a the search field
                  padding: const EdgeInsets.all(10),
                  child: CupertinoSearchTextField(
                    onChanged: (val) => setState(() => searchText = val),
                  )),
              ...items //The items to be shown.
                  //Filtered by whether or not we're showing completed items,
                  //the search text (case insensitive contains in item title, tags, and notes),
                  //and sort by the current sort strategy (by default the date added)
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
                        //Each item is slidable with info, flag, and delete options
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
                                  .firstWhere(
                                      (item) => todoItem.uid == item.uid)
                                  .done = todoItem.done;
                              widget.userDataRef.set(widget.userData);
                            },
                          ),
                          title: Text(todoItem.title),
                          trailing: todoItem.flag
                              ? const Icon(CupertinoIcons.flag_fill,
                                  color: Colors.orange)
                              : const SizedBox.shrink(),
                          onTap: () => showCupertinoModalBottomSheet(
                              context: context,
                              builder: (context) => ItemPage(
                                  prevPageTitle: widget.title ??
                                      widget.userData.lists
                                          .firstWhere((list) =>
                                              list.uid == widget.listItemUid)
                                          .name,
                                  item: todoItem,
                                  listUid: widget.listItemUid,
                                  userData: widget.userData,
                                  userDataRef: widget.userDataRef)),
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
                                            prevPageTitle: widget.title ??
                                                widget.userData.lists
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
                                          .where((item) =>
                                              item.uid == todoItem.uid)
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
                                          .where((item) =>
                                              item.uid == todoItem.uid)
                                          .isNotEmpty);
                                  listToModify.items.removeWhere(
                                      (item) => item.uid == todoItem.uid);
                                  widget.userDataRef.set(widget.userData);
                                })
                          ],
                        )),
                  )
            ]),
          ),
        );
      });
}

//An enum of the sort strategies available
enum Sort { dueDate, creationDate, priority, title }
