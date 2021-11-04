import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:si413_project/model/user.dart';
import 'package:si413_project/ui/loading.dart';

import 'list_page.dart';
import 'new_list_page.dart';

class ListsPage extends StatefulWidget {
  final User user;

  const ListsPage({Key? key, required this.user}) : super(key: key);

  @override
  State<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  Stream<DocumentSnapshot<UserData>> userDataRef() => FirebaseFirestore.instance
      .doc('users/${widget.user.uid}')
      .withConverter<UserData>(
          fromFirestore: (snapshot, _) => UserData.fromJson(snapshot.data()!),
          toFirestore: (userData, _) => userData.toJson())
      .snapshots();

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<DocumentSnapshot<UserData>>(
        stream: userDataRef(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Loading();
          }
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: const Text('Lists'),
              trailing: CupertinoButton(
                child: const Icon(CupertinoIcons.add),
                onPressed: () => Navigator.push(context,
                    CupertinoPageRoute(builder: (context) => NewListPage())),
              ),
            ),
            child: ListView(
              children: snapshot.data
                      ?.data()
                      ?.lists
                      .map((listItem) => CupertinoListTile(
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
                                    builder: (context) => ListPage(
                                          listItem: listItem,
                                        ))),
                          ))
                      .toList() ??
                  [],
            ),
          );
        },
      );
}
