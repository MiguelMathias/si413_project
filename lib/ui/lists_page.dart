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

///A widget to show a page of the user's lists, the home page essentially
class ListsPage extends StatefulWidget {
  ///The current user
  final User user;

  const ListsPage({Key? key, required this.user}) : super(key: key);

  @override
  State<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  ///The user data firestore document reference
  late DocumentReference<UserData> userDataRef;

  @override
  void initState() {
    super.initState();

    ///Set the user data firestore document reference
    userDataRef = FirebaseFirestore.instance
        .doc('users/${widget.user.uid}')
        .withConverter<UserData>(
            fromFirestore: (snapshot, _) => UserData.fromJson(snapshot.data()!),
            toFirestore: (userData, _) => userData.toJson());
  }

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<DocumentSnapshot<UserData>>(
        //Listen to the stream of user data document changes
        stream: userDataRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            userDataRef.get().then((userDataDoc) {
              //If the user data doesn't exist, set it as the default user data doc for the current firebase user
              if (!userDataDoc.exists) {
                userDataRef.set(UserData([],
                    displayName: widget.user.displayName ?? '',
                    uid: widget.user.uid));
              }
            });
            //Return loading while the snapshot has no data
            return const Loading();
          }

          final UserData userData = snapshot.data!.data()!;

          return CupertinoPageScaffold(
            //A Cupertino Page with a nav bar
            navigationBar: CupertinoNavigationBar(
                leading: CupertinoButton(
                    //The logout button
                    child: const Icon(CupertinoIcons.escape),
                    onPressed: () => FirebaseAuth.instance.signOut()),
                middle: Text(widget.user.displayName ?? ''),
                trailing: CupertinoButton(
                    //A button to bring up a list modal
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
                  //The first group is the first two filtered lists: 'Today' and 'Scheduled'.
                  //I didn't extract these filtered lists into components even though I probably should've
                  //because they each had very particular props that they were passing to their children
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
                                            //Filter all the list items by the ones that are due today
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
                                            //Sort the list items by their due date
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
                                          //Filter the list items, retaining all with a due date
                                          filter: (item) => item.date != null,
                                          sort: (itemA, itemB) {
                                            //Sort the list items by their due date
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
                  //The second group is next two filtered list buttons: 'All' and 'Flagged'
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
                                            //The empty list uid and no filtering will show all user todo items
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
                                              //Filter all items by if they're flagged or not
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
                  //A title to display 'My Lists' above the list of user todo lists
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
                //The user todo lists mapped into slidable list tile buttons
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
                                //When clicked, navigate to that list's items page
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
                                    //Action to bring up the list editing page as a modal
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
                                    //Action to delete the list. Brings up the delete list dialog
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
