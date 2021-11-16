import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:si413_project/model/todo.dart';
import 'package:si413_project/model/user.dart';
import 'package:si413_project/ui/grouped_component.dart';
import 'package:si413_project/ui/item_page.dart';
import 'package:si413_project/ui/loading.dart';

import 'items_page.dart';
import 'list_page.dart';

class ListsPage extends StatefulWidget {
  final User user;

  const ListsPage({Key? key, required this.user}) : super(key: key);

  @override
  State<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  late DocumentReference<UserData> userDataRef;

  @override
  void initState() {
    super.initState();
    userDataRef = FirebaseFirestore.instance
        .doc('users/${widget.user.uid}')
        .withConverter<UserData>(
            fromFirestore: (snapshot, _) => UserData.fromJson(snapshot.data()!),
            toFirestore: (userData, _) => userData.toJson());
  }

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<DocumentSnapshot<UserData>>(
        stream: userDataRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            userDataRef.get().then((userDataDoc) {
              if (!userDataDoc.exists) {
                userDataRef.set(UserData([],
                    displayName: widget.user.displayName ?? '',
                    uid: widget.user.uid));
              }
            });
            return const Loading();
          }

          final UserData userData = snapshot.data!.data()!;
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
                leading: CupertinoButton(
                    child: const Icon(CupertinoIcons.escape),
                    onPressed: () => FirebaseAuth.instance.signOut()),
                middle: Text(widget.user.displayName ?? ''),
                trailing: CupertinoButton(
                    child: const Icon(CupertinoIcons.add),
                    onPressed: () => showCupertinoModalBottomSheet(
                        context: context,
                        builder: (context) => ListPage(
                            isAdding: true,
                            userData: snapshot.data!.data()!,
                            userDataRef: userDataRef,
                            list: ListItem(
                                color: Colors.blue, name: '', items: []))))),
            child: GroupedComponent(
              groups: [
                [
                  Container(
                      decoration: BoxDecoration(
                          color: CupertinoTheme.of(context)
                              .scaffoldBackgroundColor),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  color: CupertinoTheme.of(context)
                                      .barBackgroundColor),
                              child: CupertinoButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => ItemsPage(
                                            listItemUid: '',
                                            userData: snapshot.data!.data()!,
                                            userDataRef: userDataRef,
                                            title: 'Due Today',
                                            filter: (item) {
                                              if (item.date != null) {
                                                final now = DateTime.now();
                                                return item.date!.day ==
                                                        now.day &&
                                                    item.date!.month ==
                                                        now.month &&
                                                    item.date!.year == now.year;
                                              }
                                              return false;
                                            },
                                            sort: (itemA, itemB) {
                                              if (itemA.date != null &&
                                                  itemB.date != null) {
                                                return itemA.date!
                                                    .compareTo(itemB.date!);
                                              }
                                              return 0;
                                            }),
                                      ));
                                },
                                child: Column(
                                  children: [
                                    const IconWithBackground(
                                        color: Colors.blue,
                                        icon: CupertinoIcons.calendar_today),
                                    const SizedBox(height: 10),
                                    Text('Today',
                                        style: TextStyle(
                                            color: CupertinoTheme.of(context)
                                                .textTheme
                                                .textStyle
                                                .color))
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 10),
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  color: CupertinoTheme.of(context)
                                      .barBackgroundColor),
                              child: CupertinoButton(
                                onPressed: () => Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => ItemsPage(
                                          listItemUid: '',
                                          userData: snapshot.data!.data()!,
                                          userDataRef: userDataRef,
                                          title: 'Scheduled',
                                          filter: (item) => item.date != null,
                                          sort: (itemA, itemB) {
                                            if (itemA.date != null &&
                                                itemB.date != null) {
                                              return itemA.date!
                                                  .compareTo(itemB.date!);
                                            }
                                            return 0;
                                          }),
                                    )),
                                child: Column(children: [
                                  const IconWithBackground(
                                      color: Colors.red,
                                      icon: CupertinoIcons.calendar),
                                  const SizedBox(height: 10),
                                  Text('Scheduled',
                                      style: TextStyle(
                                          color: CupertinoTheme.of(context)
                                              .textTheme
                                              .textStyle
                                              .color))
                                ]),
                              ),
                            ),
                          ),
                        ],
                      ))
                ],
                [
                  Container(
                      decoration: BoxDecoration(
                          color: CupertinoTheme.of(context)
                              .scaffoldBackgroundColor),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  color: CupertinoTheme.of(context)
                                      .barBackgroundColor),
                              child: CupertinoButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => ItemsPage(
                                            listItemUid: '',
                                            userData: snapshot.data!.data()!,
                                            userDataRef: userDataRef,
                                            title: 'All'),
                                      ));
                                },
                                child: Column(
                                  children: [
                                    const IconWithBackground(
                                        color: Colors.grey,
                                        icon: CupertinoIcons.tray),
                                    const SizedBox(height: 10),
                                    Text('All',
                                        style: TextStyle(
                                            color: CupertinoTheme.of(context)
                                                .textTheme
                                                .textStyle
                                                .color))
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 10),
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  color: CupertinoTheme.of(context)
                                      .barBackgroundColor),
                              child: CupertinoButton(
                                onPressed: () => Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => ItemsPage(
                                              listItemUid: '',
                                              userData: snapshot.data!.data()!,
                                              userDataRef: userDataRef,
                                              title: 'Flagged',
                                              filter: (item) => item.flag,
                                            ))),
                                child: Column(children: [
                                  const IconWithBackground(
                                      color: Colors.orange,
                                      icon: CupertinoIcons.flag_fill),
                                  const SizedBox(height: 10),
                                  Text('Flagged',
                                      style: TextStyle(
                                          color: CupertinoTheme.of(context)
                                              .textTheme
                                              .textStyle
                                              .color))
                                ]),
                              ),
                            ),
                          ),
                        ],
                      ))
                ],
                [
                  Container(
                      decoration: BoxDecoration(
                          color: CupertinoTheme.of(context)
                              .scaffoldBackgroundColor),
                      child: Row(
                        children: [
                          Text('My Lists',
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
                        ],
                      ))
                ],
                userData.lists
                    .map((listItem) => Slidable(
                          child: CupertinoListTile(
                            leading: Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                  color: listItem.color,
                                  shape: BoxShape.circle),
                            ),
                            title: Text(listItem.name),
                            onTap: () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => ItemsPage(
                                        listItemUid: listItem.uid,
                                        userData: snapshot.data!.data()!,
                                        userDataRef: userDataRef))),
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
                                            builder: (context) => ListPage(
                                                userData:
                                                    snapshot.data!.data()!,
                                                userDataRef: userDataRef,
                                                list: listItem))),
                                SlidableAction(
                                    backgroundColor: Colors.red,
                                    label: 'Delete',
                                    icon: CupertinoIcons.delete,
                                    onPressed: (context) => showCupertinoDialog(
                                        context: context,
                                        builder: (context) => DeleteListDialog(
                                            listUid: listItem.uid,
                                            userData: userData,
                                            userDataRef: userDataRef)))
                              ]),
                        ))
                    .toList(),
              ],
            ),
          );
        },
      );
}
