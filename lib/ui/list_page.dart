import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import '../model/todo.dart';

class ListPage extends StatefulWidget {
  final User user;
  final String listUid;

  const ListPage({Key? key, required this.user, required this.listUid})
      : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  Stream<QuerySnapshot<Map<String, dynamic>>> todoCollectionSnapshot() =>
      FirebaseFirestore.instance
          .collection('/todoItems')
          .where('userUid', isEqualTo: widget.user.uid)
          .where('listUid', isEqualTo: widget.listUid)
          .orderBy('added')
          .snapshots();

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: todoCollectionSnapshot(),
        builder: (context, snapshot) {
          final todoItems = snapshot.data?.docs
                  .toList()
                  .map((doc) => TodoItem.fromJson(doc.data())) ??
              [];
          return ListView(
              children: todoItems
                  .map((todoItem) => CupertinoListTile(
                        title: Text(todoItem.title),
                      ))
                  .toList());
        },
      ));
}
